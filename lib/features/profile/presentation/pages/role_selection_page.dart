import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_logo.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: const Text(
          'Choisissez votre rôle',
          style: TextStyle(
            color: DonMTheme.noirDonM,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo DonM
              Center(
                child: DonMLogoWidget(
                  size: 80,
                  showText: true,
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Comment souhaitez-vous utiliser DonM?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DonMTheme.noirDonM,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    _buildRoleCard(
                      icon: Icons.person,
                      title: 'CLIENT',
                      description: 'Commander des livraisons\nSuivre vos commandes en temps réel',
                      color: DonMTheme.orangeDonM,
                      isSelected: _selectedRole == 'client',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'client';
                        });
                        _saveRoleAndNavigate('client');
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildRoleCard(
                      icon: Icons.store,
                      title: 'VENDEUR',
                      description: 'Gérer votre boutique\nRecevoir des commandes clients',
                      color: DonMTheme.vertDonM,
                      isSelected: _selectedRole == 'vendor',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'vendor';
                        });
                        _saveRoleAndNavigate('vendor');
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildRoleCard(
                      icon: Icons.motorcycle,
                      title: 'LIVREUR',
                      description: 'Livrer pour DonM\nGagner de l\'argent',
                      color: DonMTheme.vertFonceDonM,
                      isSelected: _selectedRole == 'delivery',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'delivery';
                        });
                        _saveRoleAndNavigate('delivery');
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Skip for now
              TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text(
                  'Continuer en tant que client',
                  style: TextStyle(
                    color: DonMTheme.grisDonM,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : DonMTheme.grisClairDonM,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : DonMTheme.grisDonM!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : DonMTheme.noirDonM,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white.withOpacity(0.9) : DonMTheme.grisDonM,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRoleAndNavigate(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);
      
      if (mounted) {
        // Navigate based on role
        switch (role) {
          case 'client':
            context.go('/home');
            break;
          case 'vendor':
            context.go('/home');
            break;
          case 'delivery':
            context.go('/home');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: DonMTheme.erreurDonM,
          ),
        );
      }
    }
  }
}
