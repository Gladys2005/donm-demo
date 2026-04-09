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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const DonMApp());
}

class DonMApp extends StatelessWidget {
  const DonMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonM - Livraison à Abidjan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: DonMTheme.vertDonM,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DonMTheme.vertDonM,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/orders': (context) => const OrdersPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

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
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Page de connexion - En construction'),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Page d\'inscription - En construction'),
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
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
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
                  () => Navigator.of(context).pushNamed('/orders'),
                ),
                _buildFeatureCard(
                  '🏪',
                  'Restaurants',
                  'Découvrez nos partenaires',
                  DonMTheme.vertDonM,
                  () => _showComingSoon(context),
                ),
                _buildFeatureCard(
                  '📱',
                  'Suivi',
                  'Suivez vos livraisons',
                  DonMTheme.infoDonM,
                  () => _showComingSoon(context),
                ),
                _buildFeatureCard(
                  '💰',
                  'Paiement',
                  'Mobile Money disponible',
                  DonMTheme.succesDonM,
                  () => _showComingSoon(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String description, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité bientôt disponible!'),
        backgroundColor: DonMTheme.infoDonM,
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Page des commandes - En construction'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Page de profil - En construction'),
      ),
    );
  }
}
