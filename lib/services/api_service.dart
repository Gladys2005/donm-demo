import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../main_simple.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 30);
  static String? _authToken;

  // Headers par défaut
  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Définir le token d'authentification
  static void setAuthToken(String? token) {
    _authToken = token;
  }

  // Supprimer le token d'authentification
  static void clearAuthToken() {
    _authToken = null;
  }

  // Vérifier si l'utilisateur est authentifié
  static bool get isAuthenticated => _authToken != null;

  // Gestion des erreurs
  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw Exception('Requête invalide: ${response.body}');
      case 404:
        throw Exception('Ressource non trouvée');
      case 500:
        throw Exception('Erreur serveur interne');
      default:
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ==================== AUTHENTIFICATION ====================

  // Connexion
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      
      // Stocker le token
      if (data['token'] != null) {
        setAuthToken(data['token']);
      }
      
      return data;
    } catch (e) {
      print('Erreur login: $e');
      throw e;
    }
  }

  // Inscription
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? shopName,
    String? shopAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: json.encode({
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          if (shopName != null) 'shop_name': shopName,
          if (shopAddress != null) 'shop_address': shopAddress,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      
      // Stocker le token
      if (data['token'] != null) {
        setAuthToken(data['token']);
      }
      
      return data;
    } catch (e) {
      print('Erreur register: $e');
      throw e;
    }
  }

  // Vérifier le token
  static Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _headers,
      ).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur verifyToken: $e');
      // Si le token est invalide, le supprimer
      clearAuthToken();
      throw e;
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      ).timeout(timeout);
    } catch (e) {
      print('Erreur logout: $e');
    } finally {
      clearAuthToken();
    }
  }

  // Vérifier la santé de l'API
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API DonM: ${data['message']}');
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur de connexion à l\'API: $e');
      return false;
    }
  }

  // ==================== UTILISATEURS ====================

  // Récupérer tous les utilisateurs
  static Future<List<User>> getUsers({String? role}) async {
    try {
      String url = '$baseUrl/users';
      if (role != null) {
        url += '?role=$role';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(timeout);

      final data = _handleResponse(response);
      
      List<User> users = [];
      for (var item in data) {
        users.add(_mapApiUserToUser(item));
      }
      return users;
    } catch (e) {
      print('Erreur getUsers: $e');
      throw e;
    }
  }

  // Créer un utilisateur
  static Future<User> createUser({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? shopName,
    String? shopAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
        body: json.encode({
          'username': username,
          'email': email,
          'phone': phone,
          'password_hash': password, // Dans une vraie app, hasher le mot de passe
          'first_name': firstName,
          'last_name': lastName,
          'role': role.toString().split('.').last,
          if (shopName != null) 'shop_name': shopName,
          if (shopAddress != null) 'shop_address': shopAddress,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      return _mapApiUserToUser(data);
    } catch (e) {
      print('Erreur createUser: $e');
      throw e;
    }
  }

  // Mapper API User vers User model
  static User _mapApiUserToUser(Map<String, dynamic> apiUser) {
    UserRole role = UserRole.client;
    switch (apiUser['role']) {
      case 'vendor':
        role = UserRole.vendor;
        break;
      case 'delivery':
        role = UserRole.delivery;
        break;
    }

    UserStatus status = UserStatus.active;
    switch (apiUser['status']) {
      case 'inactive':
        status = UserStatus.inactive;
        break;
      case 'suspended':
        status = UserStatus.suspended;
        break;
    }

    DeliveryLevel? deliveryLevel;
    if (apiUser['delivery_level'] != null) {
      switch (apiUser['delivery_level']) {
        case 'beginner':
          deliveryLevel = DeliveryLevel.beginner;
          break;
        case 'intermediate':
          deliveryLevel = DeliveryLevel.intermediate;
          break;
        case 'experienced':
          deliveryLevel = DeliveryLevel.experienced;
          break;
        case 'expert':
          deliveryLevel = DeliveryLevel.expert;
          break;
      }
    }

    return User(
      id: apiUser['id'],
      name: apiUser['full_name'] ?? '${apiUser['first_name']} ${apiUser['last_name']}',
      email: apiUser['email'],
      phone: apiUser['phone'],
      role: role,
      status: status,
      rating: (apiUser['rating'] ?? 0.0).toDouble(),
      memberSince: DateTime.parse(apiUser['created_at']),
      kycLevel: apiUser['kyc_level'] ?? 'NONE',
      shopName: apiUser['shop_name'],
      shopAddress: apiUser['shop_address'],
      deliveryLevel: deliveryLevel,
      currentLocation: apiUser['current_location'],
      isAvailable: apiUser['is_available'] ?? true,
      vehicleType: apiUser['vehicle_type'],
    );
  }

  // ==================== PRODUITS ====================

  // Récupérer tous les produits
  static Future<List<Product>> getProducts({
    String? vendorId,
    String? category,
    bool? available,
  }) async {
    try {
      String url = '$baseUrl/products';
      List<String> params = [];
      
      if (vendorId != null) params.add('vendor_id=$vendorId');
      if (category != null) params.add('category=$category');
      if (available != null) params.add('available=$available');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(timeout);

      final data = _handleResponse(response);
      
      List<Product> products = [];
      for (var item in data) {
        products.add(_mapApiProductToProduct(item));
      }
      return products;
    } catch (e) {
      print('Erreur getProducts: $e');
      throw e;
    }
  }

  // Créer un produit
  static Future<Product> createProduct({
    required String vendorId,
    required String name,
    required String description,
    required String shortDescription,
    required double price,
    required String category,
    required List<String> images,
    bool isAvailable = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
        body: json.encode({
          'vendor_id': vendorId,
          'name': name,
          'description': description,
          'short_description': shortDescription,
          'price': price,
          'category': category,
          'images': images,
          'is_available': isAvailable,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      return _mapApiProductToProduct(data);
    } catch (e) {
      print('Erreur createProduct: $e');
      throw e;
    }
  }

  // Mettre à jour un produit
  static Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required String shortDescription,
    required double price,
    required String category,
    required List<String> images,
    bool isAvailable = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'description': description,
          'short_description': shortDescription,
          'price': price,
          'category': category,
          'images': images,
          'is_available': isAvailable,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      return _mapApiProductToProduct(data);
    } catch (e) {
      print('Erreur updateProduct: $e');
      throw e;
    }
  }

  // Supprimer un produit
  static Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      ).timeout(timeout);

      _handleResponse(response);
    } catch (e) {
      print('Erreur deleteProduct: $e');
      throw e;
    }
  }

  // Mapper API Product vers Product model
  static Product _mapApiProductToProduct(Map<String, dynamic> apiProduct) {
    return Product(
      id: apiProduct['id'],
      name: apiProduct['name'],
      description: apiProduct['description'] ?? '',
      price: (apiProduct['price'] ?? 0.0).toDouble(),
      category: apiProduct['category'] ?? '',
      isAvailable: apiProduct['is_available'] ?? true,
      images: List<String>.from(apiProduct['images'] ?? []),
    );
  }

  // ==================== COMMANDES ====================

  // Récupérer toutes les commandes
  static Future<List<Order>> getOrders({
    String? clientId,
    String? status,
    String? deliveryPersonId,
  }) async {
    try {
      String url = '$baseUrl/orders';
      List<String> params = [];
      
      if (clientId != null) params.add('client_id=$clientId');
      if (status != null) params.add('status=$status');
      if (deliveryPersonId != null) params.add('delivery_person_id=$deliveryPersonId');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(timeout);

      final data = _handleResponse(response);
      
      List<Order> orders = [];
      for (var item in data) {
        orders.add(_mapApiOrderToOrder(item));
      }
      return orders;
    } catch (e) {
      print('Erreur getOrders: $e');
      throw e;
    }
  }

  // Créer une commande
  static Future<Order> createOrder({
    required String clientId,
    required String pickupAddress,
    required String deliveryAddress,
    required double distance,
    required double basePrice,
    required double deliveryFee,
    required double totalAmount,
    String? pickupInstructions,
    String? deliveryInstructions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: json.encode({
          'client_id': clientId,
          'pickup_address': pickupAddress,
          'delivery_address': deliveryAddress,
          'distance': distance,
          'base_price': basePrice,
          'delivery_fee': deliveryFee,
          'total_amount': totalAmount,
          if (pickupInstructions != null) 'pickup_instructions': pickupInstructions,
          if (deliveryInstructions != null) 'delivery_instructions': deliveryInstructions,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      return _mapApiOrderToOrder(data);
    } catch (e) {
      print('Erreur createOrder: $e');
      throw e;
    }
  }

  // Mettre à jour le statut d'une commande
  static Future<Order> updateOrderStatus({
    required String id,
    required String status,
    String? deliveryPersonId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: _headers,
        body: json.encode({
          'status': status,
          if (deliveryPersonId != null) 'delivery_person_id': deliveryPersonId,
        }),
      ).timeout(timeout);

      final data = _handleResponse(response);
      return _mapApiOrderToOrder(data);
    } catch (e) {
      print('Erreur updateOrderStatus: $e');
      throw e;
    }
  }

  // Récupérer les livreurs disponibles
  static Future<List<User>> getAvailableDeliveryPersons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-persons/available'),
        headers: _headers,
      ).timeout(timeout);

      final data = _handleResponse(response);
      
      List<User> deliveryPersons = [];
      for (var item in data) {
        deliveryPersons.add(_mapApiUserToUser(item));
      }
      return deliveryPersons;
    } catch (e) {
      print('Erreur getAvailableDeliveryPersons: $e');
      throw e;
    }
  }

  // Mapper API Order vers Order model
  static Order _mapApiOrderToOrder(Map<String, dynamic> apiOrder) {
    return Order(
      id: apiOrder['id'],
      clientId: apiOrder['client_id'],
      pickupAddress: apiOrder['pickup_address'],
      deliveryAddress: apiOrder['delivery_address'],
      distance: (apiOrder['distance'] ?? 0.0).toDouble(),
      price: (apiOrder['total_amount'] ?? 0.0).toDouble(),
      status: apiOrder['status'] ?? 'pending',
      createdAt: DateTime.parse(apiOrder['created_at']),
      deliveryPersonId: apiOrder['delivery_person_id'] != null ? int.tryParse(apiOrder['delivery_person_id'].toString()) : null,
      trackingCode: apiOrder['tracking_code'],
    );
  }

  // ==================== PAIEMENTS ====================

  // Créer un paiement
  static Future<Map<String, dynamic>> createPayment({
    required String orderId,
    required double amount,
    required String method,
    String? transactionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: _headers,
        body: json.encode({
          'order_id': orderId,
          'amount': amount,
          'method': method,
          if (transactionId != null) 'transaction_id': transactionId,
        }),
      ).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur createPayment: $e');
      throw e;
    }
  }

  // Payer avec Mobile Money
  static Future<Map<String, dynamic>> payWithMobileMoney({
    required String orderId,
    required String phoneNumber,
    required String operator,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/mobile-money'),
        headers: _headers,
        body: json.encode({
          'order_id': orderId,
          'phone_number': phoneNumber,
          'operator': operator,
          'amount': amount,
        }),
      ).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur payWithMobileMoney: $e');
      throw e;
    }
  }

  // Récupérer les paiements d'une commande
  static Future<List<Map<String, dynamic>>> getOrderPayments(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/order/$orderId'),
        headers: _headers,
      ).timeout(timeout);

      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Erreur getOrderPayments: $e');
      throw e;
    }
  }

  // Récupérer les paiements d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/user/$userId'),
        headers: _headers,
      ).timeout(timeout);

      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Erreur getUserPayments: $e');
      throw e;
    }
  }

  // Rembourser un paiement
  static Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/refund'),
        headers: _headers,
        body: json.encode({
          'reason': reason,
        }),
      ).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur refundPayment: $e');
      throw e;
    }
  }
}
