enum UserRole {
  client,
  vendor,
  delivery,
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
}

enum DeliveryLevel {
  classique,
  certifie,
  certifiePlus,
  assure,
}

class User {
  final int id;
  final String phone;
  final String email;
  final String name;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.phone,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == json['role'],
        orElse: () => UserRole.client,
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'role': role.toString(),
      'status': status.toString(),
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  User copyWith({
    int? id,
    String? phone,
    String? email,
    String? name,
    UserRole? role,
    UserStatus? status,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, role: $role, status: $status)';
  }
}
