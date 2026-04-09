import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../services/api_service.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late MockClient mockClient;
    late ApiService apiService;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService();
      // Override the HTTP client for testing
      ApiService.setTestClient(mockClient);
    });

    tearDown(() {
      ApiService.clearAuthToken();
    });

    group('Authentication Tests', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        final loginResponse = {
          'message': 'Connexion réussie',
          'user': {
            'id': 'user-123',
            'email': 'test@example.com',
            'role': 'client'
          },
          'token': 'jwt-token-123'
        };

        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"message":"Connexion réussie","user":{"id":"user-123","email":"test@example.com","role":"client"},"token":"jwt-token-123"}',
                200));

        // Act
        final result = await apiService.login('test@example.com', 'password123');

        // Assert
        expect(result['message'], equals('Connexion réussie'));
        expect(result['user']['email'], equals('test@example.com'));
        expect(result['token'], equals('jwt-token-123'));
        expect(apiService.isAuthenticated, isTrue);
      });

      test('should handle login failure with invalid credentials', () async {
        // Arrange
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"error":"Email ou mot de passe incorrect"}', 401));

        // Act & Assert
        expect(
          () async => await apiService.login('test@example.com', 'wrongpassword'),
          throwsA(isA<Exception>()),
        );
      });

      test('should register successfully with valid data', () async {
        // Arrange
        final registerResponse = {
          'message': 'Utilisateur créé avec succès',
          'user': {
            'id': 'user-123',
            'email': 'newuser@example.com',
            'role': 'client'
          },
          'token': 'jwt-token-456'
        };

        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"message":"Utilisateur créé avec succès","user":{"id":"user-123","email":"newuser@example.com","role":"client"},"token":"jwt-token-456"}',
                201));

        // Act
        final result = await apiService.register(
          username: 'newuser',
          email: 'newuser@example.com',
          phone: '+2250770000000',
          password: 'password123',
          firstName: 'New',
          lastName: 'User',
          role: 'client',
        );

        // Assert
        expect(result['message'], equals('Utilisateur créé avec succès'));
        expect(result['user']['email'], equals('newuser@example.com'));
        expect(apiService.isAuthenticated, isTrue);
      });

      test('should verify token successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"message":"Token valide","user":{"id":"user-123","email":"test@example.com","role":"client"}}',
                200));

        // Act
        final result = await apiService.verifyToken();

        // Assert
        expect(result['message'], equals('Token valide'));
        expect(result['user']['email'], equals('test@example.com'));
      });

      test('should handle invalid token verification', () async {
        // Arrange
        ApiService.setAuthToken('invalid-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"error":"Token invalide ou expiré"}', 403));

        // Act & Assert
        expect(
          () async => await apiService.verifyToken(),
          throwsA(isA<Exception>()),
        );
      });

      test('should logout successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"message":"Déconnexion réussie"}', 200));

        // Act
        final result = await apiService.logout();

        // Assert
        expect(result['message'], equals('Déconnexion réussie'));
        expect(apiService.isAuthenticated, isFalse);
      });
    });

    group('Payment Tests', () {
      test('should create payment successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"message":"Paiement créé avec succès","payment":{"id":"payment-123","status":"paid"}}',
                201));

        // Act
        final result = await apiService.createPayment(
          orderId: 'order-123',
          amount: 2500.0,
          method: 'cash',
          transactionId: 'txn-123',
        );

        // Assert
        expect(result['message'], equals('Paiement créé avec succès'));
        expect(result['payment']['status'], equals('paid'));
      });

      test('should process mobile money payment successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"success":true,"message":"Paiement initié avec succès","paymentId":"payment-123","paymentUrl":"https://payment.url","operator":"orange","amount":2550,"fees":50}',
                200));

        // Act
        final result = await apiService.payWithMobileMoney(
          orderId: 'order-123',
          phoneNumber: '+2250770000000',
          operator: 'orange',
          amount: 2500.0,
        );

        // Assert
        expect(result['success'], isTrue);
        expect(result['operator'], equals('orange'));
        expect(result['amount'], equals(2550.0));
        expect(result['fees'], equals(50));
      });

      test('should handle mobile money payment failure', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"success":false,"error":"Service indisponible","code":503}',
                400));

        // Act & Assert
        expect(
          () async => await apiService.payWithMobileMoney(
            orderId: 'order-123',
            phoneNumber: '+2250770000000',
            operator: 'orange',
            amount: 2500.0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should get order payments successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"payment-1","status":"paid","amount":2500},{"id":"payment-2","status":"pending","amount":500}]',
                200));

        // Act
        final result = await apiService.getOrderPayments('order-123');

        // Assert
        expect(result, isA<List>());
        expect(result.length, equals(2));
        expect(result[0]['status'], equals('paid'));
        expect(result[1]['status'], equals('pending'));
      });

      test('should get user payments successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"payment-1","order_number":"ORD-001","order_total":2500,"status":"paid"}]',
                200));

        // Act
        final result = await apiService.getUserPayments('user-123');

        // Assert
        expect(result, isA<List>());
        expect(result.length, equals(1));
        expect(result[0]['order_number'], equals('ORD-001'));
      });

      test('should refund payment successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"message":"Paiement remboursé avec succès","refunded_amount":2500}',
                200));

        // Act
        final result = await apiService.refundPayment(
          paymentId: 'payment-123',
          reason: 'Client satisfait',
        );

        // Assert
        expect(result['message'], equals('Paiement remboursé avec succès'));
        expect(result['refunded_amount'], equals(2500));
      });
    });

    group('Order Tests', () {
      test('should create order successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"message":"Commande créée avec succès","order":{"id":"order-123","tracking_code":"TRK-001","status":"pending"}}',
                201));

        // Act
        final result = await apiService.createOrder({
          'client_id': 'client-123',
          'pickup_address': 'Abidjan, Cocody',
          'delivery_address': 'Abidjan, Yopougon',
          'distance': 5.5,
          'base_price': 2000.0,
          'delivery_fee': 500.0,
          'total_amount': 2500.0,
        });

        // Assert
        expect(result['message'], equals('Commande créée avec succès'));
        expect(result['order']['tracking_code'], equals('TRK-001'));
      });

      test('should get orders successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"order-1","status":"pending","tracking_code":"TRK-001"},{"id":"order-2","status":"confirmed","tracking_code":"TRK-002"}]',
                200));

        // Act
        final result = await apiService.getOrders();

        // Assert
        expect(result, isA<List>());
        expect(result.length, equals(2));
        expect(result[0]['status'], equals('pending'));
        expect(result[1]['status'], equals('confirmed'));
      });

      test('should get orders by client successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"order-1","client_id":"client-123","status":"pending"}]',
                200));

        // Act
        final result = await apiService.getOrders(clientId: 'client-123');

        // Assert
        expect(result, isA<List>());
        expect(result.length, equals(1));
        expect(result[0]['client_id'], equals('client-123'));
      });

      test('should update order status successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.put(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"id":"order-123","status":"confirmed","delivery_person_id":"delivery-456"}',
                200));

        // Act
        final result = await apiService.updateOrderStatus('order-123', 'confirmed', 'delivery-456');

        // Assert
        expect(result['status'], equals('confirmed'));
        expect(result['delivery_person_id'], equals('delivery-456'));
      });
    });

    group('Product Tests', () {
      test('should get products successfully', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"product-1","name":"Attiéké","price":2500,"category":"Plats chauds","is_available":true}]',
                200));

        // Act
        final result = await apiService.getProducts();

        // Assert
        expect(result, isA<List>());
        expect(result.length, equals(1));
        expect(result[0]['name'], equals('Attiéké'));
        expect(result[0]['price'], equals(2500));
      });

      test('should get products by category successfully', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '[{"id":"product-1","name":"Attiéké","category":"Plats chauds"},{"id":"product-2","name":"Alloco","category":"Plats chauds"}]',
                200));

        // Act
        final result = await apiService.getProducts(category: 'Plats chauds');

        // Assert
        expect(result, isA<List>());
        expect(result.length, equals(2));
        result.forEach((product) {
          expect(product['category'], equals('Plats chauds'));
        });
      });

      test('should create product successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"id":"product-123","name":"Nouveau produit","price":3000,"category":"Boissons"}',
                201));

        // Act
        final result = await apiService.createProduct({
          'vendor_id': 'vendor-123',
          'name': 'Nouveau produit',
          'description': 'Description du produit',
          'price': 3000.0,
          'category': 'Boissons',
          'images': ['image.jpg'],
          'is_available': true,
        });

        // Assert
        expect(result['name'], equals('Nouveau produit'));
        expect(result['price'], equals(3000));
        expect(result['category'], equals('Boissons'));
      });

      test('should update product successfully', () async {
        // Arrange
        ApiService.setAuthToken('valid-token');
        
        when(mockClient.put(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(
                '{"id":"product-123","name":"Produit mis à jour","price":3200}',
                200));

        // Act
        final result = await apiService.updateProduct('product-123', {
          'name': 'Produit mis à jour',
          'price': 3200.0,
        });

        // Assert
        expect(result['name'], equals('Produit mis à jour'));
        expect(result['price'], equals(3200));
      });
    });

    group('Error Handling Tests', () {
      test('should handle network timeout', () async {
        // Arrange
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () async => await apiService.login('test@example.com', 'password123'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed JSON response', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Invalid JSON', 200));

        // Act & Assert
        expect(
          () async => await apiService.getProducts(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle 500 server error', () async {
        // Arrange
        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Internal Server Error', 500));

        // Act & Assert
        expect(
          () async => await apiService.login('test@example.com', 'password123'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Authentication Headers Tests', () {
      test('should include auth header when token is set', () async {
        // Arrange
        ApiService.setAuthToken('test-token');
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"user":{"id":"user-123"}}', 200));

        // Act
        await apiService.verifyToken();

        // Assert
        verify(mockClient.get(any, headers: argThat(
          contains('Authorization'),
        ))).called(1);
      });

      test('should not include auth header when token is not set', () async {
        // Arrange
        ApiService.clearAuthToken();
        
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('[]', 200));

        // Act
        await apiService.getProducts();

        // Assert
        verify(mockClient.get(any, headers: argThat(
          isNot(contains('Authorization')),
        ))).called(1);
      });
    });
  });
}
