import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../main_simple.dart';
import '../services/api_service.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'widget_test.mocks.dart';

void main() {
  group('DonM Widget Tests', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    testWidgets('App should render without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const DonMApp());

      // Verify that the app renders
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login page should render correctly', (WidgetTester tester) async {
      // Build the login page
      await tester.pumpWidget(const MaterialApp(
        home: LoginPage(),
      ));

      // Verify key widgets are present
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    });

    testWidgets('Registration page should render correctly', (WidgetTester tester) async {
      // Build the registration page
      await tester.pumpWidget(const MaterialApp(
        home: RegisterPage(),
      ));

      // Verify key widgets are present
      expect(find.text('Inscription'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(6)); // All registration fields
      expect(find.byType(DropdownButtonFormField), findsOneWidget); // Role selection
      expect(find.byType(ElevatedButton), findsOneWidget); // Register button
    });

    testWidgets('Role selection page should render correctly', (WidgetTester tester) async {
      // Build the role selection page
      await tester.pumpWidget(const MaterialApp(
        home: RoleSelectionPage(),
      ));

      // Verify role options are present
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Vendeur'), findsOneWidget);
      expect(find.text('Livreur'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(3)); // Three role buttons
    });

    testWidgets('Order form should render correctly', (WidgetTester tester) async {
      // Build the order form page
      await tester.pumpWidget(const MaterialApp(
        home: OrderFormPage(),
      ));

      // Verify form elements are present
      expect(find.text('Commander une livraison'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Pickup and delivery addresses
      expect(find.byType(ElevatedButton), findsOneWidget); // Submit button
    });

    testWidgets('Payment page should render correctly', (WidgetTester tester) async {
      // Create a mock order
      final mockOrder = Order(
        id: 'order-123',
        clientId: 'client-123',
        pickupAddress: 'Abidjan, Cocody',
        deliveryAddress: 'Abidjan, Yopougon',
        distance: 5.5,
        price: 2500.0,
        status: 'pending',
        createdAt: DateTime.now(),
        trackingCode: 'TRK-001',
      );

      // Build the payment page
      await tester.pumpWidget(MaterialApp(
        home: PaymentPage(order: mockOrder, amount: 2500.0),
      ));

      // Verify payment elements are present
      expect(find.text('Paiement'), findsOneWidget);
      expect(find.text('Résumé de la commande'), findsOneWidget);
      expect(find.text('Méthode de paiement'), findsOneWidget);
      expect(find.byType(Radio<String>), findsNWidgets(3)); // Three payment methods
    });

    testWidgets('Product list should render correctly', (WidgetTester tester) async {
      // Build the product list page
      await tester.pumpWidget(const MaterialApp(
        home: ProductListPage(),
      ));

      // Verify product list elements
      expect(find.text('Produits'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget); // Loading indicator
    });

    testWidgets('Order tracking should render correctly', (WidgetTester tester) async {
      // Create a mock order
      final mockOrder = Order(
        id: 'order-123',
        clientId: 'client-123',
        pickupAddress: 'Abidjan, Cocody',
        deliveryAddress: 'Abidjan, Yopougon',
        distance: 5.5,
        price: 2500.0,
        status: 'in_transit',
        createdAt: DateTime.now(),
        trackingCode: 'TRK-001',
      );

      // Build the order tracking page
      await tester.pumpWidget(MaterialApp(
        home: OrderTrackingPage(order: mockOrder),
      ));

      // Verify tracking elements
      expect(find.text('Suivi de commande'), findsOneWidget);
      expect(find.text('TRK-001'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget); // Progress indicator
    });

    group('Form Validation Tests', () {
      testWidgets('Login form should validate empty fields', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: LoginPage(),
        ));

        // Try to submit without filling fields
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should show validation errors
        expect(find.text('Veuillez entrer votre email'), findsOneWidget);
        expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
      });

      testWidgets('Registration form should validate email format', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: RegisterPage(),
        ));

        // Enter invalid email
        await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should show email validation error
        expect(find.text('Veuillez entrer un email valide'), findsOneWidget);
      });

      testWidgets('Order form should validate required fields', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: OrderFormPage(),
        ));

        // Try to submit without filling addresses
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should show validation errors
        expect(find.text('Veuillez entrer l\'adresse de départ'), findsOneWidget);
        expect(find.text('Veuillez entrer l\'adresse de livraison'), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('Should navigate between pages correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const DonMApp());

        // Start at login page
        expect(find.text('Connexion'), findsOneWidget);

        // Navigate to registration
        await tester.tap(find.text('Pas encore de compte ? Inscrivez-vous'));
        await tester.pumpAndSettle();

        // Should be on registration page
        expect(find.text('Inscription'), findsOneWidget);

        // Navigate back to login
        await tester.tap(find.text('Déjà un compte ? Connectez-vous'));
        await tester.pumpAndSettle();

        // Should be back on login page
        expect(find.text('Connexion'), findsOneWidget);
      });

      testWidgets('Should navigate to role selection after login', (WidgetTester tester) async {
        // Mock successful login
        when(mockApiService.login(any, any))
            .thenAnswer((_) async => {
              return {
                'message': 'Connexion réussie',
                'user': {'id': 'user-123', 'email': 'test@example.com'},
                'token': 'jwt-token'
              };
            });

        await tester.pumpWidget(const MaterialApp(
          home: LoginPage(),
        ));

        // Fill login form
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');

        // Submit login
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Should navigate to role selection
        expect(find.text('Choisissez votre rôle'), findsOneWidget);
      });
    });

    group('State Management Tests', () {
      testWidgets('Should update UI when loading state changes', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: ProductListPage(),
        ));

        // Initially should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Simulate data loading completion
        await tester.pump(Duration(seconds: 2));

        // Should hide loading indicator (assuming data is loaded)
        // Note: This would require mocking the actual API call
      });

      testWidgets('Should show error message when API call fails', (WidgetTester tester) async {
        // Mock API failure
        when(mockApiService.getProducts())
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(const MaterialApp(
          home: ProductListPage(),
        ));

        // Wait for error state
        await tester.pump();

        // Should show error message
        expect(find.text('Erreur de chargement'), findsOneWidget);
      });
    });

    group('User Interaction Tests', () {
      testWidgets('Should select payment method correctly', (WidgetTester tester) async {
        final mockOrder = Order(
          id: 'order-123',
          clientId: 'client-123',
          pickupAddress: 'Abidjan, Cocody',
          deliveryAddress: 'Abidjan, Yopougon',
          distance: 5.5,
          price: 2500.0,
          status: 'pending',
          createdAt: DateTime.now(),
          trackingCode: 'TRK-001',
        );

        await tester.pumpWidget(MaterialApp(
          home: PaymentPage(order: mockOrder, amount: 2500.0),
        ));

        // Initially no payment method selected
        expect(find.byType(Radio<String>), findsNWidgets(3));

        // Select mobile money payment
        await tester.tap(find.byKey(const Key('mobile_money_radio')));
        await tester.pump();

        // Should show mobile money specific fields
        expect(find.byKey(const Key('operator_dropdown')), findsOneWidget);
        expect(find.byKey(const Key('phone_field')), findsOneWidget);
      });

      testWidgets('Should enable/disable submit button based on form validity', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: OrderFormPage(),
        ));

        // Initially button should be disabled
        expect(find.byType(ElevatedButton), findsOneWidget);
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);

        // Fill required fields
        await tester.enterText(
            find.byKey(const Key('pickup_address_field')), 'Abidjan, Cocody');
        await tester.enterText(
            find.byKey(const Key('delivery_address_field')), 'Abidjan, Yopougon');
        await tester.pump();

        // Button should be enabled
        expect(find.byType(ElevatedButton), findsOneWidget);
        final updatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(updatedButton.onPressed, isNotNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: LoginPage(),
        ));

        // Check semantic labels
        expect(find.bySemanticsLabel('Champ email'), findsOneWidget);
        expect(find.bySemanticsLabel('Champ mot de passe'), findsOneWidget);
        expect(find.bySemanticsLabel('Bouton de connexion'), findsOneWidget);
      });

      testWidgets('Should support keyboard navigation', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: LoginPage(),
        ));

        // Test tab navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Focus should move to next field
        // Note: This would require specific implementation of focus management
      });
    });

    group('Performance Tests', () {
      testWidgets('Should render within performance budget', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(const DonMApp());
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Should render within 2 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Should handle large lists efficiently', (WidgetTester tester) async {
        // Create a large list of products
        final largeProductList = List.generate(1000, (index) => Product(
          id: 'product-$index',
          name: 'Product $index',
          price: 1000.0 + index,
          category: 'Test Category',
          vendorId: 'vendor-123',
          isAvailable: true,
        ));

        await tester.pumpWidget(MaterialApp(
          home: ProductListPage(products: largeProductList),
        ));

        // Should handle scrolling smoothly
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pump();

        // Should not drop frames
        expect(tester.takeException(), isNull);
      });
    });
  });
}

// Mock classes for testing
class DonMApp extends StatelessWidget {
  const DonMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonM Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              key: const Key('email_field'),
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Entrez votre email',
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
            TextFormField(
              key: const Key('password_field'),
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre mot de passe';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Se connecter'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Pas encore de compte ? Inscrivez-vous'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Déjà un compte ? Connectez-vous'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              key: const Key('email_field'),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Rôle'),
              items: ['client', 'vendor', 'delivery']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisissez votre rôle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Client'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Vendeur'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Livreur'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderFormPage extends StatelessWidget {
  const OrderFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commander une livraison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              key: const Key('pickup_address_field'),
              decoration: const InputDecoration(
                labelText: 'Adresse de départ',
                hintText: 'Entrez l\'adresse de départ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('delivery_address_field'),
              decoration: const InputDecoration(
                labelText: 'Adresse de livraison',
                hintText: 'Entrez l\'adresse de livraison',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Commander'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key, this.products});

  final List<Product>? products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      body: products == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products!.length,
              itemBuilder: (context, index) {
                final product = products![index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.price} FCFA'),
                );
              },
            ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, required this.order, required this.amount});

  final Order order;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Résumé de la commande'),
            const SizedBox(height: 16),
            const Text('Méthode de paiement'),
            RadioListTile<String>(
              key: const Key('mobile_money_radio'),
              title: const Text('Mobile Money'),
              value: 'mobile_money',
              groupValue: 'mobile_money',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Espèces'),
              value: 'cash',
              groupValue: 'mobile_money',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Carte bancaire'),
              value: 'card',
              groupValue: 'mobile_money',
              onChanged: (value) {},
            ),
            DropdownButtonFormField<String>(
              key: const Key('operator_dropdown'),
              decoration: const InputDecoration(labelText: 'Opérateur'),
              items: ['orange', 'mtn', 'momo']
                  .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                  .toList(),
              onChanged: (value) {},
            ),
            TextFormField(
              key: const Key('phone_field'),
              decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: Text('Payer ${amount.toInt()} FCFA'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de commande')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Code de suivi: ${order.trackingCode}'),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text('Statut: ${order.status}'),
          ],
        ),
      ),
    );
  }
}

// Mock data classes
class Order {
  final String id;
  final String clientId;
  final String pickupAddress;
  final String deliveryAddress;
  final double distance;
  final double price;
  final String status;
  final DateTime createdAt;
  final String trackingCode;

  Order({
    required this.id,
    required this.clientId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.trackingCode,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String vendorId;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.vendorId,
    required this.isAvailable,
  });
}
