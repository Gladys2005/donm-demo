import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_logo.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/user_model.dart';
import '../role_selection_page.dart';
import '../kyc_evolution_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    final user = await StorageService.getCurrentUser();
    final role = await StorageService.getCurrentRole();
    
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: DonMTheme.blancDonM,
        appBar: AppBar(
          backgroundColor: DonMTheme.blancDonM,
          elevation: 0,
          title: const Text(
            'Profil',
            style: TextStyle(
              color: DonMTheme.noirDonM,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Erreur: Utilisateur non connecté',
            style: TextStyle(
              fontSize: 16,
              color: DonMTheme.grisDonM,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DonMTheme.grisClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: DonMTheme.noirDonM,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _getProfileGradient(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  DonMLogoWidget(
                    size: 60,
                    showText: true,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getProfileTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getProfileSubtitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getRoleColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getRoleIcon(),
                            color: _getRoleColor(),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: DonMTheme.noirDonM,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: DonMTheme.grisDonM,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: DonMTheme.grisDonM,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DonMTheme.noirDonM,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentUser!.status.toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Role Evolution Section
            if (_currentUser!.role == UserRole.delivery) ...[
              _buildEvolutionSection(),
            ],

            // Quick Actions
            const SizedBox(height: 30),
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DonMTheme.noirDonM,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildActionCard(
                  Icons.edit,
                  'Modifier profil',
                  'Mettre à jour vos informations',
                  DonMTheme.orangeDonM,
                  () {
                    // TODO: Navigate to edit profile
                  },
                ),
                _buildActionCard(
                  Icons.history,
                  'Historique',
                  'Vos commandes et livraisons',
                  DonMTheme.vertDonM,
                  () {
                    // TODO: Navigate to history
                  },
                ),
                _buildActionCard(
                  Icons.notifications,
                  'Notifications',
                  'Gérer vos préférences',
                  DonMTheme.vertFonceDonM,
                  () {
                    // TODO: Navigate to notifications
                  },
                ),
                _buildActionCard(
                  Icons.settings,
                  'Paramètres',
                  'Configuration de l\'application',
                  DonMTheme.grisDonM,
                  () {
                    // TODO: Navigate to settings
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthService.logout();
                  if (mounted) {
                    context.go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DonMTheme.erreurDonM,
                  foregroundColor: DonMTheme.blancDonM,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolutionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Évolution de compte',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DonMTheme.noirDonM,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/kyc-evolution');
                  },
                  child: const Text(
                    'Voir détails',
                    style: TextStyle(
                      color: DonMTheme.vertDonM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DonMTheme.vertDonM.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DonMTheme.vertDonM.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: DonMTheme.vertDonM,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progressez dans votre carrière',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: DonMTheme.noirDonM,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Accédez à des niveaux supérieurs',
                              style: TextStyle(
                                fontSize: 14,
                                color: DonMTheme.grisDonM,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: DonMTheme.grisClairDonM,
                    valueColor: AlwaysStoppedAnimation<Color>(DonMTheme.vertDonM),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Niveau actuel: CLASSIQUE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DonMTheme.noirDonM,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DonMTheme.noirDonM,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: DonMTheme.grisDonM,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getProfileGradient() {
    switch (_currentUser?.role) {
      case UserRole.client:
        return DonMTheme.gradientPrincipal;
      case UserRole.vendor:
        return DonMTheme.gradientVert;
      case UserRole.delivery:
        return const LinearGradient(
          colors: [DonMTheme.vertFonceDonM, DonMTheme.vertDonM],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return DonMTheme.gradientPrincipal;
    }
  }

  String _getProfileTitle() {
    switch (_currentUser?.role) {
      case UserRole.client:
        return 'Espace Client';
      case UserRole.vendor:
        return 'Espace Vendeur';
      case UserRole.delivery:
        return 'Espace Livreur';
      default:
        return 'Profil';
    }
  }

  String _getProfileSubtitle() {
    switch (_currentUser?.role) {
      case UserRole.client:
        return 'Commandez et suivez vos livraisons';
      case UserRole.vendor:
        return 'Gérez votre boutique et vos commandes';
      case UserRole.delivery:
        return 'Livrez pour DonM et gagnez de l\'argent';
      default:
        return 'Bienvenue sur DonM';
    }
  }

  Color _getRoleColor() {
    switch (_currentUser?.role) {
      case UserRole.client:
        return DonMTheme.orangeDonM;
      case UserRole.vendor:
        return DonMTheme.vertDonM;
      case UserRole.delivery:
        return DonMTheme.vertFonceDonM;
      default:
        return DonMTheme.grisDonM;
    }
  }

  IconData _getRoleIcon() {
    switch (_currentUser?.role) {
      case UserRole.client:
        return Icons.person;
      case UserRole.vendor:
        return Icons.store;
      case UserRole.delivery:
        return Icons.motorcycle;
      default:
        return Icons.person;
    }
  }

  Color _getStatusColor() {
    switch (_currentUser?.status) {
      case UserStatus.active:
        return DonMTheme.succesDonM;
      case UserStatus.suspended:
        return DonMTheme.erreurDonM;
      case UserStatus.pending:
        return DonMTheme.infoDonM;
      default:
        return DonMTheme.grisDonM;
    }
  }
}
