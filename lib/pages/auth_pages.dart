import 'package:flutter/material.dart';
import '../main_simple.dart';
import '../services/auth_service_simple.dart';

// Page de connexion améliorée
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.jauneClairDonM,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const DonMLogoWidget(size: 80),
              const SizedBox(height: 40),
              Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DonMTheme.vertFonceDonM,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accédez à votre espace DonM',
                style: TextStyle(
                  fontSize: 16,
                  color: DonMTheme.grisDonM,
                ),
              ),
              const SizedBox(height: 40),
              
              // Formulaire de connexion
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DonMTheme.blancDonM,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: DonMTheme.noirDonM.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'exemple@donm.ci',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'Entrez votre mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Bouton de connexion
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DonMTheme.vertDonM,
                            foregroundColor: DonMTheme.blancDonM,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: DonMTheme.blancDonM,
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Mot de passe oublié
                      TextButton(
                        onPressed: () {
                          // TODO: Implémenter la récupération de mot de passe
                        },
                        child: Text(
                          'Mot de passe oublié?',
                          style: TextStyle(
                            color: DonMTheme.vertDonM,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Comptes de démonstration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DonMTheme.blancDonM.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DonMTheme.vertDonM.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comptes de démonstration:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: DonMTheme.vertFonceDonM,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDemoAccount('Client', 'client@donm.ci'),
                    _buildDemoAccount('Vendeur', 'vendeur@donm.ci'),
                    _buildDemoAccount('Livreur', 'livreur@donm.ci'),
                    const SizedBox(height: 8),
                    Text(
                      'Mot de passe: password123',
                      style: TextStyle(
                        fontSize: 12,
                        color: DonMTheme.grisDonM,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Lien vers inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore de compte?',
                    style: TextStyle(
                      color: DonMTheme.grisDonM,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: DonMTheme.vertDonM,
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
    );
  }

  Widget _buildDemoAccount(String role, String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.account_circle,
            size: 16,
            color: DonMTheme.vertDonM,
          ),
          const SizedBox(width: 8),
          Text(
            '$role: $email',
            style: TextStyle(
              fontSize: 12,
              color: DonMTheme.noirDonM,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthServiceSimple();
      final user = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Rediriger selon le rôle et le statut
      await _redirectToAppropriatePage(user);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: DonMTheme.erreurDonM,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _redirectToAppropriatePage(User user) async {
    final authService = AuthServiceSimple();

    // Si le compte est en attente de validation
    if (user.status == UserStatus.pending) {
      if (user.role == UserRole.vendor) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PendingValidationPage(
              role: user.role,
              message: 'Votre compte vendeur est en attente de validation par notre équipe.',
            ),
          ),
        );
        return;
      }
    }

    // Si le livreur n'a pas complété le KYC
    if (user.role == UserRole.delivery && user.kycLevel != 'VERIFIED') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const KYCEvolutionPage(),
        ),
      );
      return;
    }

    // Redirection normale selon le rôle
    switch (user.role) {
      case UserRole.client:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case UserRole.vendor:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const VendorDashboardPage()),
        );
        break;
      case UserRole.delivery:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DeliveryDashboardPage()),
        );
        break;
    }
  }
}

// Page d'attente de validation
class PendingValidationPage extends StatelessWidget {
  final UserRole role;
  final String message;

  const PendingValidationPage({
    super.key,
    required this.role,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.jauneClairDonM,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DonMLogoWidget(size: 100),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DonMTheme.blancDonM,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: DonMTheme.noirDonM.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 64,
                      color: DonMTheme.jauneDonM,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Compte en attente de validation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DonMTheme.vertFonceDonM,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: DonMTheme.grisDonM,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Nous vous enverrons un email dès que votre compte sera validé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: DonMTheme.grisDonM,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await AuthServiceSimple().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DonMTheme.vertDonM,
                    side: const BorderSide(color: DonMTheme.vertDonM),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Se déconnecter',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page d'inscription améliorée
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.client;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.jauneClairDonM,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const DonMLogoWidget(size: 60),
              const SizedBox(height: 20),
              Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DonMTheme.vertFonceDonM,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoignez la communauté DonM',
                style: TextStyle(
                  fontSize: 16,
                  color: DonMTheme.grisDonM,
                ),
              ),
              const SizedBox(height: 24),
              
              // Formulaire d'inscription
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DonMTheme.blancDonM,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: DonMTheme.noirDonM.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nom
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom complet',
                          hintText: 'Entrez votre nom',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'exemple@donm.ci',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Téléphone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          hintText: '+225 XX XX XX XX XX',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de téléphone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Rôle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Je suis un:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<UserRole>(
                                  title: const Text('Client'),
                                  value: UserRole.client,
                                  groupValue: _selectedRole,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<UserRole>(
                                  title: const Text('Vendeur'),
                                  value: UserRole.vendor,
                                  groupValue: _selectedRole,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          RadioListTile<UserRole>(
                            title: const Text('Livreur'),
                            value: UserRole.delivery,
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          if (_selectedRole == UserRole.delivery)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: DonMTheme.jauneDonM.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: DonMTheme.jauneDonM),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: DonMTheme.jauneDonM,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Le KYC (vérification d\'identité) sera requis pour les livreurs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: DonMTheme.vertFonceDonM,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_selectedRole == UserRole.vendor)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: DonMTheme.vertDonM.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: DonMTheme.vertDonM),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: DonMTheme.vertDonM,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Votre compte sera validé par notre équipe avant activation',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: DonMTheme.vertFonceDonM,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'Min 6 caractères',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirmation du mot de passe
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          hintText: 'Répétez votre mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Bouton d'inscription
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DonMTheme.vertDonM,
                            foregroundColor: DonMTheme.blancDonM,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: DonMTheme.blancDonM,
                                )
                              : const Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Lien vers connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte?',
                    style: TextStyle(
                      color: DonMTheme.grisDonM,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        color: DonMTheme.vertDonM,
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
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthServiceSimple();
      final user = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      // Rediriger selon le rôle
      await _redirectToAppropriatePage(user);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: DonMTheme.erreurDonM,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _redirectToAppropriatePage(User user) async {
    switch (user.role) {
      case UserRole.client:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case UserRole.vendor:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PendingValidationPage(
              role: user.role,
              message: 'Votre compte vendeur est en attente de validation par notre équipe.',
            ),
          ),
        );
        break;
      case UserRole.delivery:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const KYCEvolutionPage(),
          ),
        );
        break;
    }
  }
}
