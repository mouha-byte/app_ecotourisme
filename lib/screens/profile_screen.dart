import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:ecoguide/screens/login_screen.dart';
import 'package:ecoguide/screens/admin/admin_dashboard_screen.dart';
import 'package:ecoguide/services/offline_map_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final OfflineMapService _offlineMapService = OfflineMapService();
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String _cacheSize = '0 B';

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await _offlineMapService.getFormattedCacheSize();
    if (mounted) {
      setState(() => _cacheSize = size);
    }
  }

  Future<void> _showDownloadMapDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTiles = _offlineMapService.calculateTileCount();

    showDialog(
      context: context,
      barrierDismissible: !_isDownloading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.download_for_offline, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Text(
                  'Carte Hors-Ligne',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Téléchargez la carte de la Tunisie pour utiliser l\'application sans connexion internet.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cache actuel:',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _cacheSize,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tuiles à télécharger:',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$totalTiles',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (_isDownloading) ...[
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            actions: [
              if (!_isDownloading) ...[
                TextButton(
                  onPressed: () async {
                    await _offlineMapService.clearCache();
                    await _loadCacheSize();
                    if (mounted) {
                      setDialogState(() {});
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache supprimé')),
                      );
                    }
                  },
                  child: Text(
                    'Vider le cache',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isDownloading = true;
                      _downloadProgress = 0;
                    });
                    setDialogState(() {});

                    await _offlineMapService.downloadTunisiaTiles(
                      onProgress: (downloaded, total) {
                        if (mounted) {
                          setState(() {
                            _downloadProgress = downloaded / total;
                          });
                          setDialogState(() {});
                        }
                      },
                    );

                    await _loadCacheSize();

                    if (mounted) {
                      setState(() => _isDownloading = false);
                      setDialogState(() {});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Carte téléchargée avec succès!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text(
                    'Télécharger',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ] else ...[
                TextButton(
                  onPressed: null,
                  child: Text(
                    'Téléchargement en cours...',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;
    // temporary check ensures code is reachable; replace with real logic later
    final bool isAdmin = (user?.email ?? '').contains('admin'); // TODO: Implement admin check from Firestore

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 60,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bienvenue sur EcoGuide',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connectez-vous pour accéder à plus de fonctionnalités',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Se connecter'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LoginScreen(isRegister: true),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Créer un compte'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primaryGreen,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Utilisateur',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Sites visités', '12', Icons.place),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Itinéraires', '5', Icons.route),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      'Réservations', '3', Icons.calendar_today),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(Icons.favorite, 'Sites favoris', () {}),
            _buildMenuItem(Icons.history, 'Historique', () {}),
            _buildMenuItem(
              Icons.download_for_offline,
              'Télécharger la carte',
              _showDownloadMapDialog,
            ),
            _buildMenuItem(Icons.notifications, 'Notifications', () {}),
            _buildMenuItem(Icons.help, 'Aide & FAQ', () {}),
            _buildMenuItem(Icons.info, 'À propos', () {}),

            if (isAdmin) ...[
              const Divider(height: 32),
              _buildMenuItem(
                Icons.admin_panel_settings,
                'Dashboard Admin',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
                color: AppTheme.accentOrange,
              ),
            ],

            const Divider(height: 32),
            _buildMenuItem(
              Icons.logout,
              'Déconnexion',
              () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Déconnexion réussie')),
                  );
                }
              },
              color: AppTheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryGreen),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
