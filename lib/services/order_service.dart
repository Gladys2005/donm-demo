import 'dart:async';
import '../main_simple.dart';
import 'database_service.dart';
import 'communication_service.dart';

// Service de gestion des commandes avec interaction entre rôles
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final DatabaseService _database = DatabaseService();
  final CommunicationService _communication = CommunicationService();

  // Initialiser les services
  void initialize() {
    _database.initializeData();
  }

  // === FONCTIONNALITÉS CLIENT ===

  // Client passe une nouvelle commande
  Future<Order> createOrder({
    required String clientId,
    required String vendorId,
    required List<OrderItem> items,
    required String deliveryAddress,
    required String pickupAddress,
  }) async {
    return await _communication.placeOrder(
      clientId: clientId,
      vendorId: vendorId,
      items: items,
      deliveryAddress: deliveryAddress,
      pickupAddress: pickupAddress,
    );
  }

  // Client obtient ses commandes
  Future<List<Order>> getClientOrders(String clientId) async {
    return await _database.getOrders(userId: clientId, role: UserRole.client);
  }

  // Client annule une commande
  Future<void> cancelOrder(String orderId, String clientId) async {
    final orders = await _database.getOrders();
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.clientId != clientId) {
      throw Exception('Vous ne pouvez annuler que vos propres commandes');
    }

    if (order.status == OrderStatus.delivered) {
      throw Exception('Impossible d\'annuler une commande déjà livrée');
    }

    if (order.status == OrderStatus.inTransit) {
      throw Exception('Impossible d\'annuler une commande en cours de livraison');
    }

    await _communication.cancelOrder(
      orderId,
      clientId,
      UserRole.client,
      'Annulation par le client',
    );
  }

  // Client suit sa commande
  Future<Order> trackOrder(String orderId, String clientId) async {
    final orders = await _database.getOrders(userId: clientId, role: UserRole.client);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.clientId != clientId) {
      throw Exception('Commande non trouvée');
    }

    return order;
  }

  // === FONCTIONNALITÉS VENDEUR ===

  // Vendeur obtient ses commandes
  Future<List<Order>> getVendorOrders(String vendorId) async {
    return await _database.getOrders(userId: vendorId, role: UserRole.vendor);
  }

  // Vendeur confirme une commande
  Future<void> confirmOrder(String orderId, String vendorId) async {
    final orders = await _database.getOrders(userId: vendorId, role: UserRole.vendor);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.vendorId != vendorId) {
      throw Exception('Commande non trouvée');
    }

    if (order.status != OrderStatus.pending) {
      throw Exception('Cette commande ne peut plus être confirmée');
    }

    await _communication.confirmOrder(orderId, vendorId);
  }

  // Vendeur commence la préparation
  Future<void> startPreparation(String orderId, String vendorId) async {
    final orders = await _database.getOrders(userId: vendorId, role: UserRole.vendor);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.vendorId != vendorId) {
      throw Exception('Commande non trouvée');
    }

    if (order.status != OrderStatus.confirmed) {
      throw Exception('La commande doit être confirmée avant la préparation');
    }

    await _communication.prepareOrder(orderId, vendorId);
  }

  // Vendeur marque la commande comme prête
  Future<void> markOrderReady(String orderId, String vendorId) async {
    final orders = await _database.getOrders(userId: vendorId, role: UserRole.vendor);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.vendorId != vendorId) {
      throw Exception('Commande non trouvée');
    }

    if (order.status != OrderStatus.preparing) {
      throw Exception('La commande doit être en préparation');
    }

    await _communication.markOrderReady(orderId, vendorId);
  }

  // Vendeur annule une commande
  Future<void> vendorCancelOrder(String orderId, String vendorId, String reason) async {
    final orders = await _database.getOrders(userId: vendorId, role: UserRole.vendor);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.vendorId != vendorId) {
      throw Exception('Commande non trouvée');
    }

    if (order.status == OrderStatus.delivered) {
      throw Exception('Impossible d\'annuler une commande déjà livrée');
    }

    if (order.status == OrderStatus.inTransit) {
      throw Exception('Impossible d\'annuler une commande en cours de livraison');
    }

    await _communication.cancelOrder(orderId, vendorId, UserRole.vendor, reason);
  }

  // === FONCTIONNALITÉS LIVREUR ===

  // Livreur obtient les commandes disponibles
  Future<List<Order>> getAvailableOrders() async {
    final orders = await _database.getOrders();
    return orders.where((order) => 
      order.status == OrderStatus.readyForPickup && 
      order.deliveryPersonId == null
    ).toList();
  }

  // Livreur obtient ses commandes assignées
  Future<List<Order>> getDeliveryPersonOrders(String deliveryPersonId) async {
    return await _database.getOrders(userId: deliveryPersonId, role: UserRole.delivery);
  }

  // Livreur accepte une livraison
  Future<void> acceptDelivery(String orderId, String deliveryPersonId) async {
    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    
    if (order.status != OrderStatus.readyForPickup) {
      throw Exception('Cette commande n\'est pas prête pour la livraison');
    }

    if (order.deliveryPersonId != null) {
      throw Exception('Cette commande a déjà été assignée à un livreur');
    }

    await _communication.acceptDelivery(orderId, deliveryPersonId);
  }

  // Livreur commence la livraison
  Future<void> startDelivery(String orderId, String deliveryPersonId) async {
    final orders = await _database.getOrders(userId: deliveryPersonId, role: UserRole.delivery);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.deliveryPersonId != deliveryPersonId) {
      throw Exception('Cette commande ne vous est pas assignée');
    }

    if (order.status != OrderStatus.readyForPickup) {
      throw Exception('Cette commande n\'est pas prête pour la livraison');
    }

    await _communication.startDelivery(orderId, deliveryPersonId);
  }

  // Livreur marque la commande comme livrée
  Future<void> completeDelivery(String orderId, String deliveryPersonId) async {
    final orders = await _database.getOrders(userId: deliveryPersonId, role: UserRole.delivery);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    if (order.deliveryPersonId != deliveryPersonId) {
      throw Exception('Cette commande ne vous est pas assignée');
    }

    if (order.status != OrderStatus.inTransit) {
      throw Exception('Cette commande n\'est pas en cours de livraison');
    }

    await _communication.completeDelivery(orderId, deliveryPersonId);
  }

  // Livreur signale un problème
  Future<void> reportIssue(String orderId, String deliveryPersonId, String issue) async {
    final orders = await _database.getOrders(userId: deliveryPersonId, role: UserRole.delivery);
    final order = orders.firstWhere((o) => o.id == orderId);
    
    // Notifier le client et le vendeur via une méthode publique
    // Note: En pratique, il faudrait ajouter une méthode publique dans CommunicationService
    // Pour l'instant, nous allons utiliser une approche alternative
    print('Problème signalé pour la commande ${order.id}: $issue');
    
    // Simuler une notification (en pratique, utiliser une méthode publique)
    ScaffoldMessenger.of(/*context*/).showSnackBar(
      SnackBar(
        content: Text('Problème signalé: $issue'),
        backgroundColor: DonMTheme.erreurDonM,
      ),
    );
  }

  // === FONCTIONNALITÉS COMMUNES ===

  // Obtenir les détails d'une commande
  Future<Order> getOrderDetails(String orderId) async {
    final orders = await _database.getOrders();
    try {
      return orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      throw Exception('Commande non trouvée');
    }
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

  Stream<List<NotificationEvent>> getNotificationStream(String userId) {
    return _communication.getUserNotifications(userId);
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
        case OrderStatus.pending:
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case OrderStatus.confirmed:
          stats['confirmed'] = (stats['confirmed'] ?? 0) + 1;
          break;
        case OrderStatus.preparing:
          stats['preparing'] = (stats['preparing'] ?? 0) + 1;
          break;
        case OrderStatus.readyForPickup:
          stats['ready'] = (stats['ready'] ?? 0) + 1;
          break;
        case OrderStatus.inTransit:
          stats['inTransit'] = (stats['inTransit'] ?? 0) + 1;
          break;
        case OrderStatus.delivered:
          stats['delivered'] = (stats['delivered'] ?? 0) + 1;
          break;
        case OrderStatus.cancelled:
          stats['cancelled'] = (stats['cancelled'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  // Nettoyage
  void dispose() {
    _database.dispose();
    _communication.dispose();
  }
}
