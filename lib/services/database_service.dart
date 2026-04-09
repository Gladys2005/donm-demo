import 'dart:async';
import 'dart:math';
import '../main_simple.dart';

// Service de simulation de base de données et API
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Simuler une base de données en mémoire
  final List<Order> _orders = [];
  final List<User> _users = [];
  final List<Product> _products = [];
  final StreamController<List<Order>> _orderStreamController = StreamController.broadcast();
  final StreamController<List<User>> _userStreamController = StreamController.broadcast();

  // Streams pour les mises à jour en temps réel
  Stream<List<Order>> get ordersStream => _orderStreamController.stream;
  Stream<List<User>> get usersStream => _userStreamController.stream;

  // Initialiser les données de démonstration
  void initializeData() {
    _initializeUsers();
    _initializeProducts();
    _initializeOrders();
  }

  void _initializeUsers() {
    _users.addAll([
      User(
        id: '1',
        name: 'Jean Kouadio',
        email: 'jean.kouadio@email.com',
        phone: '+225 07 00 00 00 00',
        role: UserRole.client,
        status: UserStatus.active,
        rating: 4.8,
        memberSince: DateTime.now().subtract(const Duration(days: 730)),
        kycLevel: 'VERIFIED',
      ),
      User(
        id: '2',
        name: 'Marie Konan',
        email: 'marie.konan@email.com',
        phone: '+225 07 01 01 01 01',
        role: UserRole.vendor,
        status: UserStatus.active,
        rating: 4.9,
        memberSince: DateTime.now().subtract(const Duration(days: 365)),
        kycLevel: 'CERTIFIED',
        shopName: 'Boutique Marie',
        shopAddress: 'Abidjan, Cocody',
      ),
      User(
        id: '3',
        name: 'Paul Yapo',
        email: 'paul.yapo@email.com',
        phone: '+225 07 02 02 02 02',
        role: UserRole.delivery,
        status: UserStatus.active,
        rating: 4.7,
        memberSince: DateTime.now().subtract(const Duration(days: 180)),
        kycLevel: 'VERIFIED',
        deliveryLevel: DeliveryLevel.experienced,
        currentLocation: 'Abidjan, Plateau',
        isAvailable: true,
      ),
    ]);
  }

  void _initializeProducts() {
    _products.addAll([
      Product(
        id: '1',
        name: 'Attiéké et poisson fumé',
        description: 'Plat traditionnel ivoirien',
        price: 2500,
        category: 'Plats',
        isAvailable: true,
        images: ['assets/images/attieke.jpg'],
      ),
      Product(
        id: '2',
        name: 'Alloco et oeuf',
        description: 'Banane plantain frite avec oeuf',
        price: 1500,
        category: 'Petit-déjeuner',
        isAvailable: true,
        images: ['assets/images/alloco.jpg'],
      ),
      Product(
        id: '3',
        name: 'Garba',
        description: 'Thon et gari',
        price: 2000,
        category: 'Plats',
        isAvailable: true,
        images: ['assets/images/garba.jpg'],
      ),
    ]);
  }

  void _initializeOrders() {
    final random = Random();
    for (int i = 0; i < 10; i++) {
      final order = Order(
        id: 'ORD-${i + 1}',
        clientId: '1', // ID du client de démonstration
        pickupAddress: 'Abidjan, Cocody, Boutique Marie',
        deliveryAddress: 'Abidjan, Yopougon, Zone ${i + 1}',
        distance: (5.0 + i).toDouble(),
        price: 150000 + (random.nextInt(10000) - 5000),
        status: _getRandomStatus(i),
        createdAt: DateTime.now().subtract(Duration(hours: i * 2)),
        deliveryPersonId: i % 3 == 0 ? (100 + i) : null,
        trackingCode: 'TRK-${1000 + i}',
      );
      _orders.add(order);
    }
    _orderStreamController.add(_orders);
  }

  String _getRandomStatus(int index) {
    final statuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'in_transit',
      'delivered',
      'cancelled',
    ];
    return statuses[index % statuses.length];
  }

  // CRUD Operations pour les commandes
  Future<List<Order>> getOrders({String? userId, UserRole? role}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simuler réseau
    
    List<Order> filteredOrders = List.from(_orders);
    
    if (userId != null && role != null) {
      filteredOrders = filteredOrders.where((order) {
        switch (role) {
          case UserRole.client:
            // Pour le client, on retourne toutes les commandes (démo)
            return true;
          case UserRole.vendor:
            // Pour le vendeur, on retourne les commandes confirmées et en préparation
            return order.status == 'confirmed' || order.status == 'preparing' || order.status == 'ready';
          case UserRole.delivery:
            // Pour le livreur, on retourne les commandes prêtes et en transit
            return order.status == 'ready' || order.status == 'in_transit' || order.deliveryPersonId?.toString() == userId;
        }
      }).toList();
    }
    
    return filteredOrders;
  }

  Future<Order> createOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newOrder = _createOrder(
      pickupAddress: order.pickupAddress,
      deliveryAddress: order.deliveryAddress,
      distance: order.distance,
      price: order.price,
      status: order.status,
    );
    
    _orders.add(newOrder);
    _orderStreamController.add(_orders);
    
    return newOrder;
  }

  Order _createOrder({
    String? id,
    required String pickupAddress,
    required String deliveryAddress,
    required double distance,
    required double price,
    String? status,
  }) {
    return Order(
      id: id ?? 'ORD-${_orders.length + 1}',
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      distance: distance,
      price: price,
      status: status ?? 'pending',
      createdAt: DateTime.now(),
    );
  }

  Future<Order> updateOrderStatus(String orderId, String status, {String? deliveryPersonId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      // Créer une nouvelle commande avec le statut mis à jour
      final updatedOrder = Order(
        id: _orders[orderIndex].id,
        pickupAddress: _orders[orderIndex].pickupAddress,
        deliveryAddress: _orders[orderIndex].deliveryAddress,
        distance: _orders[orderIndex].distance,
        price: _orders[orderIndex].price,
        status: status,
        createdAt: _orders[orderIndex].createdAt,
        deliveryPersonId: deliveryPersonId != null ? int.tryParse(deliveryPersonId) : _orders[orderIndex].deliveryPersonId,
      );
      
      _orders[orderIndex] = updatedOrder;
      _orderStreamController.add(_orders);
      return updatedOrder;
    } else {
      throw Exception('Commande non trouvée');
    }
  }

  Future<List<User>> getUsers({UserRole? role}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (role != null) {
      return _users.where((user) => user.role == role).toList();
    }
    
    return List.from(_users);
  }

  Future<List<Product>> getProducts({String? vendorId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Pour la démo, on retourne tous les produits car le modèle Product n'a pas vendorId
    return List.from(_products);
  }

  Future<List<User>> getAvailableDeliveryPersons() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _users.where((user) => 
      user.role == UserRole.delivery && 
      user.isAvailable == true
    ).toList();
  }

  Future<void> acceptDelivery(String orderId, String deliveryPersonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    await updateOrderStatus(orderId, 'in_transit', deliveryPersonId: deliveryPersonId);
  }

  // Notifications
  void _notifyVendor(Order order) {
    // Simuler une notification au vendeur
    print('Nouvelle commande reçue: ${order.id} pour le vendeur');
  }

  void _notifyOrderUpdate(Order order) {
    // Simuler une notification de mise à jour
    print('Commande mise à jour: ${order.id} - Statut: ${order.status}');
  }

  // Commandes
  List<Order> getAllOrders() {
    return List.unmodifiable(_orders);
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Produits
  List<Product> getAllProducts() {
    return List.unmodifiable(_products);
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void createProduct(Product product) {
    _products.add(product);
    print('Produit créé: ${product.id} - ${product.name}');
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      print('Produit mis à jour: ${product.id} - ${product.name}');
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((product) => product.id == productId);
    print('Produit supprimé: $productId');
  }

  // Nettoyage
  void dispose() {
    _orderStreamController.close();
    _userStreamController.close();
  }
}

// Extensions pour les modèles
extension OrderCopyWith on Order {
  Order copyWith({
    String? id,
    String? deliveryPersonId,
    String? status,
    String? deliveryAddress,
    String? pickupAddress,
    DateTime? createdAt,
    double? distance,
    double? price,
    String? trackingCode,
  }) {
    return Order(
      id: id ?? this.id,
      deliveryPersonId: deliveryPersonId != null ? int.tryParse(deliveryPersonId) : this.deliveryPersonId,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      createdAt: createdAt ?? this.createdAt,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      trackingCode: trackingCode ?? this.trackingCode,
    );
  }
}
