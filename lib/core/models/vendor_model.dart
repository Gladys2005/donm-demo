class Vendor {
  final int userId;
  final String shopName;
  final String activityType;
  final String location;
  final List<Product> products;
  final List<Order> orders;

  Vendor({
    required this.userId,
    required this.shopName,
    required this.activityType,
    required this.location,
    required this.products,
    required this.orders,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      userId: json['user_id'],
      shopName: json['shop_name'],
      activityType: json['activity_type'],
      location: json['location'],
      products: (json['products'] as List<dynamic>?)
          ?.map((product) => Product.fromJson(product))
          .toList() ?? [],
      orders: (json['orders'] as List<dynamic>?)
          ?.map((order) => Order.fromJson(order))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'shop_name': shopName,
      'activity_type': activityType,
      'location': location,
      'products': products.map((product) => product.toJson()).toList(),
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'],
      isAvailable: json['is_available'] ?? false,
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'is_available': isAvailable,
      'images': images,
    };
  }
}
