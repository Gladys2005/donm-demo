import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_logo.dart';

class KYCEvolutionPage extends StatefulWidget {
  const KYCEvolutionPage({super.key});

  @override
  State<KYCEvolutionPage> createState() => _KYCEvolutionPageState();
}

class _KYCEvolutionPageState extends State<KYCEvolutionPage> {
  int _currentStep = 0;
  String _currentLevel = 'CLASSIQUE';
  
  final List<KYCStep> _steps = [
    KYCStep(
      title: 'Informations personnelles',
      description: 'Nom, email, téléphone',
      icon: Icons.person,
      isCompleted: false,
    ),
    KYCStep(
      title: 'Documents d\'identité',
      description: 'Pièce d\'identité, passeport',
      icon: Icons.credit_card,
      isCompleted: false,
    ),
    KYCStep(
      title: 'Documents additionnels',
      description: 'Permis, certificats',
      icon: Icons.description,
      isCompleted: false,
    ),
    KYCStep(
      title: 'Validation',
      description: 'Vérification par l\'équipe DonM',
      icon: Icons.verified,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: const Text(
          'Évolution de compte',
          style: TextStyle(
            color: DonMTheme.noirDonM,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Level Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: _getLevelGradient(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: DonMTheme.noirDonM.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getLevelIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Niveau actuel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                _getLevelTitle(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                _getLevelDescription(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _getProgress(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Evolution Path
              const Text(
                'Parcours d\'évolution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),

              // Steps
              ...List.generate(_steps.length, (index) {
                return _buildStepCard(index);
              }),

              const SizedBox(height: 30),

              // Upgrade Options
              if (_currentLevel == 'CLASSIQUE' || _currentLevel == 'CERTIFIÉ') ...[
                const Text(
                  'Options d\'évolution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_currentLevel == 'CLASSIQUE') ...[
                      Expanded(
                        child: _buildUpgradeCard(
                          'CERTIFIÉ',
                          'Certification DonM',
                          'Devenir livreur certifié',
                          DonMTheme.vertDonM,
                          Icons.verified,
                          () => _upgradeToCertified(),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (_currentLevel == 'CERTIFIÉ') ...[
                      Expanded(
                        child: _buildUpgradeCard(
                          'CERTIFIÉ+',
                          'Certification Premium',
                          'Accès aux missions premium',
                          DonMTheme.orangeDonM,
                          Icons.workspace_premium,
                          () => _upgradeToPremium(),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: _buildUpgradeCard(
                        'ASSURÉ',
                        'Assurance livraison',
                        'Protéger vos livraisons',
                        DonMTheme.vertFonceDonM,
                        Icons.security,
                        () => _addInsurance(),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // Benefits
              _buildBenefitsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(int index) {
    final step = _steps[index];
    final isCompleted = index < _currentStep;
    final isCurrent = index == _currentStep;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? DonMTheme.vertDonM 
              : isCurrent 
                  ? DonMTheme.orangeDonM 
                  : DonMTheme.grisClairDonM!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DonMTheme.noirDonM.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? DonMTheme.vertDonM 
                  : isCurrent 
                      ? DonMTheme.orangeDonM 
                      : DonMTheme.grisDonM,
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DonMTheme.noirDonM,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: DonMTheme.grisDonM,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: DonMTheme.vertDonM,
              size: 24,
            )
          else if (isCurrent)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: DonMTheme.orangeDonM,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    String level,
    String title,
    String description,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DonMTheme.blancDonM,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: DonMTheme.grisDonM,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DonMTheme.grisClairDonM,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avantages du niveau',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          ..._getBenefits().map((benefit) => _buildBenefitItem(benefit)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: DonMTheme.vertDonM,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getLevelGradient() {
    switch (_currentLevel) {
      case 'CLASSIQUE':
        return const LinearGradient(
          colors: [DonMTheme.grisDonM, DonMTheme.grisClairDonM],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'CERTIFIÉ':
        return DonMTheme.gradientVert;
      case 'CERTIFIÉ+':
        return DonMTheme.gradientPrincipal;
      case 'ASSURÉ':
        return const LinearGradient(
          colors: [DonMTheme.vertFonceDonM, DonMTheme.vertDonM],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [DonMTheme.grisDonM, DonMTheme.grisClairDonM],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getLevelIcon() {
    switch (_currentLevel) {
      case 'CLASSIQUE':
        return Icons.person;
      case 'CERTIFIÉ':
        return Icons.verified;
      case 'CERTIFIÉ+':
        return Icons.workspace_premium;
      case 'ASSURÉ':
        return Icons.security;
      default:
        return Icons.person;
    }
  }

  String _getLevelTitle() {
    switch (_currentLevel) {
      case 'CLASSIQUE':
        return 'CLASSIQUE';
      case 'CERTIFIÉ':
        return 'CERTIFIÉ';
      case 'CERTIFIÉ+':
        return 'CERTIFIÉ+';
      case 'ASSURÉ':
        return 'ASSURÉ';
      default:
        return 'CLASSIQUE';
    }
  }

  String _getLevelDescription() {
    switch (_currentLevel) {
      case 'CLASSIQUE':
        return 'Livreur de base';
      case 'CERTIFIÉ':
        return 'Livreur certifié DonM';
      case 'CERTIFIÉ+':
        return 'Livreur premium';
      case 'ASSURÉ':
        return 'Livreur assuré';
      default:
        return 'Livreur de base';
    }
  }

  double _getProgress() {
    switch (_currentLevel) {
      case 'CLASSIQUE':
        return 0.25;
      case 'CERTIFIÉ':
        return 0.5;
      case 'CERTIFIÉ+':
        return 0.75;
      case 'ASSURÉ':
        return 1.0;
      default:
        return 0.25;
    }
  }

  List<String> _getBenefits() {
    switch (_currentLevel) {
      case 'CLASSIQUE':
        return [
          'Accès aux missions de base',
          'Commission de 10%',
          'Support par email',
        ];
      case 'CERTIFIÉ':
        return [
          'Accès aux missions premium',
          'Commission de 15%',
          'Support prioritaire',
          'Badge de certification',
        ];
      case 'CERTIFIÉ+':
        return [
          'Accès exclusif aux missions VIP',
          'Commission de 20%',
          'Support dédié 24/7',
          'Badge premium',
        ];
      case 'ASSURÉ':
        return [
          'Protection contre les accidents',
          'Indemnisation rapide',
          'Assistance routière',
          'Zéro franchise',
        ];
      default:
        return [
          'Accès aux missions de base',
          'Commission de 10%',
          'Support par email',
        ];
    }
  }

  void _upgradeToCertified() {
    // TODO: Implement upgrade to certified
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirection vers la certification...'),
        backgroundColor: DonMTheme.vertDonM,
      ),
    );
  }

  void _upgradeToPremium() {
    // TODO: Implement upgrade to premium
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirection vers l\'offre premium...'),
        backgroundColor: DonMTheme.orangeDonM,
      ),
    );
  }

  void _addInsurance() {
    // TODO: Implement insurance addition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirection vers l\'assurance...'),
        backgroundColor: DonMTheme.vertFonceDonM,
      ),
    );
  }
}

class KYCStep {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;

  KYCStep({
    required this.title,
    required this.description,
    required this.icon,
    this.isCompleted = false,
  });
}
