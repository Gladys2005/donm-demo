import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main_simple.dart';

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  bool _isLoading = false;
  String _status = 'En attente de test...';
  List<User> _users = [];
  List<Product> _products = [];
  List<Order> _orders = [];
  List<User> _deliveryPersons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Base de Données'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton de test principal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test de Connexion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _runFullTest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DonMTheme.vertDonM,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Lancer le test complet'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testApiHealth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DonMTheme.jauneDonM,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('API Health'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistiques
            if (_users.isNotEmpty || _products.isNotEmpty || _orders.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistiques',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '${_users.length}',
                              'Utilisateurs',
                              Icons.people,
                              DonMTheme.vertDonM,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              '${_products.length}',
                              'Produits',
                              Icons.shopping_cart,
                              DonMTheme.jauneDonM,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '${_orders.length}',
                              'Commandes',
                              Icons.receipt,
                              DonMTheme.infoDonM,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              '${_deliveryPersons.length}',
                              'Livreurs',
                              Icons.delivery_dining,
                              DonMTheme.succesDonM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Liste des utilisateurs
            if (_users.isNotEmpty) ...[
              const Text(
                'Utilisateurs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._users.map((user) => _buildUserCard(user)).toList(),
              const SizedBox(height: 16),
            ],
            
            // Liste des produits
            if (_products.isNotEmpty) ...[
              const Text(
                'Produits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._products.map((product) => _buildProductCard(product)).toList(),
              const SizedBox(height: 16),
            ],
            
            // Liste des commandes
            if (_orders.isNotEmpty) ...[
              const Text(
                'Commandes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._orders.map((order) => _buildOrderCard(order)).toList(),
              const SizedBox(height: 16),
            ],
            
            // Liste des livreurs disponibles
            if (_deliveryPersons.isNotEmpty) ...[
              const Text(
                'Livreurs Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._deliveryPersons.map((deliveryPerson) => _buildDeliveryPersonCard(deliveryPerson)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: DonMTheme.vertDonM,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.name),
        subtitle: Text('${user.role.toString().split('.').last} - ${user.phone}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text('${user.rating}'),
              ],
            ),
            if (user.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: DonMTheme.succesDonM,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Disponible',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DonMTheme.jauneDonM.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant,
            color: DonMTheme.jauneDonM,
          ),
        ),
        title: Text(product.name),
        subtitle: Text(product.category),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.price.toInt()} FCFA',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (product.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: DonMTheme.succesDonM,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Disponible',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DonMTheme.infoDonM.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt,
            color: DonMTheme.infoDonM,
          ),
        ),
        title: Text(order.trackingCode ?? 'N/A'),
        subtitle: Text('${order.distance} km - ${order.price.toInt()} FCFA'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _getStatusDisplayName(order.status),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryPersonCard(User deliveryPerson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: DonMTheme.succesDonM,
          child: const Icon(
            Icons.delivery_dining,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(deliveryPerson.name),
        subtitle: Text('${deliveryPerson.vehicleType ?? 'N/A'} - ${deliveryPerson.currentLocation ?? 'N/A'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text('${deliveryPerson.rating}'),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'in_transit':
        return DonMTheme.vertDonM;
      case 'delivered':
        return DonMTheme.succesDonM;
      case 'cancelled':
        return DonMTheme.erreurDonM;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'Préparation';
      case 'ready':
        return 'Prête';
      case 'in_transit':
        return 'Livraison';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  Future<void> _testApiHealth() async {
    setState(() {
      _isLoading = true;
      _status = 'Test de santé de l\'API...';
    });

    try {
      bool isHealthy = await ApiService.checkHealth();
      setState(() {
        _status = isHealthy 
            ? 'API DonM fonctionne parfaitement !' 
            : 'API DonM injoignable';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runFullTest() async {
    setState(() {
      _isLoading = true;
      _status = 'Test complet en cours...';
      _users.clear();
      _products.clear();
      _orders.clear();
      _deliveryPersons.clear();
    });

    try {
      // 1. Test de santé
      bool isHealthy = await ApiService.checkHealth();
      if (!isHealthy) {
        throw Exception('API non disponible');
      }

      // 2. Test des utilisateurs
      setState(() {
        _status = 'Chargement des utilisateurs...';
      });
      List<User> users = await ApiService.getUsers();
      
      // 3. Test des produits
      setState(() {
        _status = 'Chargement des produits...';
      });
      List<Product> products = await ApiService.getProducts();
      
      // 4. Test des commandes
      setState(() {
        _status = 'Chargement des commandes...';
      });
      List<Order> orders = await ApiService.getOrders();
      
      // 5. Test des livreurs disponibles
      setState(() {
        _status = 'Chargement des livreurs disponibles...';
      });
      List<User> deliveryPersons = await ApiService.getAvailableDeliveryPersons();

      setState(() {
        _users = users;
        _products = products;
        _orders = orders;
        _deliveryPersons = deliveryPersons;
        _status = 'Test complet réussi !';
      });

    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
