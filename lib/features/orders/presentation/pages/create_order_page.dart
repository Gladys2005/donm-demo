import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/donm_theme.dart';
import '../../../../widgets/donm_logo.dart';
import '../../../../widgets/donm_branding.dart';
import '../../../../core/services/location_service.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedType = 'delivery';
  String _selectedSize = 'medium';
  double _estimatedPrice = 0.0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _orderTypes = [
    {
      'id': 'delivery',
      'name': 'Livraison',
      'icon': Icons.local_shipping,
      'description': 'Livraison standard',
      'basePrice': 1500,
    },
    {
      'id': 'express',
      'name': 'Express',
      'icon': Icons.flash_on,
      'description': 'Livraison express',
      'basePrice': 2500,
    },
    {
      'id': 'course',
      'name': 'Course',
      'icon': Icons.motorcycle,
      'description': 'Course personnalisée',
      'basePrice': 2000,
    },
  ];

  final List<Map<String, dynamic>> _packageSizes = [
    {
      'id': 'small',
      'name': 'Petit',
      'description': 'Documents, petits objets',
      'multiplier': 1.0,
    },
    {
      'id': 'medium',
      'name': 'Moyen',
      'description': 'Colis moyens',
      'multiplier': 1.5,
    },
    {
      'id': 'large',
      'name': 'Grand',
      'description': 'Grands colis',
      'multiplier': 2.0,
    },
    {
      'id': 'xlarge',
      'name': 'Très grand',
      'description': 'Colis volumineux',
      'multiplier': 2.5,
    },
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    final selectedType = _orderTypes.firstWhere(
      (type) => type['id'] == _selectedType,
    );
    final selectedSize = _packageSizes.firstWhere(
      (size) => size['id'] == _selectedSize,
    );
    
    final basePrice = selectedType['basePrice'] as double;
    final multiplier = selectedSize['multiplier'] as double;
    
    setState(() {
      _estimatedPrice = basePrice * multiplier;
    });
  }

  void _createOrder() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simuler la création de commande
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Commande créée avec succès!'),
              backgroundColor: DonMTheme.succesDonM,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: DonMTheme.erreurDonM,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonMTheme.blancDonM,
      appBar: AppBar(
        backgroundColor: DonMTheme.blancDonM,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Nouvelle commande',
          style: TextStyle(
            color: DonMTheme.noirDonM,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Historique des commandes
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête avec prix estimé
              DonMBranding.getDonMCard(
                child: Row(
                  children: [
                    DonMCircularLogo(size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prix estimé',
                            style: TextStyle(
                              fontSize: 14,
                              color: DonMTheme.grisDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            '${_estimatedPrice.toInt()} FCFA',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: DonMTheme.orangeDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Type de livraison
              const Text(
                'Type de livraison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _orderTypes.length,
                  itemBuilder: (context, index) {
                    final type = _orderTypes[index];
                    final isSelected = type['id'] == _selectedType;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = type['id'];
                          _calculatePrice();
                        });
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? DonMTheme.gradientPrincipal
                              : null,
                          color: isSelected 
                              ? null 
                              : DonMTheme.grisClairDonM,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.transparent 
                                : DonMTheme.grisDonM!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type['icon'],
                              color: isSelected 
                                  ? Colors.white 
                                  : DonMTheme.orangeDonM,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              type['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? Colors.white 
                                    : DonMTheme.noirDonM,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Taille du colis
              const Text(
                'Taille du colis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _packageSizes.length,
                itemBuilder: (context, index) {
                  final size = _packageSizes[index];
                  final isSelected = size['id'] == _selectedSize;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSize = size['id'];
                        _calculatePrice();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected 
                            ? DonMTheme.gradientVert
                            : null,
                        color: isSelected 
                            ? null 
                            : DonMTheme.grisClairDonM,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? Colors.transparent 
                              : DonMTheme.grisDonM!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            size['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? Colors.white 
                                  : DonMTheme.noirDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            size['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                  ? Colors.white.withOpacity(0.8) 
                                  : DonMTheme.grisDonM,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Adresse de livraison
              DonMBranding.getDonMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adresse de livraison',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse complète',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        hintText: 'Entrez l\'adresse de livraison',
                        suffixIcon: Icon(Icons.map_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adresse requise';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Informations du destinataire
              DonMBranding.getDonMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations du destinataire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du destinataire',
                        prefixIcon: Icon(Icons.person_outlined),
                        hintText: 'Entrez le nom du destinataire',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nom du destinataire requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+225 XX XX XX XX XX',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Téléphone requis';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              DonMBranding.getDonMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description du colis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Décrivez le contenu du colis...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes supplémentaires (optionnel)',
                        hintText: 'Instructions spéciales...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bouton de création
              DonMBranding.getDonMButton(
                text: 'Créer la commande',
                onPressed: _createOrder,
                isLoading: _isLoading,
                width: double.infinity,
                height: 50,
                icon: Icons.check_circle,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
