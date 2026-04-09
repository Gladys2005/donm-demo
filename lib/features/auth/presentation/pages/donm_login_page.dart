import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:form_validator/form_validator.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_logo.dart';
import '../../../../widgets/donm_branding.dart';
import '../../../../core/services/auth_service.dart';
import '../bloc/auth_bloc.dart';

class DonMLoginPage extends StatefulWidget {
  const DonMLoginPage({super.key});

  @override
  State<DonMLoginPage> createState() => _DonMLoginPageState();
}

class _DonMLoginPageState extends State<DonMLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DonMTheme.erreurDonM,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          } else if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is AuthAuthenticated) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo DonM
                Center(
                  child: DonMLogoWithSlogan(
                    logoSize: 80,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Carte de connexion
                DonMBranding.getDonMCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        
                        Text(
                          'Connexion',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: DonMTheme.noirDonM,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Champ email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            hintText: 'exemple@email.com',
                          ),
                          validator: ValidationBuilder()
                              .required('Email requis')
                              .email('Email invalide')
                              .build(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Champ mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                                color: DonMTheme.grisDonM,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            hintText: 'Entrez votre mot de passe',
                          ),
                          validator: ValidationBuilder()
                              .required('Mot de passe requis')
                              .minLength(6, 'Minimum 6 caractères')
                              .build(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Se souvenir et mot de passe oublié
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: DonMTheme.orangeDonM,
                            ),
                            const Text(
                              'Se souvenir de moi',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                context.go('/forgot-password');
                              },
                              child: Text(
                                'Mot de passe oublié?',
                                style: TextStyle(
                                  color: DonMTheme.vertDonM,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Bouton de connexion
                        DonMBranding.getDonMButton(
                          text: 'Se connecter',
                          onPressed: _login,
                          isLoading: _isLoading,
                          width: double.infinity,
                          height: 50,
                          icon: Icons.login,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Ligne de séparation
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OU',
                                style: TextStyle(
                                  color: DonMTheme.grisDonM,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Connexion biométrique
                        FutureBuilder<bool>(
                          future: AuthService.isBiometricAvailable(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return DonMBranding.getDonMButton(
                                text: 'Connexion biométrique',
                                onPressed: () async {
                                  final authenticated = await AuthService.authenticateWithBiometric(
                                    localizedReason: 'Connectez-vous avec votre empreinte',
                                  );
                                  if (authenticated) {
                                    // Gérer la connexion biométrique
                                  }
                                },
                                isOutlined: true,
                                type: DonMButtonType.tertiary,
                                width: double.infinity,
                                height: 50,
                                icon: Icons.fingerprint,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Lien d'inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pas encore de compte? ',
                              style: TextStyle(
                                color: DonMTheme.grisDonM,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.go('/register');
                              },
                              child: Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  color: DonMTheme.orangeDonM,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
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
