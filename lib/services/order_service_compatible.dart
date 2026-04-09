import 'dart:async';
import '../main_simple.dart';

// Service de commandes compatible avec les modèles existants
class OrderServiceCompatible {
  static final OrderServiceCompatible _instance = OrderServiceCompatible._internal();
  factory OrderServiceCompatible() => _instance;
  OrderServiceCompatible._internal();

  // Simuler une base de données en mémoire
  final List<Order> _orders = [];
  final StreamController<List<Order>> _orderStreamController = StreamController.broadcast();

  Stream<List<Order>> get ordersStream => _orderStreamController.stream;

  // Initialiser les données de démonstration
  void initializeData() {
    _initializeOrders();
  }

  void _initializeOrders() {
    // Créer des commandes compatibles avec le modèle Order existant
    for (int i = 0; i < 10; i++) {
      final order = Order(
        id: 'ORD-${i + 1}',
        pickupAddress: 'Abidjan, Cocody, Boutique ${i + 1}',
        deliveryAddress: 'Abidjan, Yopougon, Zone ${i + 1}',
        distance: (5.0 + i).toDouble(),
        price: (2000 + i * 500).toDouble(),
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
    final statuses = ['pending', 'confirmed', 'preparing', 'ready', 'in_transit', 'delivered', 'cancelled'];
    return statuses[index % statuses.length];
  }

  // Obtenir les commandes selon le rôle
  Future<List<Order>> getOrdersByRole(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simuler réseau
    
    List<Order> filteredOrders = List.from(_orders);
    
    // Filtrer selon le rôle (logique simplifiée)
    switch (role) {
      case UserRole.client:
        // Le client voit toutes les commandes (démo)
        break;
      case UserRole.vendor:
        // Le vendeur voit les commandes confirmées et en préparation
        filteredOrders = filteredOrders.where((order) => 
          order.status == 'confirmed' || order.status == 'preparing' || order.status == 'ready'
        ).toList();
        break;
      case UserRole.delivery:
        // Le livreur voit les commandes assignées et disponibles
        filteredOrders = filteredOrders.where((order) => 
          order.status == 'ready' || order.status == 'in_transit' || (order.status == 'confirmed' && order.deliveryPersonId == null)
        ).toList();
        break;
    }
    
    return filteredOrders;
  }

  // Annuler une commande
  Future<void> cancelOrder(String orderId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = Order(
        id: _orders[orderIndex].id,
        pickupAddress: _orders[orderIndex].pickupAddress,
        deliveryAddress: _orders[orderIndex].deliveryAddress,
        distance: _orders[orderIndex].distance,
        price: _orders[orderIndex].price,
        status: 'cancelled',
        createdAt: _orders[orderIndex].createdAt,
        deliveryPersonId: _orders[orderIndex].deliveryPersonId,
        trackingCode: _orders[orderIndex].trackingCode,
      );
      
      _orderStreamController.add(_orders);
    } else {
      throw Exception('Commande non trouvée');
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = Order(
        id: _orders[orderIndex].id,
        pickupAddress: _orders[orderIndex].pickupAddress,
        deliveryAddress: _orders[orderIndex].deliveryAddress,
        distance: _orders[orderIndex].distance,
        price: _orders[orderIndex].price,
        status: status,
        createdAt: _orders[orderIndex].createdAt,
        deliveryPersonId: _orders[orderIndex].deliveryPersonId,
        trackingCode: _orders[orderIndex].trackingCode,
      );
      
      _orderStreamController.add(_orders);
    } else {
      throw Exception('Commande non trouvée');
    }
  }

  // Accepter une livraison (pour les livreurs)
  Future<void> acceptDelivery(String orderId, int deliveryPersonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = Order(
        id: _orders[orderIndex].id,
        pickupAddress: _orders[orderIndex].pickupAddress,
        deliveryAddress: _orders[orderIndex].deliveryAddress,
        distance: _orders[orderIndex].distance,
        price: _orders[orderIndex].price,
        status: 'in_transit',
        createdAt: _orders[orderIndex].createdAt,
        deliveryPersonId: deliveryPersonId,
        trackingCode: _orders[orderIndex].trackingCode,
      );
      
      _orderStreamController.add(_orders);
    } else {
      throw Exception('Commande non trouvée');
    }
  }

  // Créer une nouvelle commande (simplifiée)
  Future<Order> createOrder({
    required String pickupAddress,
    required String deliveryAddress,
    required double distance,
    required double price,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newOrder = Order(
      id: 'ORD-${_orders.length + 1}',
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      distance: distance,
      price: price,
      status: 'pending',
      createdAt: DateTime.now(),
      trackingCode: 'TRK-${1000 + _orders.length}',
    );
    
    _orders.add(newOrder);
    _orderStreamController.add(_orders);
    
    return newOrder;
  }

  // Obtenir les détails d'une commande
  Future<Order> getOrderDetails(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      throw Exception('Commande non trouvée');
    }
  }

  // Statistiques
  Future<Map<String, int>> getOrderStats(String userId, UserRole role) async {
    final orders = await getOrdersByRole(userId, role);
    
    final stats = <String, int>{
      'total': orders.length,
      'pending': 0,
      'confirmed': 0,
      'preparing': 0,
      'ready': 0,
      'in_transit': 0,
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
          stats['in_transit'] = (stats['in_transit'] ?? 0) + 1;
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
    _orderStreamController.close();
  }
}
