import 'dart:async';
import '../main_simple.dart';

// Service d'authentification simplifié compatible avec les modèles existants
class AuthServiceSimple {
  static final AuthServiceSimple _instance = AuthServiceSimple._internal();
  factory AuthServiceSimple() => _instance;
  AuthServiceSimple._internal();

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
    final users = _getDemoUsers();
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
    final users = _getDemoUsers();
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
      status: role == UserRole.client ? UserStatus.active : UserStatus.pending,
      memberSince: DateTime.now(),
      kycLevel: role == UserRole.delivery ? 'PENDING' : 'NONE',
      rating: 0.0,
    );

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

    // Créer une copie avec le nouveau statut KYC
    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phone: _currentUser!.phone,
      role: _currentUser!.role,
      status: _currentUser!.status,
      memberSince: _currentUser!.memberSince,
      kycLevel: kycLevel,
      rating: _currentUser!.rating,
    );
    _userController.add(_currentUser);
  }

  // Mettre à jour le statut du compte
  Future<void> updateAccountStatus(UserStatus status) async {
    if (_currentUser == null) throw Exception('Utilisateur non connecté');

    // Créer une copie avec le nouveau statut
    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phone: _currentUser!.phone,
      role: _currentUser!.role,
      status: status,
      memberSince: _currentUser!.memberSince,
      kycLevel: _currentUser!.kycLevel,
      rating: _currentUser!.rating,
    );
    _userController.add(_currentUser);
  }

  // Obtenir les utilisateurs de démonstration
  List<User> _getDemoUsers() {
    return [
      User(
        id: '1',
        name: 'Jean Kouadio',
        email: 'client@donm.ci',
        phone: '+225 07 00 00 00 00',
        role: UserRole.client,
        status: UserStatus.active,
        memberSince: DateTime.now().subtract(const Duration(days: 730)),
        kycLevel: 'NONE',
        rating: 4.8,
      ),
      User(
        id: '2',
        name: 'Marie Konan',
        email: 'vendeur@donm.ci',
        phone: '+225 07 01 01 01 01',
        role: UserRole.vendor,
        status: UserStatus.active,
        memberSince: DateTime.now().subtract(const Duration(days: 365)),
        kycLevel: 'NONE',
        rating: 4.9,
      ),
      User(
        id: '3',
        name: 'Paul Yapo',
        email: 'livreur@donm.ci',
        phone: '+225 07 02 02 02 02',
        role: UserRole.delivery,
        status: UserStatus.active,
        memberSince: DateTime.now().subtract(const Duration(days: 180)),
        kycLevel: 'VERIFIED',
        rating: 4.7,
      ),
      // Utilisateurs en attente pour la démo
      User(
        id: '4',
        name: 'Vendeur En Attente',
        email: 'vendeur_pending@donm.ci',
        phone: '+225 07 03 03 03 03',
        role: UserRole.vendor,
        status: UserStatus.pending,
        memberSince: DateTime.now(),
        kycLevel: 'NONE',
        rating: 0.0,
      ),
      User(
        id: '5',
        name: 'Livreur KYC Pending',
        email: 'livreur_pending@donm.ci',
        phone: '+225 07 04 04 04 04',
        role: UserRole.delivery,
        status: UserStatus.active,
        memberSince: DateTime.now(),
        kycLevel: 'PENDING',
        rating: 0.0,
      ),
    ];
  }

  // Nettoyage
  void dispose() {
    _userController.close();
  }
}
