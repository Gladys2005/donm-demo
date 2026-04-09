import 'dart:async';
import '../main_simple.dart';
import 'database_service.dart';

// Service simplifié de gestion des commandes
class OrderServiceSimple {
  static final OrderServiceSimple _instance = OrderServiceSimple._internal();
  factory OrderServiceSimple() => _instance;
  OrderServiceSimple._internal();

  final DatabaseService _database = DatabaseService();

  // Initialiser les services
  void initialize() {
    _database.initializeData();
  }

  // Client passe une nouvelle commande
  Future<Order> createOrder({
    required String deliveryAddress,
    required String pickupAddress,
    required double distance,
    required double price,
  }) async {
    final order = Order(
      id: '', // Sera généré dans la base de données
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      distance: distance,
      price: price,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    return await _database.createOrder(order);
  }

  // Obtenir les commandes selon le rôle
  Future<List<Order>> getOrdersByRole(String userId, UserRole role) async {
    return await _database.getOrders(userId: userId, role: role);
  }

  // Annuler une commande
  Future<void> cancelOrder(String orderId, String userId) async {
    await _database.updateOrderStatus(orderId, 'cancelled');
  }

  // Obtenir les produits disponibles
  Future<List<Product>> getAvailableProducts({String? vendorId}) async {
    return await _database.getProducts(vendorId: vendorId);
  }

  // Obtenir les utilisateurs par rôle
  Future<List<User>> getUsersByRole(UserRole role) async {
    return await _database.getUsers(role: role);
  }

  // Obtenir les livreurs disponibles
  Future<List<User>> getAvailableDeliveryPersons() async {
    return await _database.getAvailableDeliveryPersons();
  }

  // Streams pour les mises à jour en temps réel
  Stream<List<Order>> getOrdersStream() {
    return _database.ordersStream;
  }

  // Statistiques
  Future<Map<String, int>> getOrderStats(String userId, UserRole role) async {
    final orders = await _database.getOrders(userId: userId, role: role);
    
    final stats = <String, int>{
      'total': orders.length,
      'pending': 0,
      'confirmed': 0,
      'preparing': 0,
      'ready': 0,
      'inTransit': 0,
      'delivered': 0,
      'cancelled': 0,
    };

    for (final order in orders) {
      switch (order.status) {
        case 'pending':
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case 'confirmed':
          stats['confirmed'] = (stats['confirmed'] ?? 0) + 1;
          break;
        case 'preparing':
          stats['preparing'] = (stats['preparing'] ?? 0) + 1;
          break;
        case 'ready':
          stats['ready'] = (stats['ready'] ?? 0) + 1;
          break;
        case 'in_transit':
          stats['inTransit'] = (stats['inTransit'] ?? 0) + 1;
          break;
        case 'delivered':
          stats['delivered'] = (stats['delivered'] ?? 0) + 1;
          break;
        case 'cancelled':
          stats['cancelled'] = (stats['cancelled'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  // Nettoyage
  void dispose() {
    _database.dispose();
  }
}
