import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:form_validator/form_validator.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/auth_service.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Header
                Text(
                  'Créer votre compte',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                Text(
                  'Rejoignez DonM pour des livraisons rapides et fiables',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing * 2),
                
                // Name fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: ValidationBuilder()
                            .required('Prénom requis')
                            .minLength(2, 'Minimum 2 caractères')
                            .build(),
                      ),
                    ),
                    const SizedBox(width: AppConfig.defaultSpacing),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: ValidationBuilder()
                            .required('Nom requis')
                            .minLength(2, 'Minimum 2 caractères')
                            .build(),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: ValidationBuilder()
                      .required('Email requis')
                      .email('Email invalide')
                      .build(),
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '+225 XX XX XX XX XX',
                  ),
                  validator: ValidationBuilder()
                      .required('Téléphone requis')
                      .add((value) {
                        if (!AuthService.isValidPhoneNumber(value ?? '')) {
                          return 'Numéro de téléphone invalide';
                        }
                        return null;
                      })
                      .build(),
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: ValidationBuilder()
                      .required('Mot de passe requis')
                      .minLength(8, 'Minimum 8 caractères')
                      .add((value) {
                        final validation = AuthService.validatePassword(value ?? '');
                        if (!validation['isValid']) {
                          return validation['errors'].first;
                        }
                        return null;
                      })
                      .build(),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Password strength indicator
                if (_passwordController.text.isNotEmpty)
                  PasswordStrengthIndicator(
                    password: _passwordController.text,
                  ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: ValidationBuilder()
                      .required('Confirmation requise')
                      .add((value) {
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      })
                      .build(),
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing),
                
                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'J\'accepte les ',
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            WidgetSpan(
                              child: TextButton(
                                onPressed: () {
                                  // Open terms and conditions
                                },
                                child: const Text('termes et conditions'),
                              ),
                            ),
                            const TextSpan(text: ' et la '),
                            WidgetSpan(
                              child: TextButton(
                                onPressed: () {
                                  // Open privacy policy
                                },
                                child: const Text('politique de confidentialité'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing * 3),
                
                // Register button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: (_agreeToTerms && state is! AuthLoading) ? _register : null,
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('S\'inscrire'),
                    );
                  },
                ),
                
                const SizedBox(height: AppConfig.defaultSpacing * 2),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte? '),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final validation = AuthService.validatePassword(password);
    final strength = validation['strength'] as int;
    final strengthLevel = validation['strengthLevel'] as String;
    final strengthColor = validation['strengthColor'] as Color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Force du mot de passe: ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              strengthLevel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 4.0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
      ],
    );
  }
}
