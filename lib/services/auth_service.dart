import 'dart:async';
import '../main_simple.dart';

// Service d'authentification
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final StreamController<User?> _userController = StreamController.broadcast();

  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Connexion
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simuler réseau

    // Simuler la validation des identifiants
    final users = await _getUsers();
    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Email ou mot de passe incorrect'),
    );

    // Simuler la validation du mot de passe
    if (password != 'password123') {
      throw Exception('Email ou mot de passe incorrect');
    }

    _currentUser = user;
    _userController.add(_currentUser);

    return user;
  }

  // Inscription
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simuler réseau

    // Vérifier si l'email existe déjà
    final users = await _getUsers();
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Cet email est déjà utilisé');
    }

    // Créer le nouvel utilisateur
    final newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      status: UserStatus.pending, // En attente de validation
      rating: 0.0,
      memberSince: DateTime.now(),
      kycLevel: role == UserRole.delivery ? 'PENDING' : 'NONE',
    );

    // Ajouter à la base de données simulée
    users.add(newUser);

    _currentUser = newUser;
    _userController.add(_currentUser);

    return newUser;
  }

  // Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    _userController.add(null);
  }

  // Vérifier si l'utilisateur peut accéder à un rôle
  bool canAccessRole(UserRole role) {
    if (_currentUser == null) return false;

    // Le client peut toujours accéder
    if (role == UserRole.client) return true;

    // Le vendeur doit être connecté et validé
    if (role == UserRole.vendor) {
      return _currentUser!.role == role && _currentUser!.status == UserStatus.active;
    }

    // Le livreur doit être connecté, validé et avoir complété le KYC
    if (role == UserRole.delivery) {
      return _currentUser!.role == role && 
             _currentUser!.status == UserStatus.active && 
             _currentUser!.kycLevel == 'VERIFIED';
    }

    return false;
  }

  // Vérifier si le KYC est requis
  bool needsKyc() {
    if (_currentUser == null) return false;
    return _currentUser!.role == UserRole.delivery && 
           _currentUser!.kycLevel != 'VERIFIED';
  }

  // Vérifier si le compte est en attente de validation
  bool isPendingValidation() {
    if (_currentUser == null) return false;
    return _currentUser!.status == UserStatus.pending;
  }

  // Mettre à jour le statut KYC
  Future<void> updateKycStatus(String kycLevel) async {
    if (_currentUser == null) throw Exception('Utilisateur non connecté');

    _currentUser = _currentUser!.copyWith(kycLevel: kycLevel);
    _userController.add(_currentUser);
  }

  // Mettre à jour le statut du compte
  Future<void> updateAccountStatus(UserStatus status) async {
    if (_currentUser == null) throw Exception('Utilisateur non connecté');

    _currentUser = _currentUser!.copyWith(status: status);
    _userController.add(_currentUser);
  }

  // Obtenir les utilisateurs (simulation)
  Future<List<User>> _getUsers() async {
    // Simuler une base de données d'utilisateurs
    return [
      User(
        id: '1',
        name: 'Jean Kouadio',
        email: 'client@donm.ci',
        phone: '+225 07 00 00 00 00',
        role: UserRole.client,
        status: UserStatus.active,
        rating: 4.8,
        memberSince: DateTime.now().subtract(const Duration(days: 730)),
        kycLevel: 'NONE',
      ),
      User(
        id: '2',
        name: 'Marie Konan',
        email: 'vendeur@donm.ci',
        phone: '+225 07 01 01 01 01',
        role: UserRole.vendor,
        status: UserStatus.active,
        rating: 4.9,
        memberSince: DateTime.now().subtract(const Duration(days: 365)),
        kycLevel: 'NONE',
        shopName: 'Boutique Marie',
        shopAddress: 'Abidjan, Cocody',
      ),
      User(
        id: '3',
        name: 'Paul Yapo',
        email: 'livreur@donm.ci',
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
      // Utilisateurs en attente pour la démo
      User(
        id: '4',
        name: 'Vendeur En Attente',
        email: 'vendeur_pending@donm.ci',
        phone: '+225 07 03 03 03 03',
        role: UserRole.vendor,
        status: UserStatus.pending,
        rating: 0.0,
        memberSince: DateTime.now(),
        kycLevel: 'NONE',
        shopName: 'Boutitude Test',
        shopAddress: 'Abidjan, Yopougon',
      ),
      User(
        id: '5',
        name: 'Livreur KYC Pending',
        email: 'livreur_pending@donm.ci',
        phone: '+225 07 04 04 04 04',
        role: UserRole.delivery,
        status: UserStatus.active,
        rating: 0.0,
        memberSince: DateTime.now(),
        kycLevel: 'PENDING',
        deliveryLevel: DeliveryLevel.beginner,
        currentLocation: 'Abidjan, Treichville',
        isAvailable: false,
      ),
    ];
  }

  // Nettoyage
  void dispose() {
    _userController.close();
  }
}

// Extension pour copier les utilisateurs
extension UserCopyWith on User {
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    double? rating,
    DateTime? memberSince,
    String? kycLevel,
    String? shopName,
    String? shopAddress,
    DeliveryLevel? deliveryLevel,
    String? currentLocation,
    bool? isAvailable,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      memberSince: memberSince ?? this.memberSince,
      kycLevel: kycLevel ?? this.kycLevel,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      deliveryLevel: deliveryLevel ?? this.deliveryLevel,
      currentLocation: currentLocation ?? this.currentLocation,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
