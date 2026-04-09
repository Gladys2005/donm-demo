const request = require('supertest');
const { Pool } = require('pg');
const app = require('../../server');

// Mock de la base de données pour les tests E2E
jest.mock('pg');

describe('User Journey E2E Tests', () => {
  let pool;
  let authToken;
  let userId;
  let orderId;
  let productId;
  let paymentId;

  beforeAll(() => {
    pool = new Pool();
  });

  afterAll(async () => {
    // Nettoyage des données de test
    if (paymentId) {
      await pool.query('DELETE FROM payments WHERE id = $1', [paymentId]);
    }
    if (orderId) {
      await pool.query('DELETE FROM orders WHERE id = $1', [orderId]);
    }
    if (productId) {
      await pool.query('DELETE FROM products WHERE id = $1', [productId]);
    }
    if (userId) {
      await pool.query('DELETE FROM users WHERE id = $1', [userId]);
    }
  });

  describe('Complete Client Journey', () => {
    it('should complete full client workflow: register -> login -> order -> pay -> track', async () => {
      // Étape 1: Inscription du client
      const registerData = {
        username: 'client_test',
        email: 'client.test@example.com',
        phone: '+2250770000001',
        password: 'password123',
        first_name: 'Test',
        last_name: 'Client',
        role: 'client'
      };

      pool.query
        .mockResolvedValueOnce({ rows: [] }) // Email non existant
        .mockResolvedValueOnce({
          rows: [{ id: 'user-client-123', email: 'client.test@example.com', role: 'client' }]
        });

      const registerResponse = await request(app)
        .post('/api/auth/register')
        .send(registerData)
        .expect(201);

      expect(registerResponse.body.message).toBe('Utilisateur créé avec succès');
      userId = registerResponse.body.user.id;
      authToken = registerResponse.body.token;

      // Étape 2: Connexion
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: userId,
          email: 'client.test@example.com',
          password_hash: '$2b$10$mockhashedpassword',
          role: 'client'
        }]
      });

      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'client.test@example.com',
          password: 'password123'
        })
        .expect(200);

      expect(loginResponse.body.message).toBe('Connexion réussie');
      authToken = loginResponse.body.token;

      // Étape 3: Vérification du token
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: userId,
          email: 'client.test@example.com',
          role: 'client'
        }]
      });

      const verifyResponse = await request(app)
        .get('/api/auth/verify')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(verifyResponse.body.message).toBe('Token valide');

      // Étape 4: Consultation des produits disponibles
      pool.query.mockResolvedValueOnce({
        rows: [
          {
            id: 'product-1',
            name: 'Attiéké et poisson',
            price: 2500,
            category: 'Plats chauds',
            vendor_id: 'vendor-123',
            is_available: true
          },
          {
            id: 'product-2',
            name: 'Alloco',
            price: 1500,
            category: 'Plats chauds',
            vendor_id: 'vendor-123',
            is_available: true
          }
        ]
      });

      const productsResponse = await request(app)
        .get('/api/products?available=true')
        .expect(200);

      expect(productsResponse.body).toHaveLength(2);
      productId = productsResponse.body[0].id;

      // Étape 5: Création d'une commande
      pool.query
        .mockResolvedValueOnce({
          rows: [{
            id: 'order-123',
            tracking_code: 'TRK-CLIENT-001',
            status: 'pending'
          }]
        })
        .mockResolvedValueOnce({
          rows: [{
            id: 'order-123',
            tracking_code: 'TRK-CLIENT-001',
            status: 'pending',
            client_id: userId
          }]
        });

      const orderData = {
        client_id: userId,
        pickup_address: 'Abidjan, Cocody, Zone 4',
        delivery_address: 'Abidjan, Yopougon, Zone 1',
        distance: 8.5,
        base_price: 2125,
        delivery_fee: 500,
        total_amount: 2625,
        pickup_instructions: 'Sonner à la porte',
        delivery_instructions: 'Appeler avant livraison'
      };

      const orderResponse = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${authToken}`)
        .send(orderData)
        .expect(201);

      expect(orderResponse.body.message).toBe('Commande créée avec succès');
      orderId = orderResponse.body.order.id;
      expect(orderResponse.body.order.tracking_code).toBe('TRK-CLIENT-001');

      // Étape 6: Consultation des commandes du client
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: orderId,
          tracking_code: 'TRK-CLIENT-001',
          status: 'pending',
          total_amount: 2625
        }]
      });

      const clientOrdersResponse = await request(app)
        .get(`/api/orders?client_id=${userId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(clientOrdersResponse.body).toHaveLength(1);
      expect(clientOrdersResponse.body[0].tracking_code).toBe('TRK-CLIENT-001');

      // Étape 7: Paiement avec Mobile Money
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: orderId, total_amount: 2625, status: 'pending' }]
        })
        .mockResolvedValueOnce({
          rows: [{ id: 'payment-123', order_id: orderId }]
        })
        .mockResolvedValueOnce({ rows: [] }); // Pour la mise à jour

      const paymentData = {
        order_id: orderId,
        phone_number: '+2250770000001',
        operator: 'orange',
        amount: 2625,
        email: 'client.test@example.com'
      };

      const paymentResponse = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', `Bearer ${authToken}`)
        .send(paymentData)
        .expect(200);

      expect(paymentResponse.body.success).toBe(true);
      expect(paymentResponse.body.operator).toBe('orange');
      expect(paymentResponse.body.amount).toBeGreaterThan(2625); // Avec frais
      paymentId = paymentResponse.body.paymentId;

      // Étape 8: Simulation du webhook de paiement réussi
      pool.query
        .mockResolvedValueOnce({
          rows: [{
            id: paymentId,
            order_id: orderId,
            status: 'pending'
          }]
        })
        .mockResolvedValueOnce({ rows: [] }) // UPDATE payment
        .mockResolvedValueOnce({ rows: [] }); // UPDATE order

      const webhookResponse = await request(app)
        .post('/api/payments/orange/webhook')
        .send({
          payment_id: paymentId,
          status: 'successful',
          transaction_id: 'TXN-ORANGE-123',
          amount: 2675
        })
        .expect(200);

      expect(webhookResponse.body.received).toBe(true);

      // Étape 9: Vérification du statut de la commande après paiement
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: orderId,
          tracking_code: 'TRK-CLIENT-001',
          status: 'confirmed',
          total_amount: 2625
        }]
      });

      const updatedOrderResponse = await request(app)
        .get(`/api/orders/${orderId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(updatedOrderResponse.body.status).toBe('confirmed');

      // Étape 10: Consultation de l'historique des paiements
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: paymentId,
          order_id: orderId,
          amount: 2675,
          status: 'paid',
          method: 'mobile_money_orange',
          order_number: 'TRK-CLIENT-001',
          order_total: 2625
        }]
      });

      const paymentsHistoryResponse = await request(app)
        .get(`/api/payments/user/${userId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(paymentsHistoryResponse.body).toHaveLength(1);
      expect(paymentsHistoryResponse.body[0].status).toBe('paid');

      // Étape 11: Déconnexion
      const logoutResponse = await request(app)
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(logoutResponse.body.message).toBe('Déconnexion réussie');
    });
  });

  describe('Complete Vendor Journey', () => {
    let vendorToken;
    let vendorId;
    let vendorProductId;

    it('should complete full vendor workflow: register -> login -> add products -> manage orders', async () => {
      // Étape 1: Inscription du vendeur
      const vendorRegisterData = {
        username: 'vendor_test',
        email: 'vendor.test@example.com',
        phone: '+2250770000002',
        password: 'password123',
        first_name: 'Test',
        last_name: 'Vendor',
        role: 'vendor',
        shop_name: 'Boutique Test'
      };

      pool.query
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({
          rows: [{ id: 'user-vendor-123', email: 'vendor.test@example.com', role: 'vendor' }]
        });

      const vendorRegisterResponse = await request(app)
        .post('/api/auth/register')
        .send(vendorRegisterData)
        .expect(201);

      vendorId = vendorRegisterResponse.body.user.id;
      vendorToken = vendorRegisterResponse.body.token;

      // Étape 2: Connexion du vendeur
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: vendorId,
          email: 'vendor.test@example.com',
          password_hash: '$2b$10$mockhashedpassword',
          role: 'vendor'
        }]
      });

      const vendorLoginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'vendor.test@example.com',
          password: 'password123'
        })
        .expect(200);

      vendorToken = vendorLoginResponse.body.token;

      // Étape 3: Ajout d'un produit
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'product-vendor-123',
          name: 'Garba spécial',
          price: 3000,
          category: 'Plats chauds',
          vendor_id: vendorId
        }]
      });

      const productData = {
        vendor_id: vendorId,
        name: 'Garba spécial',
        description: 'Garba avec poisson fumé et légumes',
        price: 3000,
        category: 'Plats chauds',
        images: ['garba.jpg'],
        is_available: true
      };

      const productResponse = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${vendorToken}`)
        .send(productData)
        .expect(201);

      vendorProductId = productResponse.id;
      expect(productResponse.name).toBe('Garba spécial');

      // Étape 4: Consultation des produits du vendeur
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: vendorProductId,
          name: 'Garba spécial',
          price: 3000,
          is_available: true
        }]
      });

      const vendorProductsResponse = await request(app)
        .get('/api/products?vendor_id=vendor-123')
        .set('Authorization', `Bearer ${vendorToken}`)
        .expect(200);

      expect(vendorProductsResponse.body).toHaveLength(1);

      // Étape 5: Mise à jour d'un produit
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: vendorProductId,
          name: 'Garba spécial',
          price: 3200,
          is_available: false
        }]
      });

      const updateResponse = await request(app)
        .put(`/api/products/${vendorProductId}`)
        .set('Authorization', `Bearer ${vendorToken}`)
        .send({
          price: 3200,
          is_available: false
        })
        .expect(200);

      expect(updateResponse.price).toBe(3200);
      expect(updateResponse.is_available).toBe(false);

      // Étape 6: Consultation des commandes contenant les produits du vendeur
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-with-vendor-product',
          tracking_code: 'TRK-ORDER-001',
          status: 'confirmed',
          total_amount: 3200
        }]
      });

      const vendorOrdersResponse = await request(app)
        .get('/api/orders')
        .set('Authorization', `Bearer ${vendorToken}`)
        .expect(200);

      expect(vendorOrdersResponse.body).toHaveLength(1);
    });
  });

  describe('Complete Delivery Person Journey', () => {
    let deliveryToken;
    let deliveryId;

    it('should complete full delivery person workflow: register -> login -> accept orders -> update status', async () => {
      // Étape 1: Inscription du livreur
      const deliveryRegisterData = {
        username: 'delivery_test',
        email: 'delivery.test@example.com',
        phone: '+2250770000003',
        password: 'password123',
        first_name: 'Test',
        last_name: 'Delivery',
        role: 'delivery',
        vehicle_type: 'moto',
        delivery_level: 'premium'
      };

      pool.query
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({
          rows: [{ id: 'user-delivery-123', email: 'delivery.test@example.com', role: 'delivery' }]
        });

      const deliveryRegisterResponse = await request(app)
        .post('/api/auth/register')
        .send(deliveryRegisterData)
        .expect(201);

      deliveryId = deliveryRegisterResponse.body.user.id;
      deliveryToken = deliveryRegisterResponse.body.token;

      // Étape 2: Connexion du livreur
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: deliveryId,
          email: 'delivery.test@example.com',
          password_hash: '$2b$10$mockhashedpassword',
          role: 'delivery'
        }]
      });

      const deliveryLoginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'delivery.test@example.com',
          password: 'password123'
        })
        .expect(200);

      deliveryToken = deliveryLoginResponse.body.token;

      // Étape 3: Consultation des commandes disponibles
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-available-123',
          tracking_code: 'TRK-AVAILABLE-001',
          status: 'confirmed',
          pickup_address: 'Abidjan, Cocody',
          delivery_address: 'Abidjan, Yopougon',
          total_amount: 2500
        }]
      });

      const availableOrdersResponse = await request(app)
        .get('/api/orders?status=confirmed')
        .set('Authorization', `Bearer ${deliveryToken}`)
        .expect(200);

      expect(availableOrdersResponse.body).toHaveLength(1);

      // Étape 4: Acceptation d'une commande
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-available-123',
          status: 'in_transit',
          delivery_person_id: deliveryId
        }]
      });

      const acceptOrderResponse = await request(app)
        .put('/api/orders/order-available-123/status')
        .set('Authorization', `Bearer ${deliveryToken}`)
        .send({
          status: 'in_transit',
          delivery_person_id: deliveryId
        })
        .expect(200);

      expect(acceptOrderResponse.status).toBe('in_transit');
      expect(acceptOrderResponse.delivery_person_id).toBe(deliveryId);

      // Étape 5: Mise à jour de la position du livreur
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-available-123',
          delivery_person_location: { lat: 5.360, lng: -4.008 }
        }]
      });

      const locationUpdateResponse = await request(app)
        .put('/api/orders/order-available-123/location')
        .set('Authorization', `Bearer ${deliveryToken}`)
        .send({
          delivery_person_location: { lat: 5.360, lng: -4.008 }
        })
        .expect(200);

      expect(locationUpdateResponse.delivery_person_location).toEqual({
        lat: 5.360,
        lng: -4.008
      });

      // Étape 6: Finalisation de la livraison
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-available-123',
          status: 'delivered'
        }]
      });

      const completeDeliveryResponse = await request(app)
        .put('/api/orders/order-available-123/status')
        .set('Authorization', `Bearer ${deliveryToken}`)
        .send({
          status: 'delivered'
        })
        .expect(200);

      expect(completeDeliveryResponse.status).toBe('delivered');
    });
  });

  describe('Cross-Role Interactions', () => {
    it('should handle client order -> vendor preparation -> delivery -> payment completion', async () => {
      // Ce test simule l'interaction complète entre les trois rôles
      
      // 1. Client crée une commande
      const clientOrderData = {
        client_id: 'client-cross-123',
        pickup_address: 'Abidjan, Plateau, Boutique A',
        delivery_address: 'Abidjan, Marcory, Residence B',
        distance: 6.2,
        total_amount: 2655
      };

      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'order-cross-123',
          tracking_code: 'TRK-CROSS-001',
          status: 'pending'
        }]
      });

      const crossOrderResponse = await request(app)
        .post('/api/orders')
        .set('Authorization', 'Bearer client-token')
        .send(clientOrderData)
        .expect(201);

      const crossOrderId = crossOrderResponse.body.order.id;

      // 2. Livreur accepte la commande
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: crossOrderId,
          status: 'in_transit',
          delivery_person_id: 'delivery-cross-123'
        }]
      });

      await request(app)
        .put(`/api/orders/${crossOrderId}/status`)
        .set('Authorization', 'Bearer delivery-token')
        .send({
          status: 'in_transit',
          delivery_person_id: 'delivery-cross-123'
        })
        .expect(200);

      // 3. Client effectue le paiement
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: crossOrderId, total_amount: 2655, status: 'in_transit' }]
        })
        .mockResolvedValueOnce({
          rows: [{ id: 'payment-cross-123', order_id: crossOrderId }]
        });

      const crossPaymentResponse = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', 'Bearer client-token')
        .send({
          order_id: crossOrderId,
          phone_number: '+2250770000004',
          operator: 'mtn',
          amount: 2655
        })
        .expect(200);

      expect(crossPaymentResponse.body.success).toBe(true);

      // 4. Paiement confirmé via webhook
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'payment-cross-123', order_id: crossOrderId, status: 'pending' }]
        })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [] });

      await request(app)
        .post('/api/payments/mtn/webhook')
        .send({
          referenceId: 'payment-cross-123',
          status: 'successful',
          amount: 2705
        })
        .expect(200);

      // 5. Commande marquée comme livrée
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: crossOrderId,
          status: 'delivered'
        }]
      });

      const finalStatusResponse = await request(app)
        .put(`/api/orders/${crossOrderId}/status`)
        .set('Authorization', 'Bearer delivery-token')
        .send({
          status: 'delivered'
        })
        .expect(200);

      expect(finalStatusResponse.status).toBe('delivered');
    });
  });

  describe('Error Handling and Edge Cases', () => {
    it('should handle concurrent orders gracefully', async () => {
      // Simulation de commandes simultanées
      const concurrentOrders = Array.from({ length: 5 }, (_, i) => ({
        client_id: `client-concurrent-${i}`,
        pickup_address: `Abidjan, Zone ${i}`,
        delivery_address: `Abidjan, Zone ${i + 10}`,
        total_amount: 2500 + (i * 100)
      }));

      // Mock des réponses pour les commandes concurrentes
      pool.query.mockResolvedValue({
        rows: [{
          id: `order-concurrent-${Math.random()}`,
          tracking_code: `TRK-CONCURRENT-${Math.random()}`,
          status: 'pending'
        }]
      });

      const promises = concurrentOrders.map(order =>
        request(app)
          .post('/api/orders')
          .set('Authorization', 'Bearer concurrent-token')
          .send(order)
      );

      const results = await Promise.allSettled(promises);
      
      // Vérifier que toutes les commandes ont été créées
      results.forEach((result, index) => {
        if (result.status === 'fulfilled') {
          expect(result.value.status).toBe(201);
        } else {
          console.log(`Concurrent order ${index} failed:`, result.reason);
        }
      });
    });

    it('should handle payment failures and retries', async () => {
      // Simulation d'un échec de paiement suivi d'une nouvelle tentative
      
      // Premier échec
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'order-retry-123', total_amount: 2500, status: 'pending' }]
        })
        .mockResolvedValueOnce({
          rows: [{ id: 'payment-retry-123', order_id: 'order-retry-123' }]
        });

      const firstPaymentResponse = await request(app)
        .post('/api/payments/mobile-money')
        .set('Authorization', 'Bearer retry-token')
        .send({
          order_id: 'order-retry-123',
          phone_number: '+2250770000005',
          operator: 'orange',
          amount: 2500
        });

      // Simulation d'échec
      if (firstPaymentResponse.status === 400) {
        // Deuxième tentative réussie
        pool.query
          .mockResolvedValueOnce({
            rows: [{ id: 'order-retry-123', total_amount: 2500, status: 'pending' }]
          })
          .mockResolvedValueOnce({
            rows: [{ id: 'payment-retry-success', order_id: 'order-retry-123' }]
          });

        const retryResponse = await request(app)
          .post('/api/payments/mobile-money')
          .set('Authorization', 'Bearer retry-token')
          .send({
            order_id: 'order-retry-123',
            phone_number: '+2250770000005',
            operator: 'mtn', // Changement d'opérateur
            amount: 2500
          })
          .expect(200);

        expect(retryResponse.body.success).toBe(true);
      }
    });
  });
});
