import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// DonM Theme - Couleurs du logo DonM
class DonMTheme {
  static const Color blancDonM = Color(0xFFFFFFFF);
  static const Color noirDonM = Color(0xFF000000);
  static const Color jauneDonM = Color(0xFFFFB300); // Jaune/orange du logo
  static const Color vertDonM = Color(0xFF2E7D32); // Vert du logo
  static const Color vertFonceDonM = Color(0xFF1B5E20); // Vert foncé du logo
  static const Color jauneClairDonM = Color(0xFFFFF8E1); // Jaune clair
  static const Color grisDonM = Color(0xFF6C757D);
  static const Color grisClairDonM = Color(0xFFF8F9FA);
  static const Color erreurDonM = Color(0xFFDC3545);
  static const Color succesDonM = Color(0xFF28A745);
  static const Color infoDonM = Color(0xFF17A2B8);

  static const LinearGradient gradientPrincipal = LinearGradient(
    colors: [vertFonceDonM, vertDonM], // Vert du logo
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientVert = LinearGradient(
    colors: [vertDonM, vertFonceDonM],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    appBarTheme: const AppBarTheme(
      backgroundColor: blancDonM,
      foregroundColor: noirDonM,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: jauneDonM,
        foregroundColor: blancDonM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

// Pages simples pour la démo
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.vertDonM,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DonMTheme.blancDonM,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '🍛',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DonM',
              style: TextStyle(
                color: DonMTheme.blancDonM,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Livraison de plats à Abidjan',
              style: TextStyle(
                color: DonMTheme.blancDonM,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: DonMTheme.blancDonM,
      ),
      body: const Center(
        child: Text('Page de connexion - En construction'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DonM'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: DonMTheme.blancDonM,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue sur DonM!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DonMTheme.noirDonM,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Application de livraison de plats et courses à Abidjan',
              style: TextStyle(
                fontSize: 16,
                color: DonMTheme.grisDonM,
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(
                  '🍔',
                  'Commander',
                  'Commandez vos plats préférés',
                  DonMTheme.jauneDonM,
                ),
                _buildFeatureCard(
                  '🏪',
                  'Restaurants',
                  'Découvrez nos partenaires',
                  DonMTheme.vertDonM,
                ),
                _buildFeatureCard(
                  '📱',
                  'Suivi',
                  'Suivez vos livraisons',
                  DonMTheme.infoDonM,
                ),
                _buildFeatureCard(
                  '💰',
                  'Paiement',
                  'Mobile Money disponible',
                  DonMTheme.succesDonM,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DonMTheme.noirDonM,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: DonMTheme.grisDonM,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// DonM Theme - Couleurs du logo DonM
class DonMTheme {
  static const Color blancDonM = Color(0xFFFFFFFF);
  static const Color noirDonM = Color(0xFF000000);
  static const Color jauneDonM = Color(0xFFFFB300); // Jaune/orange du logo
  static const Color vertDonM = Color(0xFF2E7D32); // Vert du logo
  static const Color vertFonceDonM = Color(0xFF1B5E20); // Vert foncé du logo
  static const Color jauneClairDonM = Color(0xFFFFF8E1); // Jaune clair
  static const Color grisDonM = Color(0xFF6C757D);
  static const Color grisClairDonM = Color(0xFFF8F9FA);
  static const Color erreurDonM = Color(0xFFDC3545);
  static const Color succesDonM = Color(0xFF28A745);
  static const Color infoDonM = Color(0xFF17A2B8);

  static const LinearGradient gradientPrincipal = LinearGradient(
    colors: [vertFonceDonM, vertDonM], // Vert du logo
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientVert = LinearGradient(
    colors: [vertDonM, vertFonceDonM],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    appBarTheme: const AppBarTheme(
      backgroundColor: blancDonM,
      foregroundColor: noirDonM,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: jauneDonM,
        foregroundColor: blancDonM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}

// DonM Logo Widget
class DonMLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color textColor;

  const DonMLogoWidget({
    super.key,
    this.size = 60,
    this.showText = true,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image not found
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: DonMTheme.gradientPrincipal,
                  borderRadius: BorderRadius.circular(size * 0.25),
                  boxShadow: [
                    BoxShadow(
                      color: DonMTheme.jauneDonM.withOpacity(0.3),
                      blurRadius: size * 0.2,
                      offset: Offset(0, size * 0.1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.white,
                  size: 40,
                ),
              );
            },
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'DonM',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }
}

// Enums
enum UserRole {
  client,
  vendor,
  delivery,
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
}

enum DeliveryLevel {
  beginner,
  experienced,
  expert,
  professional,
}

// Models
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final String? shopName;
  final String? shopAddress;
  final DeliveryLevel? deliveryLevel;
  final String? currentLocation;
  final bool? isAvailable;
  final DateTime memberSince;
  final String kycLevel;
  final double rating;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.shopName,
    this.shopAddress,
    this.deliveryLevel,
    this.currentLocation,
    this.isAvailable,
    required this.memberSince,
    this.kycLevel = 'NONE',
    this.rating = 0.0,
  });

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    UserRole? role,
    UserStatus? status,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      memberSince: this.memberSince,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, role: $role, status: $status)';
  }
}

class Order {
  final String id;
  final String clientId;
  final String pickupAddress;
  final String deliveryAddress;
  final double distance;
  final double price;
  final String status;
  final DateTime createdAt;
  final int? deliveryPersonId;
  final String? trackingCode;

  Order({
    required this.id,
    required this.clientId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.price,
    required this.status,
    required this.createdAt,
    this.deliveryPersonId,
    this.trackingCode,
  });

  @override
  String toString() {
    return 'Order(id: $id, status: $status, price: $price)';
  }
}

class DeliveryPerson {
  final int userId;
  final DeliveryLevel level;
  final String vehicleType;
  final List<String> documents;
  final double rating;
  final bool isAvailable;
  final bool isVerified;
  final List<Order> completedOrders;
  final List<Order> currentOrders;

  DeliveryPerson({
    required this.userId,
    required this.level,
    required this.vehicleType,
    required this.documents,
    required this.rating,
    required this.isAvailable,
    required this.isVerified,
    required this.completedOrders,
    required this.currentOrders,
  });

  DeliveryPerson copyWith({
    int? userId,
    DeliveryLevel? level,
    String? vehicleType,
    List<String>? documents,
    double? rating,
    bool? isAvailable,
    bool? isVerified,
    List<Order>? completedOrders,
    List<Order>? currentOrders,
  }) {
    return DeliveryPerson(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      vehicleType: vehicleType ?? this.vehicleType,
      documents: documents ?? this.documents,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      completedOrders: completedOrders ?? this.completedOrders,
      currentOrders: currentOrders ?? this.currentOrders,
    );
  }

  @override
  String toString() {
    return 'DeliveryPerson(userId: $userId, level: $level, rating: $rating)';
  }
}

class Vendor {
  final int userId;
  final String shopName;
  final String activityType;
  final String location;
  final List<Product> products;
  final List<Order> orders;

  Vendor({
    required this.userId,
    required this.shopName,
    required this.activityType,
    required this.location,
    required this.products,
    required this.orders,
  });

  @override
  String toString() {
    return 'Vendor(userId: $userId, shopName: $shopName)';
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  bool isAvailable;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.images,
  });

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }
}

// Main App
// Services globaux
late OrderServiceSimple orderService;
late DatabaseService databaseService;

void main() {
  // Initialiser les services
  orderService = OrderServiceSimple();
  databaseService = DatabaseService();
  
  // Initialiser les données
  orderService.initialize();
  
  runApp(const DonMApp());
}

class DonMApp extends StatelessWidget {
  const DonMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonM - Livraison Rapide',
      debugShowCheckedModeBanner: false,
      theme: DonMTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}

// Splash Page
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.jauneClairDonM,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: DonMLogoWidget(
                size: 100,
                showText: true,
                textColor: DonMTheme.noirDonM,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Importer la LoginPage fonctionnelle depuis auth_pages.dart

// Register Page (remplacée par la version dans auth_pages.dart)
// La nouvelle RegisterPage est importée depuis pages/auth_pages.dart
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
          });
        }
      });
    }
  }

  void _verifyOTP() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: const Text(
          'Inscription',
          style: TextStyle(
            color: DonMTheme.noirDonM,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                DonMLogoWidget(
                  size: 80,
                  showText: true,
                ),
                
                const SizedBox(height: 40),
                
                const Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: DonMTheme.noirDonM,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Rejoignez DonM',
                  style: TextStyle(
                    fontSize: 16,
                    color: DonMTheme.grisDonM,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                if (!_otpSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Numéro requis';
                      }
                      if (value.length < 8) {
                        return 'Numéro invalide';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Code OTP',
                      prefixIcon: const Icon(Icons.sms),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Code OTP requis';
                      }
                      if (value.length != 6) {
                        return 'Code OTP invalide';
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.jauneDonM,
                    foregroundColor: DonMTheme.blancDonM,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _otpSent ? 'Vérifier' : 'Envoyer OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Déjà un compte? Se connecter',
                    style: TextStyle(
                      color: DonMTheme.jauneDonM,
                      fontWeight: FontWeight.w600,
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

// Role Selection Page
class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;

  void _navigateToRole(BuildContext context, UserRole role) {
    final authService = AuthServiceSimple();
    
    // Pour le flux DonM : si non connecté, rediriger vers l'inscription
    if (!authService.isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
      return;
    }

    // Vérifier si l'utilisateur peut accéder à ce rôle
    if (!authService.canAccessRole(role)) {
      _showAccessDeniedDialog(context, role);
      return;
    }

    // Rediriger vers la page appropriée
    _navigateToRolePage(context, role);
  }

  void _createDemoUserAndNavigate(BuildContext context, UserRole role) async {
    final authService = AuthServiceSimple();
    
    // Créer un utilisateur de démonstration selon le rôle sélectionné
    String email, name, phone;
    switch (role) {
      case UserRole.client:
        email = 'client@demo.com';
        name = 'Client Demo';
        phone = '0101010101';
        break;
      case UserRole.vendor:
        email = 'vendor@demo.com';
        name = 'Vendor Demo';
        phone = '0202020202';
        break;
      case UserRole.delivery:
        email = 'delivery@demo.com';
        name = 'Delivery Demo';
        phone = '0303030303';
        break;
    }

    try {
      // Créer l'utilisateur de démonstration
      final user = await authService.register(
        name: name,
        email: email,
        phone: phone,
        password: 'demo123',
        role: role,
      );

      // Connecter l'utilisateur
      await authService.login(email: email, password: 'demo123');

      // Naviguer vers la page appropriée
      if (mounted) {
        _navigateToRolePage(context, role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: DonMTheme.erreurDonM,
          ),
        );
      }
    }
  }

  void _navigateToRolePage(BuildContext context, UserRole role) {
    // Utiliser une page de test simple pour diagnostiquer le problème
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => TestPage(role: role)),
    );
  }

void _showAccessDeniedDialog(BuildContext context, UserRole role) {
    final authService = AuthServiceSimple();
    String message = '';
    String action = '';

    if (authService.isPendingValidation()) {
      message = 'Votre compte est en attente de validation.';
      action = 'Veuillez patienter pendant que notre équipe valide votre compte.';
    } else if (authService.needsKyc()) {
      message = 'Vous devez compléter le processus KYC.';
      action = 'Veuillez terminer la vérification d\'identité pour accéder à ce rôle.';
    } else {
      message = 'Vous n\'êtes pas autorisé à accéder à ce rôle.';
      action = 'Veuillez vous connecter avec le compte approprié.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accès refusé - ${role.toString().split('.').last}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 8),
            Text(
              action,
              style: TextStyle(
                fontSize: 14,
                color: DonMTheme.grisDonM,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (authService.needsKyc())
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const KYCEvolutionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DonMTheme.vertDonM,
                foregroundColor: DonMTheme.blancDonM,
              ),
              child: const Text('Compléter KYC'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.jauneClairDonM,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const DonMLogoWidget(size: 80),
              const SizedBox(height: 20),
              Text(
                'Choisissez votre rôle',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DonMTheme.vertFonceDonM,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comment souhaitez-vous utiliser DonM?',
                style: TextStyle(
                  fontSize: 16,
                  color: DonMTheme.grisDonM,
                ),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRoleCard(
                        icon: Icons.person,
                        title: 'CLIENT',
                        description: 'Commander des livraisons\nSuivre vos commandes en temps réel',
                        color: DonMTheme.jauneDonM,
                        isSelected: false,
                        onTap: () {
                          _navigateToRole(context, UserRole.client);
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildRoleCard(
                        icon: Icons.store,
                        title: 'VENDEUR',
                        description: 'Gérer votre boutique\nRecevoir des commandes clients',
                        color: DonMTheme.vertDonM,
                        isSelected: false,
                        onTap: () {
                          _navigateToRole(context, UserRole.vendor);
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildRoleCard(
                        icon: Icons.motorcycle,
                        title: 'LIVREUR',
                        description: 'Livrer pour DonM\nGagner de l\'argent',
                        color: DonMTheme.vertFonceDonM,
                        isSelected: false,
                        onTap: () {
                          _navigateToRole(context, UserRole.delivery);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Text(
                  'Continuer en tant que client',
                  style: TextStyle(
                    color: DonMTheme.grisDonM,
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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white.withOpacity(0.9) : DonMTheme.grisDonM,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Page (Client)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  UserRole _currentRole = UserRole.client;
  
  final List<Widget> _pages = [
    const HomeTab(),
    const OrdersTab(),
    const ProfileTab(),
  ];

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'Client';
      case UserRole.vendor:
        return 'Vendeur';
      case UserRole.delivery:
        return 'Livreur';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.grisClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'DonM - ${_getRoleName(_currentRole)}',
              style: const TextStyle(
                color: DonMTheme.noirDonM,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: DonMTheme.vertDonM),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                );
              },
              tooltip: 'Changer de rôle',
            ),
          ],
        ),
      ),
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
          selectedItemColor: DonMTheme.jauneDonM,
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
      floatingActionButton: null,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: DonMTheme.gradientPrincipal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                  const Text(
                    'DonM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Livraison rapide et fiable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: DonMTheme.jauneDonM.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: DonMTheme.jauneDonM,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vos livraisons',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Ce mois-ci'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('24', 'Total', DonMTheme.jauneDonM),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem('12', 'Ce mois', DonMTheme.vertDonM),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem('5.2k', 'Économies', DonMTheme.vertFonceDonM),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton de commande principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const OrderFormPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.jauneDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Commander une livraison',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bouton de test de base de données
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const DatabaseTestPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DonMTheme.vertDonM,
                    side: const BorderSide(color: DonMTheme.vertDonM),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tester la base de données',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nos services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildServiceCard(Icons.local_shipping, 'Livraison', 'Rapide et fiable', DonMTheme.jauneDonM),
                      _buildServiceCard(Icons.store, 'Marchandises', 'Tous types', DonMTheme.vertDonM),
                      _buildServiceCard(Icons.motorcycle, 'Course', 'Express', DonMTheme.vertFonceDonM),
                      _buildServiceCard(Icons.inventory_2, 'Colis', 'Sécurisé', DonMTheme.jauneClairDonM),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatItem(String value, String label, Color color) {
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DonMTheme.grisDonM,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildServiceCard(IconData icon, String title, String subtitle, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to service
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
}

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'Toutes';
  UserRole _currentRole = UserRole.client; // Sera dynamique selon l'utilisateur

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer l'utilisateur connecté
      final authService = AuthServiceSimple();
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        _currentRole = currentUser.role;
        
        // Charger les commandes depuis l'API selon le rôle
        List<Order> orders = [];
        switch (_currentRole) {
          case UserRole.client:
            // Pour le client, montrer ses commandes
            orders = await ApiService.getOrders(clientId: currentUser.id);
            break;
          case UserRole.vendor:
            // Pour le vendeur, montrer toutes les commandes
            orders = await ApiService.getOrders();
            break;
          case UserRole.delivery:
            // Pour le livreur, montrer les commandes qui lui sont assignées
            orders = await ApiService.getOrders(deliveryPersonId: currentUser.id);
            break;
        }
        
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: DonMTheme.erreurDonM,
        ),
      );
    }
  }

  String _getUserIdForRole() {
    // IDs simulés pour la démo
    switch (_currentRole) {
      case UserRole.client:
        return '1';
      case UserRole.vendor:
        return '2';
      case UserRole.delivery:
        return '3';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes Commandes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadOrders,
                  tooltip: 'Actualiser',
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Toutes', []),
                  const SizedBox(width: 8),
                  _buildFilterChip('En attente', ['pending']),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmées', ['confirmed']),
                  const SizedBox(width: 8),
                  _buildFilterChip('En préparation', ['preparing']),
                  const SizedBox(width: 8),
                  _buildFilterChip('Prêtes', ['ready']),
                  const SizedBox(width: 8),
                  _buildFilterChip('En livraison', ['in_transit']),
                  const SizedBox(width: 8),
                  _buildFilterChip('Livrées', ['delivered']),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contenu
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: DonMTheme.vertDonM,
                ),
              )
            else if (_filteredOrders.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: DonMTheme.grisDonM,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune commande',
                      style: TextStyle(
                        fontSize: 18,
                        color: DonMTheme.grisDonM,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous n\'avez aucune commande pour le moment',
                      style: TextStyle(
                        fontSize: 14,
                        color: DonMTheme.grisDonM,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Order> get _filteredOrders {
    if (_selectedFilter == 'Toutes') return _orders;
    
    final Map<String, List<String>> filterOptions = {
      'Toutes': [],
      'En attente': ['pending'],
      'Confirmées': ['confirmed'],
      'En préparation': ['preparing'],
      'Prêtes': ['ready'],
      'En livraison': ['in_transit'],
      'Livrées': ['delivered'],
    };
    
    final targetStatus = filterOptions[_selectedFilter];
    if (targetStatus == null) return _orders;
    
    return _orders.where((order) => targetStatus.contains(order.status)).toList();
  }

  Widget _buildFilterChip(String label, List<String> statuses) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (value) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: DonMTheme.grisClairDonM,
      selectedColor: DonMTheme.jauneDonM.withOpacity(0.2),
      checkmarkColor: DonMTheme.jauneDonM,
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor = _getStatusColor(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DonMTheme.grisClairDonM!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DonMTheme.noirDonM.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DonMTheme.noirDonM,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusDisplayName(order.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(order.createdAt),
            style: const TextStyle(
              fontSize: 14,
              color: DonMTheme.grisDonM,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commande simple - ${order.price.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontSize: 14,
              color: DonMTheme.noirDonM,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.price.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DonMTheme.vertDonM,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showOrderDetails(order),
                    child: const Text('Détails'),
                  ),
                  const SizedBox(width: 8),
                  if (_canTrackOrder(order))
                    ElevatedButton(
                      onPressed: () => _trackOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DonMTheme.vertDonM,
                        foregroundColor: DonMTheme.blancDonM,
                      ),
                      child: const Text('Suivre'),
                    ),
                  if (_canCancelOrder(order))
                    const SizedBox(width: 8),
                  if (_canCancelOrder(order))
                    OutlinedButton(
                      onPressed: () => _cancelOrder(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DonMTheme.erreurDonM,
                        side: const BorderSide(color: DonMTheme.erreurDonM),
                      ),
                      child: const Text('Annuler'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return DonMTheme.jauneDonM;
      case 'confirmed':
        return DonMTheme.vertDonM;
      case 'preparing':
        return DonMTheme.infoDonM;
      case 'ready':
        return DonMTheme.vertFonceDonM;
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return DonMTheme.succesDonM;
      case 'cancelled':
        return DonMTheme.erreurDonM;
      default:
        return DonMTheme.grisDonM;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
        return 'Prête';
      case 'in_transit':
        return 'En livraison';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _canTrackOrder(Order order) {
    // Pour la démo, tous les vendeurs peuvent suivre les commandes
    return order.status == 'confirmed' || 
           order.status == 'preparing' || 
           order.status == 'ready' || 
           order.status == 'in_transit';
  }

  bool _canCancelOrder(Order order) {
    return order.status == 'pending' || 
           order.status == 'confirmed';
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la commande ${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Statut: ${_getStatusDisplayName(order.status)}'),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(order.createdAt)}'),
              const SizedBox(height: 8),
              Text('Adresse de livraison: ${order.deliveryAddress}'),
              const SizedBox(height: 8),
              Text('Adresse de retrait: ${order.pickupAddress}'),
              const SizedBox(height: 16),
              const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  - Commande simple (démo)'),
              const SizedBox(height: 8),
              Text('Prix: ${order.price.toStringAsFixed(0)} FCFA'),
              Text('Distance: ${order.distance.toStringAsFixed(1)} km'),
              Text('Total: ${order.price.toStringAsFixed(0)} FCFA', 
                   style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _trackOrder(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suivi de la commande ${order.id} - ${_getStatusDisplayName(order.status)}'),
        backgroundColor: DonMTheme.infoDonM,
      ),
    );
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: Text('Êtes-vous sûr de vouloir annuler la commande ${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await orderService.cancelOrder(order.id, _getUserIdForRole());
                _loadOrders(); // Recharger les commandes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Commande annulée avec succès'),
                    backgroundColor: DonMTheme.succesDonM,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: DonMTheme.erreurDonM,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.erreurDonM,
              foregroundColor: DonMTheme.blancDonM,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}


// Vendor Dashboard
class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const VendorHomeTab(),
    const OrdersTab(),
    const ProductsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'DonM - Vendeur',
              style: const TextStyle(
                color: DonMTheme.noirDonM,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: DonMTheme.vertDonM),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                );
              },
              tooltip: 'Changer de rôle',
            ),
          ],
        ),
      ),
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
          selectedItemColor: DonMTheme.vertDonM,
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
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Produits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthServiceSimple _authService = AuthServiceSimple();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      // Si non connecté, afficher un bouton de connexion
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DonMLogoWidget(size: 80),
              const SizedBox(height: 20),
              const Text(
                'Vous n\'êtes pas connecté',
                style: TextStyle(
                  fontSize: 18,
                  color: DonMTheme.grisDonM,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DonMTheme.vertDonM,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: DonMTheme.gradientPrincipal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      _currentUser!.name.split(' ').map((e) => e[0]).join(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DonMTheme.vertDonM,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _currentUser!.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleDisplayName(_currentUser!.role),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Informations personnelles
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DonMTheme.vertFonceDonM,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileRow(Icons.phone, 'Téléphone', _currentUser!.phone),
                    _buildProfileRow(Icons.email, 'Email', _currentUser!.email),
                    _buildProfileRow(Icons.calendar_today, 'Membre depuis', 
                        '${_currentUser!.memberSince.day}/${_currentUser!.memberSince.month}/${_currentUser!.memberSince.year}'),
                    if (_currentUser!.role == UserRole.delivery) ...[
                      _buildProfileRow(Icons.star, 'Niveau KYC', _currentUser!.kycLevel),
                      _buildProfileRow(Icons.grade, 'Note', '${_currentUser!.rating.toStringAsFixed(1)}/5'),
                    ],
                    if (_currentUser!.role == UserRole.vendor && _currentUser!.shopName != null)
                      _buildProfileRow(Icons.store, 'Boutique', _currentUser!.shopName!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: DonMTheme.vertDonM),
                      title: const Text('Modifier le profil'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings, color: DonMTheme.vertDonM),
                      title: const Text('Paramètres'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: DonMTheme.erreurDonM),
                      title: const Text('Déconnexion'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _authService.logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: DonMTheme.grisDonM, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: DonMTheme.grisDonM,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DonMTheme.noirDonM,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'Client';
      case UserRole.vendor:
        return 'Vendeur';
      case UserRole.delivery:
        return 'Livreur';
    }
  }
}

class VendorHomeTab extends StatelessWidget {
  const VendorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: DonMTheme.gradientVert,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                  const Text(
                    'Tableau de bord',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gérez votre boutique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '12',
                    'Commandes aujourd\'hui',
                    Icons.list_alt,
                    DonMTheme.vertDonM,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '85,000',
                    'FCFA de revenus',
                    Icons.attach_money,
                    DonMTheme.vertFonceDonM,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Quick Actions
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                  'Ajouter produit',
                  Icons.inventory_2_outlined,
                  DonMTheme.vertDonM,
                ),
                _buildActionCard(
                  'Voir livraisons',
                  Icons.list_alt_outlined,
                  DonMTheme.vertFonceDonM,
                ),
                _buildActionCard(
                  'Statistiques',
                  Icons.bar_chart_outlined,
                  DonMTheme.jauneDonM,
                ),
                _buildActionCard(
                  'Paramètres',
                  Icons.settings_outlined,
                  DonMTheme.grisDonM,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Recent Orders
            const Text(
              'Commandes récentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildOrderCard(
                  'CMD-00${index + 1}',
                  'En attente',
                  '2,500 FCFA',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DonMTheme.grisDonM,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DonMTheme.grisClairDonM!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DonMTheme.noirDonM.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: color, size: 28),
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
        ],
      ),
    );
  }

  Widget _buildOrderCard(String orderNumber, String status, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DonMTheme.grisClairDonM!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DonMTheme.vertDonM.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: DonMTheme.vertDonM,
              size: 20,
            ),
          ),
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
                    color: DonMTheme.noirDonM,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DonMTheme.grisDonM,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DonMTheme.vertDonM,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Récupérer l'utilisateur connecté pour filtrer les produits
      final authService = AuthServiceSimple();
      final currentUser = authService.currentUser;
      
      List<Product> products = [];
      
      if (currentUser != null && currentUser.role == UserRole.vendor) {
        // Si vendeur, charger seulement ses produits
        products = await ApiService.getProducts(vendorId: currentUser.id);
      } else {
        // Sinon, charger tous les produits disponibles
        products = await ApiService.getProducts(available: true);
      }
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: DonMTheme.erreurDonM,
          ),
        );
      }
    }
  }

  void _toggleProductAvailability(Product product) async {
    try {
      // Mettre à jour le produit via l'API
      Product updatedProduct = await ApiService.updateProduct(
        id: product.id,
        name: product.name,
        description: product.description,
        shortDescription: product.description,
        price: product.price,
        category: product.category,
        images: product.images,
        isAvailable: !product.isAvailable,
      );
      
      // Mettre à jour l'état local
      setState(() {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedProduct.isAvailable 
                ? '${updatedProduct.name} est maintenant disponible'
                : '${updatedProduct.name} n\'est plus disponible',
          ),
          backgroundColor: updatedProduct.isAvailable ? DonMTheme.succesDonM : DonMTheme.erreurDonM,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: DonMTheme.erreurDonM,
        ),
      );
    }
  }

  void _editProduct(Product product) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditProductPage(product: product)),
    );
    
    if (result == true) {
      // Recharger la liste des produits depuis la base de données
      setState(() {
        _products.clear();
        _products.addAll(databaseService.getAllProducts());
      });
    }
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _products.remove(product);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} a été supprimé'),
                  backgroundColor: DonMTheme.succesDonM,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.erreurDonM,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _addProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddProductPage()),
    );
    
    if (result == true) {
      // Recharger la liste des produits depuis la base de données
      setState(() {
        _products.clear();
        _products.addAll(databaseService.getAllProducts());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DonMTheme.blancDonM,
              boxShadow: [
                BoxShadow(
                  color: DonMTheme.noirDonM.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: const Icon(Icons.search, color: DonMTheme.grisDonM),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: DonMTheme.grisClairDonM!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: DonMTheme.vertDonM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.vertDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: DonMTheme.grisClairDonM,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('${_products.length}', 'Total', Icons.inventory_2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '${_products.where((p) => p.isAvailable).length}',
                    'Disponibles',
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '${_products.where((p) => !p.isAvailable).length}',
                    'Indisponibles',
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(DonMTheme.vertDonM),
                    ),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 64,
                              color: DonMTheme.grisDonM,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun produit disponible',
                              style: TextStyle(
                                fontSize: 18,
                                color: DonMTheme.grisDonM,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajoutez votre premier produit pour commencer',
                              style: TextStyle(
                                fontSize: 14,
                                color: DonMTheme.grisDonM,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DonMTheme.grisClairDonM!),
      ),
      child: Column(
        children: [
          Icon(icon, color: DonMTheme.vertDonM, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DonMTheme.vertFonceDonM,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DonMTheme.grisDonM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: DonMTheme.grisClairDonM,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: DonMTheme.vertDonM,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.noirDonM,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DonMTheme.grisDonM,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DonMTheme.vertDonM,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DonMTheme.vertFonceDonM,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isAvailable ? DonMTheme.succesDonM : DonMTheme.erreurDonM,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.isAvailable ? 'Disponible' : 'Indisponible',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleProductAvailability(product),
                    icon: Icon(
                      product.isAvailable ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(
                      product.isAvailable ? 'Masquer' : 'Afficher',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.isAvailable ? DonMTheme.grisDonM : DonMTheme.vertDonM,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editProduct(product),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifier', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DonMTheme.jauneDonM,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteProduct(product),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Supprimer', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DonMTheme.erreurDonM,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Page d'ajout de produit
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  
  List<String> _selectedImages = [];
  bool _isAvailable = true;
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Plats chauds',
    'Petit-déjeuner',
    'Accompagnements',
    'Sauces',
    'Boissons',
    'Desserts',
    'Snacks',
    'Autre'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _pickImage() {
    // Simulation de sélection d'image
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une image'),
        content: const Text('Choisissez une source d\'image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addMockImage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.vertDonM,
              foregroundColor: Colors.white,
            ),
            child: const Text('Galerie'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addMockImage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.jauneDonM,
              foregroundColor: Colors.white,
            ),
            child: const Text('Appareil photo'),
          ),
        ],
      ),
    );
  }

  void _addMockImage() {
    setState(() {
      _selectedImages.add('assets/images/product_${_selectedImages.length + 1}.jpg');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image ajoutée avec succès'),
        backgroundColor: DonMTheme.succesDonM,
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulation de sauvegarde
      await Future.delayed(const Duration(seconds: 2));

      final newProduct = Product(
        id: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        isAvailable: _isAvailable,
        images: _selectedImages.isNotEmpty ? _selectedImages : ['assets/images/default_product.jpg'],
      );

      // Ajouter à la base de données
      databaseService.createProduct(newProduct);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit "${newProduct.name}" ajouté avec succès!'),
          backgroundColor: DonMTheme.succesDonM,
        ),
      );

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.grisClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
        title: const Text('Ajouter un produit'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Images du produit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImages.isEmpty)
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: DonMTheme.grisClairDonM,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DonMTheme.grisDonM,
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: DonMTheme.grisDonM,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucune image',
                                style: TextStyle(
                                  color: DonMTheme.grisDonM,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: DonMTheme.grisClairDonM,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: DonMTheme.grisDonM,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      color: DonMTheme.vertDonM,
                                      size: 40,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: DonMTheme.erreurDonM,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Ajouter une image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DonMTheme.jauneDonM,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nom du produit
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nom du produit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Entrez le nom du produit',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Veuillez entrer le nom du produit';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Décrivez votre produit',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Prix et Catégorie
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prix (FCFA)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DonMTheme.vertFonceDonM,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Obligatoire';
                                }
                                if (double.tryParse(value!) == null) {
                                  return 'Prix invalide';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catégorie',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DonMTheme.vertFonceDonM,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _categoryController.text.isEmpty ? null : _categoryController.text,
                              decoration: const InputDecoration(
                                hintText: 'Choisir',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _categoryController.text = value ?? '';
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Obligatoire';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Disponibilité
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Produit disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                        activeColor: DonMTheme.vertDonM,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.vertDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Enregistrement...'),
                          ],
                        )
                      : const Text(
                          'Ajouter le produit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// Page de modification de produit
class EditProductPage extends StatefulWidget {
  final Product product;
  
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  
  List<String> _selectedImages = [];
  bool _isAvailable = true;
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Plats chauds',
    'Petit-déjeuner',
    'Accompagnements',
    'Sauces',
    'Boissons',
    'Desserts',
    'Snacks',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(0));
    _categoryController = TextEditingController(text: widget.product.category);
    _selectedImages = List.from(widget.product.images);
    _isAvailable = widget.product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une image'),
        content: const Text('Choisissez une source d\'image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addMockImage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.vertDonM,
              foregroundColor: Colors.white,
            ),
            child: const Text('Galerie'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addMockImage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.jauneDonM,
              foregroundColor: Colors.white,
            ),
            child: const Text('Appareil photo'),
          ),
        ],
      ),
    );
  }

  void _addMockImage() {
    setState(() {
      _selectedImages.add('assets/images/product_${_selectedImages.length + 1}.jpg');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image ajoutée avec succès'),
        backgroundColor: DonMTheme.succesDonM,
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulation de mise à jour
      await Future.delayed(const Duration(seconds: 2));

      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        isAvailable: _isAvailable,
        images: _selectedImages.isNotEmpty ? _selectedImages : ['assets/images/default_product.jpg'],
      );

      // Mettre à jour dans la base de données
      databaseService.updateProduct(updatedProduct);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit "${updatedProduct.name}" mis à jour avec succès!'),
          backgroundColor: DonMTheme.succesDonM,
        ),
      );

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.grisClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
        title: const Text('Modifier le produit'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Images du produit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImages.isEmpty)
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: DonMTheme.grisClairDonM,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DonMTheme.grisDonM,
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: DonMTheme.grisDonM,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucune image',
                                style: TextStyle(
                                  color: DonMTheme.grisDonM,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: DonMTheme.grisClairDonM,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: DonMTheme.grisDonM,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      color: DonMTheme.vertDonM,
                                      size: 40,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: DonMTheme.erreurDonM,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Ajouter une image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DonMTheme.jauneDonM,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nom du produit
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nom du produit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Entrez le nom du produit',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Veuillez entrer le nom du produit';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Décrivez votre produit',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Prix et Catégorie
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prix (FCFA)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DonMTheme.vertFonceDonM,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Obligatoire';
                                }
                                if (double.tryParse(value!) == null) {
                                  return 'Prix invalide';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catégorie',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DonMTheme.vertFonceDonM,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _categoryController.text.isEmpty ? null : _categoryController.text,
                              decoration: const InputDecoration(
                                hintText: 'Choisir',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _categoryController.text = value ?? '';
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Obligatoire';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Disponibilité
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Produit disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                        activeColor: DonMTheme.vertDonM,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.vertDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Mise à jour...'),
                          ],
                        )
                      : const Text(
                          'Mettre à jour le produit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// Delivery Dashboard
class DeliveryDashboardPage extends StatefulWidget {
  const DeliveryDashboardPage({super.key});

  @override
  State<DeliveryDashboardPage> createState() => _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends State<DeliveryDashboardPage> {
  int _currentIndex = 0;
  bool _isAvailable = true;
  
  final List<Widget> _pages = [
    const DeliveryHomeTab(),
    const OrdersTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'DonM - Livreur',
              style: const TextStyle(
                color: DonMTheme.noirDonM,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: DonMTheme.vertDonM),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                );
              },
              tooltip: 'Changer de rôle',
            ),
          ],
        ),
      ),
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
          selectedItemColor: DonMTheme.vertFonceDonM,
          unselectedItemColor: DonMTheme.grisDonM,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'Missions',
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
                setState(() {
                  _isAvailable = !_isAvailable;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isAvailable ? 'Vous êtes maintenant disponible' : 'Vous êtes maintenant indisponible'),
                    backgroundColor: _isAvailable ? DonMTheme.vertDonM : DonMTheme.erreurDonM,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: _isAvailable ? DonMTheme.vertDonM : DonMTheme.erreurDonM,
              foregroundColor: DonMTheme.blancDonM,
              icon: Icon(_isAvailable ? Icons.power_settings_new : Icons.power_off),
              label: Text(_isAvailable ? 'Disponible' : 'Indisponible'),
            )
          : null,
    );
  }
}

class DeliveryHomeTab extends StatelessWidget {
  const DeliveryHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: DonMTheme.gradientVert,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                  const Text(
                    'Espace Livreur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gagnez de l\'argent avec DonM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DonMTheme.blancDonM,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DonMTheme.vertFonceDonM.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DonMTheme.noirDonM.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: DonMTheme.vertDonM,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Statut: Disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'En attente de missions...',
                    style: TextStyle(
                      fontSize: 14,
                      color: DonMTheme.grisDonM,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('15', 'Missions ce mois', Icons.local_shipping, DonMTheme.vertDonM),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('4.8', 'Note moyenne', Icons.star, DonMTheme.jauneDonM),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Quick Actions
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                  'Voir la carte',
                  Icons.map_outlined,
                  DonMTheme.vertDonM,
                ),
                _buildActionCard(
                  'Historique',
                  Icons.history_outlined,
                  DonMTheme.vertFonceDonM,
                ),
                _buildActionCard(
                  'Revenus',
                  Icons.attach_money_outlined,
                  DonMTheme.jauneDonM,
                ),
                _buildActionCard(
                  'Support',
                  Icons.support_agent_outlined,
                  DonMTheme.grisDonM,
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DonMTheme.grisDonM,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DonMTheme.blancDonM,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DonMTheme.grisClairDonM!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DonMTheme.noirDonM.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: color, size: 28),
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
        ],
      ),
    );
  }
}

// KYC Evolution Page
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
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                                ),
                              ),
                              Text(
                                _getLevelTitle(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getLevelDescription(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
                          DonMTheme.jauneDonM,
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
                  ? DonMTheme.jauneDonM 
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
                      ? DonMTheme.jauneDonM 
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DonMTheme.noirDonM,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DonMTheme.grisDonM,
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
                color: DonMTheme.jauneDonM,
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
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: DonMTheme.grisDonM,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirection vers la certification...'),
        backgroundColor: DonMTheme.vertDonM,
      ),
    );
  }

  void _upgradeToPremium() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirection vers l\'offre premium...'),
        backgroundColor: DonMTheme.jauneDonM,
      ),
    );
  }

  void _addInsurance() {
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

// Page de formulaire de commande DonM
class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _packageTypeController = TextEditingController();
  
  bool _isCalculating = false;
  double? _distance;
  double? _price;
  String? _selectedPackageType;
  
  final List<String> _packageTypes = [
    'Document',
    'Colis petit (< 2kg)',
    'Colis moyen (2-5kg)',
    'Colis gros (> 5kg)',
    'Nourriture',
    'Médicaments',
    'Autre'
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _packageTypeController.dispose();
    super.dispose();
  }

  void _calculateDistanceAndPrice() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isCalculating = true;
      });

      // Simulation de calcul de distance (en km)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          final random = Random();
          final calculatedDistance = 3.0 + random.nextDouble() * 12.0; // 3-15 km
          final calculatedPrice = 500 + (calculatedDistance * 25); // 500 FCFA fixe + 25 FCFA/km
          
          setState(() {
            _distance = calculatedDistance;
            _price = calculatedPrice;
            _isCalculating = false;
          });
        }
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_distance == null || _price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez calculer la distance et le prix d\'abord'),
            backgroundColor: DonMTheme.erreurDonM,
          ),
        );
        return;
      }

      // Récupérer l'utilisateur connecté
      final authService = AuthServiceSimple();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: utilisateur non connecté'),
            backgroundColor: DonMTheme.erreurDonM,
          ),
        );
        return;
      }

      // Créer la commande via l'API
      final order = await ApiService.createOrder(
        clientId: currentUser.id,
        pickupAddress: _pickupController.text,
        deliveryAddress: _deliveryController.text,
        distance: _distance!,
        basePrice: _price! - 500, // Prix de base sans frais de livraison
        deliveryFee: 500, // Frais de livraison fixes
        totalAmount: _price!,
        pickupInstructions: _pickupInstructionsController.text.isNotEmpty 
            ? _pickupInstructionsController.text 
            : null,
        deliveryInstructions: _deliveryInstructionsController.text.isNotEmpty 
            ? _deliveryInstructionsController.text 
            : null,
      );

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Commande créée avec succès ! Code de suivi: ${order.trackingCode}'),
          backgroundColor: DonMTheme.vertDonM,
        ),
      );

      // Naviguer vers la page de suivi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OrderTrackingPage(order: order)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.grisClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
        title: const Text('Commander une livraison'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Point de départ
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Point de départ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pickupController,
                        decoration: const InputDecoration(
                          hintText: 'Entrez l\'adresse de départ',
                          prefixIcon: Icon(Icons.location_on, color: DonMTheme.vertDonM),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Veuillez entrer l\'adresse de départ';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Point d'arrivée
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Point d\'arrivée',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _deliveryController,
                        decoration: const InputDecoration(
                          hintText: 'Entrez l\'adresse de destination',
                          prefixIcon: Icon(Icons.flag, color: DonMTheme.vertDonM),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Veuillez entrer l\'adresse de destination';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Type de colis
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Type de colis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPackageType,
                        decoration: const InputDecoration(
                          hintText: 'Sélectionnez le type de colis',
                          prefixIcon: Icon(Icons.inventory_2, color: DonMTheme.vertDonM),
                          border: OutlineInputBorder(),
                        ),
                        items: _packageTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedPackageType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner le type de colis';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de calcul
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCalculating ? null : _calculateDistanceAndPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.jauneDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCalculating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Calcul en cours...'),
                          ],
                        )
                      : const Text(
                          'Calculer distance et prix',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              // Résultats du calcul
              if (_distance != null && _price != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: DonMTheme.vertDonM.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Distance estimée:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${_distance!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DonMTheme.vertFonceDonM,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Prix total:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${_price!.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: DonMTheme.vertDonM,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '(500 FCFA base + 25 FCFA/km)',
                          style: TextStyle(
                            fontSize: 12,
                            color: DonMTheme.grisDonM,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Bouton de validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.vertDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Valider la commande',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// Page de suivi de commande
class OrderTrackingPage extends StatefulWidget {
  final Order order;
  
  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late Order _currentOrder;
  Timer? _trackingTimer;
  int? _deliveryPersonId;
  String _deliveryPersonName = 'En recherche...';
  String _deliveryPersonPhone = '';
  double _deliveryProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _startTrackingSimulation();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _startTrackingSimulation() {
    // Simulation de recherche de livreur
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _deliveryPersonId = 100 + Random().nextInt(50);
          _deliveryPersonName = 'Kouadio Jean';
          _deliveryPersonPhone = '+225 07 89 45 12 34';
        });
        
        // Simulation de progression de la livraison
        _simulateDeliveryProgress();
      }
    });
  }

  void _simulateDeliveryProgress() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _deliveryProgress < 1.0) {
        setState(() {
          _deliveryProgress += 0.1;
          if (_deliveryProgress >= 1.0) {
            _deliveryProgress = 1.0;
            _currentOrder = _currentOrder.copyWith(status: 'delivered');
            timer.cancel();
          }
        });
      }
    });
  }

  void _contactDeliveryPerson() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel de $_deliveryPersonName...'),
        backgroundColor: DonMTheme.infoDonM,
      ),
    );
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette commande?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DonMTheme.erreurDonM,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.grisClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
        title: const Text('Suivi de livraison'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de la commande
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DonMTheme.vertDonM.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: DonMTheme.vertDonM,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commande #${_currentOrder.id}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: DonMTheme.vertFonceDonM,
                                ),
                              ),
                              Text(
                                'Code: ${_currentOrder.trackingCode}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: DonMTheme.grisDonM,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_currentOrder.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusDisplayName(_currentOrder.status),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Prix total:'),
                        Text(
                          '${_currentOrder.price.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: DonMTheme.vertDonM,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Adresses
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails de la livraison',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DonMTheme.vertFonceDonM,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAddressRow(
                      Icons.location_on,
                      'Départ',
                      _currentOrder.pickupAddress,
                      DonMTheme.jauneDonM,
                    ),
                    const SizedBox(height: 12),
                    _buildAddressRow(
                      Icons.flag,
                      'Destination',
                      _currentOrder.deliveryAddress,
                      DonMTheme.vertDonM,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.straighten, color: DonMTheme.grisDonM, size: 20),
                        const SizedBox(width: 8),
                        const Text('Distance:'),
                        const Spacer(),
                        Text(
                          '${_currentOrder.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DonMTheme.vertFonceDonM,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Livreur
            if (_deliveryPersonId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Votre livreur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: DonMTheme.vertDonM,
                            child: Text(
                              _deliveryPersonName.split(' ').map((e) => e[0]).join(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _deliveryPersonName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _deliveryPersonPhone,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: DonMTheme.grisDonM,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _contactDeliveryPerson,
                            icon: const Icon(Icons.phone, color: DonMTheme.vertDonM),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Progression de la livraison
            if (_deliveryPersonId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progression de la livraison',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DonMTheme.vertFonceDonM,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _deliveryProgress,
                        backgroundColor: DonMTheme.grisClairDonM,
                        valueColor: const AlwaysStoppedAnimation<Color>(DonMTheme.vertDonM),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_deliveryProgress * 100).toInt()}% terminé',
                        style: const TextStyle(
                          fontSize: 14,
                          color: DonMTheme.grisDonM,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Actions
            if (_currentOrder.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonMTheme.erreurDonM,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Annuler la commande',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: DonMTheme.grisDonM,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return DonMTheme.jauneDonM;
      case 'confirmed':
        return DonMTheme.infoDonM;
      case 'preparing':
        return DonMTheme.vertDonM;
      case 'ready':
        return DonMTheme.vertDonM;
      case 'in_transit':
        return DonMTheme.vertFonceDonM;
      case 'delivered':
        return DonMTheme.succesDonM;
      case 'cancelled':
        return DonMTheme.erreurDonM;
      default:
        return DonMTheme.grisDonM;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
        return 'Prête';
      case 'in_transit':
        return 'En livraison';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}

// Page de test pour diagnostiquer le problème
class TestPage extends StatelessWidget {
  final UserRole role;
  
  const TestPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.jauneClairDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.vertDonM,
        title: Text('Test Page - ${role.toString().split('.').last}'),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DonMLogoWidget(size: 80),
            const SizedBox(height: 20),
            Text(
              'Page de test pour le rôle: ${role.toString().split('.').last}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DonMTheme.vertFonceDonM,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DonMTheme.jauneDonM,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Retour à la sélection'),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profil',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
