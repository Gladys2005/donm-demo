import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../main_simple.dart';

class PaymentPage extends StatefulWidget {
  final Order order;
  final double amount;

  const PaymentPage({
    super.key,
    required this.order,
    required this.amount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;
  String _selectedMethod = 'mobile_money';
  final _phoneNumberController = TextEditingController();
  final _operatorController = TextEditingController(text: 'orange');
  bool _paymentSuccess = false;
  String? _transactionId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le numéro de l'utilisateur connecté
    _loadUserPhone();
  }

  void _loadUserPhone() async {
    try {
      final authService = AuthServiceSimple();
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        setState(() {
          _phoneNumberController.text = currentUser.phone;
        });
      }
    } catch (e) {
      print('Erreur chargement téléphone utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: DonMTheme.vertDonM,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _paymentSuccess ? _buildSuccessView() : _buildPaymentForm(),
    );
  }

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé de la commande
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé de la commande',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Code de suivi',
                    widget.order.trackingCode ?? 'N/A',
                  ),
                  _buildSummaryRow(
                    'Distance',
                    '${widget.order.distance} km',
                  ),
                  _buildSummaryRow(
                    'Montant total',
                    '${widget.amount.toInt()} FCFA',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Méthode de paiement
          const Text(
            'Méthode de paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                _buildPaymentMethodOption(
                  'mobile_money',
                  'Mobile Money',
                  Icons.phone_android,
                  'Orange Money, MTN, MoMo',
                ),
                _buildPaymentMethodOption(
                  'cash',
                  'Espèces',
                  Icons.money,
                  'Paiement en espèces à la livraison',
                ),
                _buildPaymentMethodOption(
                  'card',
                  'Carte bancaire',
                  Icons.credit_card,
                  'Visa, Mastercard',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Détails du paiement (Mobile Money)
          if (_selectedMethod == 'mobile_money') ...[
            const Text(
              'Détails du paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _operatorController.text,
                      decoration: const InputDecoration(
                        labelText: 'Opérateur',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sim_card),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'orange',
                          child: Text('Orange Money'),
                        ),
                        DropdownMenuItem(
                          value: 'mtn',
                          child: Text('MTN Mobile Money'),
                        ),
                        DropdownMenuItem(
                          value: 'momo',
                          child: Text('MoMo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _operatorController.text = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        hintText: '+225 XX XX XX XX XX',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        if (!RegExp(r'^\+225[0-9]{8,10}$').hasMatch(value)) {
                          return 'Format invalide. Ex: +2250770000000';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Message d'erreur
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DonMTheme.erreurDonM.withOpacity(0.1),
                border: Border.all(color: DonMTheme.erreurDonM),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: DonMTheme.erreurDonM),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: DonMTheme.erreurDonM),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Bouton de paiement
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: DonMTheme.vertDonM,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 12),
                        Text('Traitement en cours...'),
                      ],
                    )
                  : Text(
                      'Payer ${widget.amount.toInt()} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String value,
    String title,
    IconData icon,
    String description,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedMethod == value ? DonMTheme.vertDonM : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _selectedMethod == value ? DonMTheme.vertDonM.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedMethod == value ? DonMTheme.vertDonM : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedMethod == value ? DonMTheme.vertDonM : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              activeColor: DonMTheme.vertDonM,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? DonMTheme.vertDonM : Colors.black,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DonMTheme.succesDonM,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paiement réussi !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DonMTheme.vertDonM,
              ),
            ),
            const SizedBox(height: 12),
            if (_transactionId != null) ...[
              Text(
                'Transaction: $_transactionId',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Votre commande ${widget.order.trackingCode} a été confirmée',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingPage(order: widget.order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DonMTheme.vertDonM,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Suivre ma commande',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> result;

      if (_selectedMethod == 'mobile_money') {
        // Valider le formulaire
        if (!_phoneNumberController.text.isNotEmpty) {
          throw Exception('Veuillez entrer votre numéro de téléphone');
        }

        result = await ApiService.payWithMobileMoney(
          orderId: widget.order.id,
          phoneNumber: _phoneNumberController.text,
          operator: _operatorController.text,
          amount: widget.amount,
        );

        if (!result['success']) {
          throw Exception(result['message'] ?? 'Échec du paiement');
        }

        setState(() {
          _transactionId = result['transaction_id'];
        });
      } else {
        // Simuler d'autres méthodes de paiement
        await Future.delayed(const Duration(seconds: 2));
        
        result = await ApiService.createPayment(
          orderId: widget.order.id,
          amount: widget.amount,
          method: _selectedMethod,
        );
      }

      setState(() {
        _paymentSuccess = true;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
