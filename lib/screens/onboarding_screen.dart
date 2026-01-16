import 'package:flutter/material.dart';
import 'package:ecoguide/utils/app_theme.dart';

/// Onboarding screen with 3 pages explaining app features
/// Shown only on first login
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.explore,
      title: 'Découvrez la Nature',
      description:
          'Explorez des sites écotouristiques uniques en Tunisie. Trouvez des réserves naturelles, parcs et plages préservées.',
      color: AppTheme.primaryGreen,
    ),
    OnboardingPage(
      icon: Icons.route,
      title: 'Planifiez vos Itinéraires',
      description:
          'Créez des itinéraires personnalisés avec notre assistant IA. Recevez des recommandations basées sur vos préférences.',
      color: AppTheme.accentBlue,
    ),
    OnboardingPage(
      icon: Icons.download_for_offline,
      title: 'Mode Hors-Ligne',
      description:
          'Téléchargez les cartes pour explorer même sans connexion internet. Parfait pour les randonnées en pleine nature!',
      color: AppTheme.accentOrange,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], isDark);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _pages[_currentPage].color
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Complete button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _pages[_currentPage].color,
                        _pages[_currentPage].color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _pages[_currentPage].color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Data class for onboarding page content
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
