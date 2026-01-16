import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoguide/screens/home_screen.dart';
import 'package:ecoguide/screens/login_screen.dart';
import 'package:ecoguide/screens/splash_screen.dart';
import 'package:ecoguide/screens/onboarding_screen.dart';

/// Wrapper widget that handles app navigation flow:
/// 1. Show splash screen
/// 2. Check authentication
/// 3. Show onboarding for first-time users
/// 4. Navigate to home or login
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  static const String _onboardingKey = 'has_completed_onboarding';
  
  bool _showSplash = true;
  bool? _hasCompletedOnboarding;
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool(_onboardingKey) ?? false;
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = hasCompleted;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = true;
      });
    }
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    // Then check auth state
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        debugPrint('AuthWrapper: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, user=${snapshot.data?.email}');
        
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...'),
                ],
              ),
            ),
          );
        }
        
        // Route based on authentication status
        if (snapshot.hasData && snapshot.data != null) {
          // Check if user needs onboarding
          if (_hasCompletedOnboarding == null) {
            // Still loading onboarding status
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (!_hasCompletedOnboarding!) {
            // Show onboarding for first-time users
            debugPrint('AuthWrapper: Showing onboarding for first-time user');
            return OnboardingScreen(
              key: const ValueKey('onboarding'),
              onComplete: _completeOnboarding,
            );
          }
          
          debugPrint('AuthWrapper: Navigating to HomeScreen');
          return const HomeScreen(key: ValueKey('home'));
        } else {
          debugPrint('AuthWrapper: Navigating to LoginScreen');
          return const LoginScreen(key: ValueKey('login'));
        }
      },
    );
  }
}
