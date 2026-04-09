class Client {
  final int userId;
  final List<String> addresses;
  final List<PaymentMethod> paymentMethods;
  final List<Order> orders;

  Client({
    required this.userId,
    required this.addresses,
    required this.paymentMethods,
    required this.orders,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      userId: json['user_id'],
      addresses: List<String>.from(json['addresses'] ?? []),
      paymentMethods: (json['payment_methods'] as List<dynamic>?)
          ?.map((method) => PaymentMethod.fromJson(method))
          .toList() ?? [],
      orders: (json['orders'] as List<dynamic>?)
          ?.map((order) => Order.fromJson(order))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'addresses': addresses,
      'payment_methods': paymentMethods.map((method) => method.toJson()).toList(),
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      last4: json['last4'],
      isDefault: json['is_default'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'is_default': isDefault,
    };
  }
}

class Order {
  final String id;
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
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.price,
    required this.status,
    required this.createdAt,
    this.deliveryPersonId,
    this.trackingCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      pickupAddress: json['pickup_address'],
      deliveryAddress: json['delivery_address'],
      distance: (json['distance'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      deliveryPersonId: json['delivery_person_id'],
      trackingCode: json['tracking_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'distance': distance,
      'price': price,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'delivery_person_id': deliveryPersonId,
      'tracking_code': trackingCode,
    };
  }
}
