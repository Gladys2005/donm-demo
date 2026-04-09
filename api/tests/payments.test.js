const request = require('supertest');
const { Pool } = require('pg');
const app = require('../server');
const MobileMoneyService = require('../services/mobileMoneyService');

// Mock des dépendances
jest.mock('pg');
jest.mock('../services/mobileMoneyService');

describe('Payments API Tests', () => {
  let pool;
  let mobileMoneyService;

  beforeAll(() => {
    pool = new Pool();
    mobileMoneyService = new MobileMoneyService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/payments', () => {
    it('devrait créer un paiement avec succès', async () => {
      // Mock de la commande
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'order-123', total_amount: 2500, status: 'pending' }]
        })
        .mockResolvedValueOnce({
          rows: [{
            id: 'payment-123',
            order_id: 'order-123',
            amount: 2500,
            status: 'paid'
          }]
        });

      const paymentData = {
        order_id: 'order-123',
        amount: 2500,
        method: 'cash',
        transaction_id: 'TXN-123'
      };

      const response = await request(app)
        .post('/api/payments')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(201);

      expect(response.body).toHaveProperty('message', 'Paiement créé avec succès');
      expect(response.body.payment).toHaveProperty('id', 'payment-123');
      expect(response.body.payment).toHaveProperty('status', 'paid');
    });

    it('devrait retourner une erreur si la commande n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const paymentData = {
        order_id: 'nonexistent-order',
        amount: 2500,
        method: 'cash'
      };

      const response = await request(app)
        .post('/api/payments')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Commande non trouvée');
    });

    it('devrait retourner une erreur si le montant est incorrect', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{ id: 'order-123', total_amount: 3000, status: 'pending' }]
      });

      const paymentData = {
        order_id: 'order-123',
        amount: 2500, // Montant différent
        method: 'cash'
      };

      const response = await request(app)
        .post('/api/payments')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(400);

      expect(response.body).toHaveProperty('error', 'Montant incorrect');
    });

    it('devrait retourner une erreur si la commande est déjà payée', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{ id: 'order-123', total_amount: 2500, status: 'confirmed' }]
      });

      const paymentData = {
        order_id: 'order-123',
        amount: 2500,
        method: 'cash'
      };

      const response = await request(app)
        .post('/api/payments')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(400);

      expect(response.body).toHaveProperty('error', 'Commande déjà payée');
    });
  });

  describe('POST /api/payments/mobile-money', () => {
    it('devrait initier un paiement Mobile Money avec succès', async () => {
      // Mock de la commande
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'order-123', total_amount: 2500, status: 'pending' }]
        })
        .mockResolvedValueOnce({
          rows: [{ id: 'payment-123', order_id: 'order-123' }]
        })
        .mockResolvedValueOnce({ rows: [] }); // Pour la mise à jour

      // Mock du service Mobile Money
      mobileMoneyService.validatePhoneNumber.mockReturnValue({ valid: true });
      mobileMoneyService.getTransactionFees.mockReturnValue(50);
      mobileMoneyService.orangeMoneyPayment.mockResolvedValue({
        success: true,
        paymentId: 'orange-payment-123',
        paymentUrl: 'https://orange.com/pay/123'
      });

      const paymentData = {
        order_id: 'order-123',
        phone_number: '+2250770000000',
        operator: 'orange',
        amount: 2500,
        email: 'test@example.com'
      };

      const response = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body).toHaveProperty('message', 'Paiement initié avec succès');
      expect(response.body).toHaveProperty('paymentId', 'payment-123');
      expect(response.body).toHaveProperty('paymentUrl');
      expect(response.body).toHaveProperty('operator', 'orange');
      expect(response.body).toHaveProperty('fees', 50);
    });

    it('devrait valider le numéro de téléphone', async () => {
      mobileMoneyService.validatePhoneNumber.mockReturnValue({
        valid: false,
        error: 'Format de numéro invalide'
      });

      const paymentData = {
        order_id: 'order-123',
        phone_number: 'invalid-phone',
        operator: 'orange',
        amount: 2500
      };

      const response = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(400);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('error', 'Format de numéro invalide');
    });

    it('devrait gérer les erreurs de paiement Mobile Money', async () => {
      // Mock de la commande
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'order-123', total_amount: 2500, status: 'pending' }]
        })
        .mockResolvedValueOnce({
          rows: [{ id: 'payment-123', order_id: 'order-123' }]
        });

      // Mock du service Mobile Money avec erreur
      mobileMoneyService.validatePhoneNumber.mockReturnValue({ valid: true });
      mobileMoneyService.getTransactionFees.mockReturnValue(50);
      mobileMoneyService.mtnMobileMoneyPayment.mockResolvedValue({
        success: false,
        error: 'Service MTN indisponible',
        code: 503
      });

      const paymentData = {
        order_id: 'order-123',
        phone_number: '+2250770000000',
        operator: 'mtn',
        amount: 2500
      };

      const response = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(400);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('error', 'Service MTN indisponible');
      expect(response.body).toHaveProperty('code', 503);
    });

    it('devrait rejeter les opérateurs non supportés', async () => {
      mobileMoneyService.validatePhoneNumber.mockReturnValue({ valid: true });

      const paymentData = {
        order_id: 'order-123',
        phone_number: '+2250770000000',
        operator: 'unsupported',
        amount: 2500
      };

      const response = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', 'Bearer valid-token')
        .send(paymentData)
        .expect(400);

      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('error', 'Opérateur non supporté. Utilisez: orange, mtn, ou momo');
    });
  });

  describe('GET /api/payments/order/:order_id', () => {
    it('devrait récupérer les paiements d\'une commande', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [
          {
            id: 'payment-1',
            order_id: 'order-123',
            amount: 2500,
            status: 'paid',
            method: 'mobile_money_orange'
          },
          {
            id: 'payment-2',
            order_id: 'order-123',
            amount: 500,
            status: 'pending',
            method: 'cash'
          }
        ]
      });

      const response = await request(app)
        .get('/api/payments/order/order-123')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toHaveProperty('id', 'payment-1');
      expect(response.body[0]).toHaveProperty('status', 'paid');
    });
  });

  describe('GET /api/payments/user/:user_id', () => {
    it('devrait récupérer les paiements d\'un utilisateur', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [
          {
            id: 'payment-1',
            order_id: 'order-123',
            amount: 2500,
            status: 'paid',
            order_number: 'ORD-001',
            order_total: 2500
          }
        ]
      });

      const response = await request(app)
        .get('/api/payments/user/user-123')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toHaveLength(1);
      expect(response.body[0]).toHaveProperty('id', 'payment-1');
      expect(response.body[0]).toHaveProperty('order_number', 'ORD-001');
    });
  });

  describe('PUT /api/payments/:id/status', () => {
    it('devrait mettre à jour le statut d\'un paiement', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'payment-123',
          status: 'confirmed',
          gateway_response: { updated_at: new Date().toISOString() }
        }]
      });

      const response = await request(app)
        .put('/api/payments/payment-123/status')
        .set('Authorization', 'Bearer valid-token')
        .send({
          status: 'confirmed',
          gateway_response: { transaction_id: 'TXN-123' }
        })
        .expect(200);

      expect(response.body).toHaveProperty('status', 'confirmed');
      expect(response.body).toHaveProperty('gateway_response');
    });

    it('devrait retourner une erreur si le paiement n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .put('/api/payments/nonexistent/status')
        .set('Authorization', 'Bearer valid-token')
        .send({ status: 'confirmed' })
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Paiement non trouvé');
    });

    it('devrait valider les statuts autorisés', async () => {
      const response = await request(app)
        .put('/api/payments/payment-123/status')
        .set('Authorization', 'Bearer valid-token')
        .send({ status: 'invalid_status' })
        .expect(400);

      expect(response.body).toHaveProperty('error', 'Statut invalide');
    });
  });

  describe('POST /api/payments/:id/refund', () => {
    it('devrait rembourser un paiement avec succès', async () => {
      pool.query
        .mockResolvedValueOnce({
          rows: [{
            id: 'payment-123',
            order_id: 'order-123',
            amount: 2500,
            status: 'paid'
          }]
        })
        .mockResolvedValueOnce({ rows: [] }) // UPDATE payment
        .mockResolvedValueOnce({ rows: [] }); // UPDATE order

      const response = await request(app)
        .post('/api/payments/payment-123/refund')
        .set('Authorization', 'Bearer valid-token')
        .send({ reason: 'Client satisfait' })
        .expect(200);

      expect(response.body).toHaveProperty('message', 'Paiement remboursé avec succès');
      expect(response.body).toHaveProperty('refunded_amount', 2500);
    });

    it('devrait retourner une erreur si le paiement n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .post('/api/payments/nonexistent/refund')
        .set('Authorization', 'Bearer valid-token')
        .send({ reason: 'Test' })
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Paiement non trouvé');
    });

    it('devrait retourner une erreur si le paiement n\'est pas payé', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'payment-123',
          order_id: 'order-123',
          amount: 2500,
          status: 'pending' // Pas payé
        }]
      });

      const response = await request(app)
        .post('/api/payments/payment-123/refund')
        .set('Authorization', 'Bearer valid-token')
        .send({ reason: 'Test' })
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Paiement non trouvé');
    });
  });

  describe('Webhooks Mobile Money', () => {
    it('devrait gérer le webhook Orange Money', async () => {
      pool.query
        .mockResolvedValueOnce({
          rows: [{
            id: 'payment-123',
            order_id: 'order-123',
            status: 'pending'
          }]
        })
        .mockResolvedValueOnce({ rows: [] }); // UPDATE payment
        .mockResolvedValueOnce({ rows: [] }); // UPDATE order

      const webhookData = {
        payment_id: 'payment-123',
        status: 'successful',
        transaction_id: 'TXN-123',
        amount: 2500
      };

      const response = await request(app)
        .post('/api/payments/orange/webhook')
        .send(webhookData)
        .expect(200);

      expect(response.body).toHaveProperty('received', true);
    });

    it('devrait gérer le webhook MTN Mobile Money', async () => {
      pool.query
        .mockResolvedValueOnce({
          rows: [{
            id: 'payment-123',
            order_id: 'order-123',
            status: 'pending'
          }]
        })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [] });

      const webhookData = {
        referenceId: 'payment-123',
        status: 'successful',
        amount: 2500,
        financialTransactionId: 'FTX-123'
      };

      const response = await request(app)
        .post('/api/payments/mtn/webhook')
        .send(webhookData)
        .expect(200);

      expect(response.body).toHaveProperty('received', true);
    });

    it('devrait gérer le webhook MoMo', async () => {
      pool.query
        .mockResolvedValueOnce({
          rows: [{
            id: 'payment-123',
            order_id: 'order-123',
            status: 'pending'
          }]
        })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [] });

      const webhookData = {
        session_id: 'payment-123',
        status: 'completed',
        transaction_id: 'TXN-123',
        amount: 2500
      };

      const response = await request(app)
        .post('/api/payments/momo/webhook')
        .send(webhookData)
        .expect(200);

      expect(response.body).toHaveProperty('received', true);
    });
  });
});
