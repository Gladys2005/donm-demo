import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_branding.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class DonMHomePage extends StatefulWidget {
  const DonMHomePage({super.key});

  @override
  State<DonMHomePage> createState() => _DonMHomePageState();
}

class _DonMHomePageState extends State<DonMHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeTab(),
    const OrdersTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DonMTheme.blancDonM,
          boxShadow: [
            BoxShadow(
              color: DonMTheme.noirDonM.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: DonMTheme.orangeDonM,
          unselectedItemColor: DonMTheme.grisDonM,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'Commandes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                context.go('/home/orders/create');
              },
              backgroundColor: DonMTheme.orangeDonM,
              foregroundColor: DonMTheme.blancDonM,
              elevation: 8,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nouvelle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          : null,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is AuthAuthenticated
            ? state.user['first_name'] ?? 'Utilisateur'
            : 'Utilisateur';

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header DonM
                DonMBranding.getDonMHeader(
                  title: 'Bonjour, $userName!',
                  subtitle: 'Livraison rapide et fiable',
                  action: IconButton(
                    onPressed: () {
                      context.go('/home/profile/notifications');
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Carte de statistiques
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DonMBranding.getDonMCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DonMBranding.getCircularLogo(size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vos livraisons',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    'Ce mois-ci',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: DonMTheme.grisDonM,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '24',
                                'Total',
                                DonMTheme.orangeDonM,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatItem(
                                '12',
                                'Ce mois',
                                DonMTheme.vertDonM,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatItem(
                                '5.2k',
                                'Économies',
                                DonMTheme.vertFonceDonM,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions rapides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions rapides',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.local_shipping,
                                label: 'Nouvelle\nlivraison',
                                color: DonMTheme.orangeDonM,
                                onTap: () {
                                  context.go('/home/orders/create');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.qr_code_scanner,
                                label: 'Scanner\nQR code',
                                color: DonMTheme.vertDonM,
                                onTap: () {
                                  // Scanner QR code
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.history,
                                label: 'Historique\nlivraisons',
                                color: DonMTheme.vertFonceDonM,
                                onTap: () {
                                  setState(() {
                                    _currentIndex = 1;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),

                const SizedBox(height: 24),

                // Commandes récentes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DonMBranding.getDonMCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commandes récentes',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentIndex = 1;
                                });
                              },
                              child: Text(
                                'Voir tout',
                                style: TextStyle(
                                  color: DonMTheme.vertDonM,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildRecentOrder(
                          orderNumber: 'ORD-2024-001',
                          status: 'En cours',
                          date: 'Aujourd\'hui',
                          price: '2,500 FCFA',
                          statusType: DonMStatus.info,
                        ),
                        const SizedBox(height: 12),
                        _buildRecentOrder(
                          orderNumber: 'ORD-2024-002',
                          status: 'Livré',
                          date: 'Hier',
                          price: '1,800 FCFA',
                          statusType: DonMStatus.success,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Services
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nos services',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildServiceCard(
                            icon: Icons.local_shipping,
                            title: 'Livraison',
                            subtitle: 'Rapide et fiable',
                            color: DonMTheme.orangeDonM,
                            onTap: () {
                              context.go('/home/orders/create');
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.store,
                            title: 'Marchandises',
                            subtitle: 'Tous types',
                            color: DonMTheme.vertDonM,
                            onTap: () {
                              // Services marchandises
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.motorcycle,
                            title: 'Course',
                            subtitle: 'Express',
                            color: DonMTheme.vertFonceDonM,
                            onTap: () {
                              // Service course
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.inventory_2,
                            title: 'Colis',
                            subtitle: 'Sécurisé',
                            color: DonMTheme.orangeClairDonM,
                            onTap: () {
                              // Service colis
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: DonMTheme.grisDonM,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: DonMTheme.grisClairDonM!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            DonMIcon(
              icon: icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrder({
    required String orderNumber,
    required String status,
    required String date,
    required String price,
    required DonMStatus statusType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DonMTheme.grisClairDonM,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          DonMBranding.getCircularLogo(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: DonMTheme.grisDonM,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              DonMBranding.getStatusBadge(
                text: status,
                status: statusType,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return DonMBranding.getDonMCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DonMIcon(
            icon: icon,
            size: 40,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: DonMTheme.grisDonM,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Commandes',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profil',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
