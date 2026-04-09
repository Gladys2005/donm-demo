import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_logo.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/auth_bloc.dart';

class DonMSplashPage extends StatefulWidget {
  const DonMSplashPage({super.key});

  @override
  State<DonMSplashPage> createState() => _DonMSplashPageState();
}

class _DonMSplashPageState extends State<DonMSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _progressController.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final isOnboardingCompleted = await StorageService.isOnboardingCompleted();
    
    if (!mounted) return;

    if (isOnboardingCompleted) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: DonMTheme.blancDonM,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DonMTheme.blancDonM,
                  DonMTheme.orangeClairDonM.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animé
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: DonMSplashLogo(
                        size: 100,
                        animation: _logoAnimation,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Texte animé
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textAnimation,
                      child: Column(
                        children: [
                          Text(
                            'DonM',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: DonMTheme.noirDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Livraison rapide et fiable',
                            style: TextStyle(
                              fontSize: 16,
                              color: DonMTheme.grisDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Barre de progression
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DonMTheme.grisClairDonM,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: DonMTheme.gradientPrincipal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Texte de chargement
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _progressAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DonMTheme.orangeDonM,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Chargement...',
                            style: TextStyle(
                              fontSize: 14,
                              color: DonMTheme.grisDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Version
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: DonMTheme.grisDonM.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DonMSplashLogo extends StatelessWidget {
  final double size;
  final Animation<double> animation;

  const DonMSplashLogo({
    super.key,
    this.size = 80,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: DonMTheme.gradientPrincipal,
              borderRadius: BorderRadius.circular(size * 0.25),
              boxShadow: [
                BoxShadow(
                  color: DonMTheme.orangeDonM.withOpacity(0.4),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }
}
