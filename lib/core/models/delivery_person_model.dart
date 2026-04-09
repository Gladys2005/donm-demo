class DeliveryPerson {
  final int userId;
  final DeliveryLevel level;
  final String vehicleType;
  final List<String> documents;
  final double rating;
  final bool isAvailable;
  final bool isVerified;
  final List<Order> completedOrders;
  final List<Order> currentOrders;

  DeliveryPerson({
    required this.userId,
    required this.level,
    required this.vehicleType,
    required this.documents,
    required this.rating,
    required this.isAvailable,
    required this.isVerified,
    required this.completedOrders,
    required this.currentOrders,
  });

  factory DeliveryPerson.fromJson(Map<String, dynamic> json) {
    return DeliveryPerson(
      userId: json['user_id'],
      level: DeliveryLevel.values.firstWhere(
        (level) => level.toString() == json['level'],
        orElse: () => DeliveryLevel.classique,
      ),
      vehicleType: json['vehicle_type'],
      documents: List<String>.from(json['documents'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      isVerified: json['is_verified'] ?? false,
      completedOrders: (json['completed_orders'] as List<dynamic>?)
          ?.map((order) => Order.fromJson(order))
          .toList() ?? [],
      currentOrders: (json['current_orders'] as List<dynamic>?)
          ?.map((order) => Order.fromJson(order))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'level': level.toString(),
      'vehicle_type': vehicleType,
      'documents': documents,
      'rating': rating,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'completed_orders': completedOrders.map((order) => order.toJson()).toList(),
      'current_orders': currentOrders.map((order) => order.toJson()).toList(),
    };
  }

  DeliveryPerson copyWith({
    int? userId,
    DeliveryLevel? level,
    String? vehicleType,
    List<String>? documents,
    double? rating,
    bool? isAvailable,
    bool? isVerified,
    List<Order>? completedOrders,
    List<Order>? currentOrders,
  }) {
    return DeliveryPerson(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      vehicleType: vehicleType ?? this.vehicleType,
      documents: documents ?? this.documents,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      completedOrders: completedOrders ?? this.completedOrders,
      currentOrders: currentOrders ?? this.currentOrders,
    );
  }

  @override
  String toString() {
    return 'DeliveryPerson(userId: $userId, level: $level, rating: $rating)';
  }
}
