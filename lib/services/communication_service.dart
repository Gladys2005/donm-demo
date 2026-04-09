import 'dart:async';
import '../main_simple.dart';
import 'database_service.dart';

// Service de communication entre les rôles
class CommunicationService {
  static final CommunicationService _instance = CommunicationService._internal();
  factory CommunicationService() => _instance;
  CommunicationService._internal();

  final DatabaseService _database = DatabaseService();
  final StreamController<NotificationEvent> _notificationController = StreamController.broadcast();

  Stream<NotificationEvent> get notificationStream => _notificationController.stream;

  // Client passe une commande
  Future<Order> placeOrder({
    required String clientId,
    required String vendorId,
    required List<OrderItem> items,
    required String deliveryAddress,
    required String pickupAddress,
  }) async {
    // Calculer le montant total
    double totalAmount = items.fold(0, (sum, item) => sum + (item.price * item.quantity));
    double deliveryFee = 2000; // Frais de livraison fixes pour la démo

    final order = Order(
      id: '', // Sera généré dans la base de données
      clientId: clientId,
      vendorId: vendorId,
      items: items,
      deliveryAddress: deliveryAddress,
      pickupAddress: pickupAddress,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
    );

    final createdOrder = await _database.createOrder(order);

    // Notifier le vendeur
    _sendNotification(
      userId: vendorId,
      title: 'Nouvelle commande reçue',
      message: 'Commande ${createdOrder.id} - Montant: ${totalAmount} FCFA',
      type: NotificationType.newOrder,
      orderId: createdOrder.id,
    );

    // Notifier les livreurs disponibles
    final deliveryPersons = await _database.getAvailableDeliveryPersons();
    for (final deliveryPerson in deliveryPersons) {
      _sendNotification(
        userId: deliveryPerson.id,
        title: 'Nouvelle livraison disponible',
        message: 'Commande ${createdOrder.id} - ${deliveryAddress}',
        type: NotificationType.newDeliveryAvailable,
        orderId: createdOrder.id,
      );
    }

    return createdOrder;
  }

  // Vendeur confirme une commande
  Future<void> confirmOrder(String orderId, String vendorId) async {
    await _database.updateOrderStatus(orderId, OrderStatus.confirmed);

    // Notifier le client
    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    _sendNotification(
      userId: order.clientId,
      title: 'Commande confirmée',
      message: 'Votre commande ${orderId} a été confirmée par le vendeur',
      type: NotificationType.orderConfirmed,
      orderId: orderId,
    );

    // Notifier les livreurs
    final deliveryPersons = await _database.getAvailableDeliveryPersons();
    for (final deliveryPerson in deliveryPersons) {
      _sendNotification(
        userId: deliveryPerson.id,
        title: 'Commande prête pour livraison',
        message: 'Commande ${orderId} - Prête à être récupérée',
        type: NotificationType.readyForPickup,
        orderId: orderId,
      );
    }
  }

  // Vendeur prépare la commande
  Future<void> prepareOrder(String orderId, String vendorId) async {
    await _database.updateOrderStatus(orderId, OrderStatus.preparing);

    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    _sendNotification(
      userId: order.clientId,
      title: 'Commande en préparation',
      message: 'Votre commande ${orderId} est en cours de préparation',
      type: NotificationType.orderPreparing,
      orderId: orderId,
    );
  }

  // Vendeur marque la commande comme prête
  Future<void> markOrderReady(String orderId, String vendorId) async {
    await _database.updateOrderStatus(orderId, OrderStatus.readyForPickup);

    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    
    // Notifier le client
    _sendNotification(
      userId: order.clientId,
      title: 'Commande prête',
      message: 'Votre commande ${orderId} est prête pour la livraison',
      type: NotificationType.orderReady,
      orderId: orderId,
    );

    // Notifier les livreurs disponibles
    final deliveryPersons = await _database.getAvailableDeliveryPersons();
    for (final deliveryPerson in deliveryPersons) {
      _sendNotification(
        userId: deliveryPerson.id,
        title: 'Commande disponible pour livraison',
        message: 'Commande ${orderId} - ${order.pickupAddress}',
        type: NotificationType.readyForPickup,
        orderId: orderId,
      );
    }
  }

  // Livreur accepte une livraison
  Future<void> acceptDelivery(String orderId, String deliveryPersonId) async {
    await _database.assignDeliveryPerson(orderId, deliveryPersonId);

    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    
    // Notifier le client
    _sendNotification(
      userId: order.clientId,
      title: 'Livreur assigné',
      message: 'Un livreur a été assigné à votre commande ${orderId}',
      type: NotificationType.deliveryAssigned,
      orderId: orderId,
    );

    // Notifier le vendeur
    _sendNotification(
      userId: order.vendorId,
      title: 'Livreur en route',
      message: 'Le livreur est en route pour récupérer la commande ${orderId}',
      type: NotificationType.deliveryAssigned,
      orderId: orderId,
    );
  }

  // Livreur marque la commande comme en transit
  Future<void> startDelivery(String orderId, String deliveryPersonId) async {
    await _database.updateOrderStatus(orderId, OrderStatus.inTransit);

    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    
    // Notifier le client
    _sendNotification(
      userId: order.clientId,
      title: 'Livraison en cours',
      message: 'Votre commande ${orderId} est en cours de livraison',
      type: NotificationType.deliveryInProgress,
      orderId: orderId,
    );
  }

  // Livreur marque la commande comme livrée
  Future<void> completeDelivery(String orderId, String deliveryPersonId) async {
    await _database.updateOrderStatus(orderId, OrderStatus.delivered);

    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    
    // Notifier le client
    _sendNotification(
      userId: order.clientId,
      title: 'Commande livrée',
      message: 'Votre commande ${orderId} a été livrée avec succès',
      type: NotificationType.orderDelivered,
      orderId: orderId,
    );

    // Notifier le vendeur
    _sendNotification(
      userId: order.vendorId,
      title: 'Livraison terminée',
      message: 'La commande ${orderId} a été livrée',
      type: NotificationType.orderDelivered,
      orderId: orderId,
    );
  }

  // Annuler une commande
  Future<void> cancelOrder(String orderId, String userId, UserRole userRole, String reason) async {
    await _database.updateOrderStatus(orderId, OrderStatus.cancelled);

    final order = (await _database.getOrders()).firstWhere((o) => o.id == orderId);
    
    // Notifier toutes les parties concernées
    final recipients = [order.clientId, order.vendorId];
    if (order.deliveryPersonId != null) {
      recipients.add(order.deliveryPersonId!);
    }

    for (final recipient in recipients) {
      if (recipient != userId) { // Ne pas notifier l'utilisateur qui a annulé
        _sendNotification(
          userId: recipient,
          title: 'Commande annulée',
          message: 'La commande ${orderId} a été annulée: $reason',
          type: NotificationType.orderCancelled,
          orderId: orderId,
        );
      }
    }
  }

  // Notifier un utilisateur
  void _sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    required String orderId,
  }) {
    final notification = NotificationEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      message: message,
      type: type,
      orderId: orderId,
      timestamp: DateTime.now(),
    );

    _notificationController.add(notification);
  }

  // Obtenir les notifications pour un utilisateur
  Stream<List<NotificationEvent>> getUserNotifications(String userId) {
    return _notificationController.stream
        .where((notification) => notification.userId == userId)
        .fold<List<NotificationEvent>>([], (previous, notification) {
      final updated = List<NotificationEvent>.from(previous);
      updated.add(notification);
      // Garder seulement les 50 dernières notifications
      if (updated.length > 50) {
        updated.removeAt(0);
      }
      return updated;
    });
  }

  // Nettoyage
  void dispose() {
    _notificationController.close();
  }
}

// Événement de notification
class NotificationEvent {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String orderId;
  final DateTime timestamp;

  NotificationEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.orderId,
    required this.timestamp,
  });
}

// Types de notifications
enum NotificationType {
  newOrder,
  orderConfirmed,
  orderPreparing,
  orderReady,
  deliveryAssigned,
  deliveryInProgress,
  orderDelivered,
  orderCancelled,
  newDeliveryAvailable,
  readyForPickup,
}

// Extension pour les types de notification
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.newOrder:
        return 'Nouvelle commande';
      case NotificationType.orderConfirmed:
        return 'Commande confirmée';
      case NotificationType.orderPreparing:
        return 'Commande en préparation';
      case NotificationType.orderReady:
        return 'Commande prête';
      case NotificationType.deliveryAssigned:
        return 'Livreur assigné';
      case NotificationType.deliveryInProgress:
        return 'Livraison en cours';
      case NotificationType.orderDelivered:
        return 'Commande livrée';
      case NotificationType.orderCancelled:
        return 'Commande annulée';
      case NotificationType.newDeliveryAvailable:
        return 'Nouvelle livraison disponible';
      case NotificationType.readyForPickup:
        return 'Prête pour retrait';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.newOrder:
      case NotificationType.newDeliveryAvailable:
        return 'assets/icons/new_order.png';
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
        return 'assets/icons/preparing.png';
      case NotificationType.orderReady:
      case NotificationType.readyForPickup:
        return 'assets/icons/ready.png';
      case NotificationType.deliveryAssigned:
      case NotificationType.deliveryInProgress:
        return 'assets/icons/delivery.png';
      case NotificationType.orderDelivered:
        return 'assets/icons/delivered.png';
      case NotificationType.orderCancelled:
        return 'assets/icons/cancelled.png';
    }
  }
}
