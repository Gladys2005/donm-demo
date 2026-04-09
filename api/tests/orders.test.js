const request = require('supertest');
const { Pool } = require('pg');
const app = require('../server');

// Mock de la base de données pour les tests
jest.mock('pg');

describe('Orders API Tests', () => {
  let pool;

  beforeAll(() => {
    pool = new Pool();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /api/orders', () => {
    it('devrait récupérer les commandes avec succès', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [
          {
            id: 'order-1',
            client_id: 'client-123',
            pickup_address: 'Abidjan, Cocody',
            delivery_address: 'Abidjan, Yopougon',
            status: 'pending',
            total_amount: 2500,
            tracking_code: 'TRK-001'
          },
          {
            id: 'order-2',
            client_id: 'client-456',
            pickup_address: 'Abidjan, Plateau',
            delivery_address: 'Abidjan, Marcory',
            status: 'confirmed',
            total_amount: 3000,
            tracking_code: 'TRK-002'
          }
        ]
      });

      const response = await request(app)
        .get('/api/orders')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toHaveProperty('id', 'order-1');
      expect(response.body[0]).toHaveProperty('status', 'pending');
    });

    it('devrait filtrer les commandes par client', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [
          {
            id: 'order-1',
            client_id: 'client-123',
            status: 'pending',
            tracking_code: 'TRK-001'
          }
        ]
      });

      const response = await request(app)
        .get('/api/orders?client_id=client-123')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(response.body).toHaveLength(1);
      expect(response.body[0]).toHaveProperty('client_id', 'client-123');
    });

    it('devrait filtrer les commandes par statut', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [
          {
            id: 'order-1',
            status: 'pending',
            tracking_code: 'TRK-001'
          },
          {
            id: 'order-2',
            status: 'pending',
            tracking_code: 'TRK-002'
          }
        ]
      });

      const response = await request(app)
        .get('/api/orders?status=pending')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(response.body).toHaveLength(2);
      response.body.forEach(order => {
        expect(order).toHaveProperty('status', 'pending');
      });
    });
  });

  describe('POST /api/orders', () => {
    it('devrait créer une commande avec succès', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          client_id: 'client-123',
          tracking_code: 'TRK-001',
          status: 'pending'
        }]
      });

      const orderData = {
        client_id: 'client-123',
        pickup_address: 'Abidjan, Cocody, Boutique A',
        delivery_address: 'Abidjan, Yopougon, Zone 1',
        distance: 5.5,
        base_price: 2000,
        delivery_fee: 500,
        total_amount: 2500,
        pickup_instructions: 'Sonner à la porte',
        delivery_instructions: 'Appeler avant livraison'
      };

      const response = await request(app)
        .post('/api/orders')
        .set('Authorization', 'Bearer valid-token')
        .send(orderData)
        .expect(201);

      expect(response.body).toHaveProperty('message', 'Commande créée avec succès');
      expect(response.body.order).toHaveProperty('id', 'order-123');
      expect(response.body.order).toHaveProperty('tracking_code', 'TRK-001');
      expect(response.body.order).toHaveProperty('status', 'pending');
    });

    it('devrait valider les données requises', async () => {
      const response = await request(app)
        .post('/api/orders')
        .set('Authorization', 'Bearer valid-token')
        .send({
          client_id: 'client-123',
          // pickup_address manquant
          delivery_address: 'Abidjan, Yopougon'
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('devrait calculer automatiquement le montant total', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          total_amount: 2500, // 2000 + 500
          tracking_code: 'TRK-001'
        }]
      });

      const orderData = {
        client_id: 'client-123',
        pickup_address: 'Abidjan, Cocody',
        delivery_address: 'Abidjan, Yopougon',
        distance: 5.5,
        base_price: 2000,
        delivery_fee: 500
      };

      const response = await request(app)
        .post('/api/orders')
        .set('Authorization', 'Bearer valid-token')
        .send(orderData)
        .expect(201);

      expect(response.body.order).toHaveProperty('total_amount', 2500);
    });
  });

  describe('PUT /api/orders/:id/status', () => {
    it('devrait mettre à jour le statut d\'une commande', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          status: 'confirmed',
          delivery_person_id: 'delivery-456'
        }]
      });

      const response = await request(app)
        .put('/api/orders/order-123/status')
        .set('Authorization', 'Bearer valid-token')
        .send({
          status: 'confirmed',
          delivery_person_id: 'delivery-456'
        })
        .expect(200);

      expect(response.body).toHaveProperty('status', 'confirmed');
      expect(response.body).toHaveProperty('delivery_person_id', 'delivery-456');
    });

    it('devrait retourner une erreur si la commande n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .put('/api/orders/nonexistent/status')
        .set('Authorization', 'Bearer valid-token')
        .send({ status: 'confirmed' })
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Commande non trouvée');
    });

    it('devrait valider les statuts autorisés', async () => {
      const response = await request(app)
        .put('/api/orders/order-123/status')
        .set('Authorization', 'Bearer valid-token')
        .send({ status: 'invalid_status' })
        .expect(400);

      expect(response.body).toHaveProperty('error', 'Statut invalide');
    });
  });

  describe('GET /api/orders/:id', () => {
    it('devrait récupérer une commande spécifique', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          client_id: 'client-123',
          pickup_address: 'Abidjan, Cocody',
          delivery_address: 'Abidjan, Yopougon',
          status: 'pending',
          tracking_code: 'TRK-001',
          total_amount: 2500
        }]
      });

      const response = await request(app)
        .get('/api/orders/order-123')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(response.body).toHaveProperty('id', 'order-123');
      expect(response.body).toHaveProperty('tracking_code', 'TRK-001');
      expect(response.body).toHaveProperty('status', 'pending');
    });

    it('devrait retourner une erreur si la commande n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .get('/api/orders/nonexistent')
        .set('Authorization', 'Bearer valid-token')
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Commande non trouvée');
    });
  });

  describe('PUT /api/orders/:id', () => {
    it('devrait mettre à jour une commande', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          pickup_address: 'Nouvelle adresse de pickup',
          delivery_address: 'Nouvelle adresse de livraison',
          updated_at: new Date().toISOString()
        }]
      });

      const updateData = {
        pickup_address: 'Nouvelle adresse de pickup',
        delivery_address: 'Nouvelle adresse de livraison'
      };

      const response = await request(app)
        .put('/api/orders/order-123')
        .set('Authorization', 'Bearer valid-token')
        .send(updateData)
        .expect(200);

      expect(response.body).toHaveProperty('pickup_address', 'Nouvelle adresse de pickup');
      expect(response.body).toHaveProperty('delivery_address', 'Nouvelle adresse de livraison');
    });

    it('devrait retourner une erreur si la commande n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .put('/api/orders/nonexistent')
        .set('Authorization', 'Bearer valid-token')
        .send({ pickup_address: 'Test' })
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Commande non trouvée');
    });
  });

  describe('DELETE /api/orders/:id', () => {
    it('devrait supprimer une commande', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{ id: 'order-123' }]
      });

      const response = await request(app)
        .delete('/api/orders/order-123')
        .set('Authorization', 'Bearer valid-token')
        .expect(200);

      expect(response.body).toHaveProperty('message', 'Commande supprimée avec succès');
    });

    it('devrait retourner une erreur si la commande n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .delete('/api/orders/nonexistent')
        .set('Authorization', 'Bearer valid-token')
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Commande non trouvée');
    });
  });

  describe('GET /api/orders/tracking/:tracking_code', () => {
    it('devrait récupérer une commande par code de suivi', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          tracking_code: 'TRK-001',
          status: 'in_transit',
          pickup_address: 'Abidjan, Cocody',
          delivery_address: 'Abidjan, Yopougon'
        }]
      });

      const response = await request(app)
        .get('/api/orders/tracking/TRK-001')
        .expect(200);

      expect(response.body).toHaveProperty('tracking_code', 'TRK-001');
      expect(response.body).toHaveProperty('status', 'in_transit');
    });

    it('devrait retourner une erreur si le code de suivi n\'existe pas', async () => {
      pool.query.mockResolvedValueOnce({ rows: [] });

      const response = await request(app)
        .get('/api/orders/tracking/INVALID')
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Code de suivi invalide');
    });
  });

  describe('PUT /api/orders/:id/location', () => {
    it('devrait mettre à jour la position du livreur', async () => {
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-123',
          delivery_person_location: { lat: 5.360, lng: -4.008 }
        }]
      });

      const locationData = {
        delivery_person_location: { lat: 5.360, lng: -4.008 }
      };

      const response = await request(app)
        .put('/api/orders/order-123/location')
        .set('Authorization', 'Bearer valid-token')
        .send(locationData)
        .expect(200);

      expect(response.body).toHaveProperty('delivery_person_location');
      expect(response.body.delivery_person_location).toHaveProperty('lat', 5.360);
      expect(response.body.delivery_person_location).toHaveProperty('lng', -4.008);
    });

    it('devrait valider les coordonnées GPS', async () => {
      const response = await request(app)
        .put('/api/orders/order-123/location')
        .set('Authorization', 'Bearer valid-token')
        .send({
          delivery_person_location: { lat: 'invalid', lng: 'invalid' }
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });
});
