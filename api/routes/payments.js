const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { v4: uuidv4 } = require('uuid');
const MobileMoneyService = require('../services/mobileMoneyService');

// Configuration PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: false,
});

// Créer un paiement
router.post('/', async (req, res) => {
  try {
    const { order_id, amount, method, transaction_id } = req.body;

    // Vérifier si la commande existe
    const orderResult = await pool.query(
      'SELECT id, total_amount, status FROM orders WHERE id = $1',
      [order_id]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).json({ error: 'Commande non trouvée' });
    }

    const order = orderResult.rows[0];

    // Vérifier si le montant correspond
    if (parseFloat(amount) !== parseFloat(order.total_amount)) {
      return res.status(400).json({ error: 'Montant incorrect' });
    }

    // Vérifier si la commande est déjà payée
    const existingPayment = await pool.query(
      'SELECT id FROM payments WHERE order_id = $1 AND status = $2',
      [order_id, 'paid']
    );

    if (existingPayment.rows.length > 0) {
      return res.status(400).json({ error: 'Commande déjà payée' });
    }

    // Créer le paiement
    const paymentResult = await pool.query(
      `INSERT INTO payments (order_id, amount, method, status, transaction_id, paid_at)
       VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
       RETURNING *`,
      [order_id, amount, method, 'paid', transaction_id || null]
    );

    // Mettre à jour le statut de la commande
    await pool.query(
      'UPDATE orders SET status = $1 WHERE id = $2',
      ['confirmed', order_id]
    );

    const payment = paymentResult.rows[0];

    res.status(201).json({
      message: 'Paiement créé avec succès',
      payment
    });

  } catch (error) {
    console.error('Erreur création paiement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Mettre à jour le statut d'un paiement
router.put('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, gateway_response } = req.body;

    const validStatuses = ['pending', 'paid', 'failed', 'refunded'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Statut invalide' });
    }

    const updateQuery = `
      UPDATE payments 
      SET status = $1, gateway_response = $2
    `;

    const params = [status, gateway_response ? JSON.stringify(gateway_response) : null];

    // Ajouter les timestamps selon le statut
    if (status === 'paid') {
      updateQuery += ', paid_at = CURRENT_TIMESTAMP';
    } else if (status === 'failed') {
      updateQuery += ', failed_at = CURRENT_TIMESTAMP';
    } else if (status === 'refunded') {
      updateQuery += ', refunded_at = CURRENT_TIMESTAMP';
    }

    updateQuery += ', updated_at = CURRENT_TIMESTAMP WHERE id = $' + (params.length + 1) + ' RETURNING *';
    params.push(id);

    const result = await pool.query(updateQuery, params);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Paiement non trouvé' });
    }

    // Si le paiement est confirmé, mettre à jour la commande
    if (status === 'paid') {
      await pool.query(
        'UPDATE orders SET status = $1 WHERE id = (SELECT order_id FROM payments WHERE id = $2)',
        ['confirmed', id]
      );
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error('Erreur mise à jour paiement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer les paiements d'une commande
router.get('/order/:order_id', async (req, res) => {
  try {
    const { order_id } = req.params;

    const result = await pool.query(
      'SELECT * FROM payments WHERE order_id = $1 ORDER BY created_at DESC',
      [order_id]
    );

    res.json(result.rows);

  } catch (error) {
    console.error('Erreur récupération paiements:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer les paiements d'un utilisateur
router.get('/user/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await pool.query(
      `SELECT p.*, o.order_number, o.total_amount as order_total
       FROM payments p
       JOIN orders o ON p.order_id = o.id
       WHERE o.client_id = $1
       ORDER BY p.created_at DESC`,
      [user_id]
    );

    res.json(result.rows);

  } catch (error) {
    console.error('Erreur récupération paiements utilisateur:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Paiement Mobile Money réel (Orange Money, MTN, MoMo)
router.post('/mobile-money', async (req, res) => {
  try {
    const { order_id, phone_number, operator, amount, email, return_url, cancel_url } = req.body;
    
    const mobileMoneyService = new MobileMoneyService();
    
    // Valider le numéro de téléphone
    const validation = mobileMoneyService.validatePhoneNumber(phone_number, operator);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        error: validation.error
      });
    }

    // Vérifier si la commande existe et n'est pas déjà payée
    const orderResult = await pool.query(
      'SELECT id, total_amount, status FROM orders WHERE id = $1',
      [order_id]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).json({ error: 'Commande non trouvée' });
    }

    const order = orderResult.rows[0];
    if (order.status === 'paid' || order.status === 'confirmed') {
      return res.status(400).json({ error: 'Commande déjà payée' });
    }

    // Calculer les frais de transaction
    const fees = mobileMoneyService.getTransactionFees(operator, amount);
    const totalAmount = parseFloat(amount) + fees;

    // Préparer les données de paiement
    const paymentData = {
      orderId: order_id,
      amount: totalAmount,
      phoneNumber: phone_number,
      email: email || req.user?.email,
      returnUrl: return_url,
      cancelUrl: cancel_url,
      notifUrl: `${process.env.BASE_URL}/api/payments/${operator}/webhook`
    };

    // Créer un enregistrement de paiement en attente
    const paymentResult = await pool.query(
      `INSERT INTO payments (order_id, amount, method, status, gateway_response, fees)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        order_id,
        totalAmount,
        `mobile_money_${operator}`,
        'pending',
        JSON.stringify({
          operator,
          phone_number,
          fees,
          initiated_at: new Date().toISOString()
        }),
        fees
      ]
    );

    // Effectuer le paiement selon l'opérateur
    let paymentResponse;
    switch (operator.toLowerCase()) {
      case 'orange':
        paymentResponse = await mobileMoneyService.orangeMoneyPayment(paymentData);
        break;
      case 'mtn':
        paymentResponse = await mobileMoneyService.mtnMobileMoneyPayment(paymentData);
        break;
      case 'momo':
        paymentResponse = await mobileMoneyService.momoPayment(paymentData);
        break;
      default:
        return res.status(400).json({
          success: false,
          error: 'Opérateur non supporté. Utilisez: orange, mtn, ou momo'
        });
    }

    if (!paymentResponse.success) {
      // Marquer le paiement comme échoué
      await pool.query(
        `UPDATE payments 
         SET status = 'failed', gateway_response = $1 
         WHERE id = $2`,
        [
          JSON.stringify({
            error: paymentResponse.error,
            code: paymentResponse.code,
            failed_at: new Date().toISOString()
          }),
          paymentResult.rows[0].id
        ]
      );

      return res.status(400).json({
        success: false,
        error: paymentResponse.error,
        code: paymentResponse.code
      });
    }

    // Mettre à jour le paiement avec l'ID de transaction
    await pool.query(
      `UPDATE payments 
       SET transaction_id = $1, gateway_response = $2 
       WHERE id = $3`,
      [
        paymentResponse.paymentId || paymentResponse.transactionId,
        JSON.stringify({
          ...JSON.parse(paymentResult.rows[0].gateway_response || '{}'),
          paymentId: paymentResponse.paymentId || paymentResponse.transactionId,
          paymentUrl: paymentResponse.paymentUrl,
          sessionId: paymentResponse.sessionId,
          operator: paymentResponse.operator
        }),
        paymentResult.rows[0].id
      ]
    );

    // Envoyer une notification au client
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${order.client_id}`).emit('payment_initiated', {
        paymentId: paymentResult.rows[0].id,
        orderId: order_id,
        operator,
        amount: totalAmount,
        paymentUrl: paymentResponse.paymentUrl
      });
    }

    res.json({
      success: true,
      message: 'Paiement initié avec succès',
      paymentId: paymentResult.rows[0].id,
      paymentUrl: paymentResponse.paymentUrl,
      transactionId: paymentResponse.paymentId || paymentResponse.transactionId,
      sessionId: paymentResponse.sessionId,
      operator,
      amount: totalAmount,
      fees
    });

  } catch (error) {
    console.error('Erreur paiement mobile money:', error);
    res.status(500).json({ 
      success: false,
      error: 'Erreur serveur lors du traitement du paiement' 
    });
  }
});

// Webhooks pour les notifications des opérateurs
router.post('/orange/webhook', async (req, res) => {
  try {
    const { payment_id, status, transaction_id, amount } = req.body;
    
    // Mettre à jour le statut du paiement
    await handlePaymentWebhook('orange', payment_id, status, {
      transaction_id,
      amount,
      received_at: new Date().toISOString()
    });

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Erreur webhook Orange:', error);
    res.status(500).json({ error: 'Erreur webhook' });
  }
});

router.post('/mtn/webhook', async (req, res) => {
  try {
    const { referenceId, status, amount, financialTransactionId } = req.body;
    
    await handlePaymentWebhook('mtn', referenceId, status, {
      transaction_id: financialTransactionId,
      amount,
      received_at: new Date().toISOString()
    });

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Erreur webhook MTN:', error);
    res.status(500).json({ error: 'Erreur webhook' });
  }
});

router.post('/momo/webhook', async (req, res) => {
  try {
    const { session_id, status, transaction_id, amount } = req.body;
    
    await handlePaymentWebhook('momo', session_id, status, {
      transaction_id,
      amount,
      received_at: new Date().toISOString()
    });

    res.status(200).json({ received: true });
  } catch (error) {
    console.error('Erreur webhook MoMo:', error);
    res.status(500).json({ error: 'Erreur webhook' });
  }
});

// Fonction utilitaire pour gérer les webhooks
async function handlePaymentWebhook(operator, paymentIdentifier, status, additionalData) {
  try {
    // Trouver le paiement correspondant
    const paymentResult = await pool.query(
      'SELECT * FROM payments WHERE transaction_id = $1 OR id = $2',
      [paymentIdentifier, paymentIdentifier]
    );

    if (paymentResult.rows.length === 0) {
      console.error(`Paiement non trouvé: ${paymentIdentifier}`);
      return;
    }

    const payment = paymentResult.rows[0];
    const newStatus = status === 'successful' || status === 'completed' ? 'paid' : 
                      status === 'failed' || status === 'cancelled' ? 'failed' : 'pending';

    // Mettre à jour le paiement
    await pool.query(
      `UPDATE payments 
       SET status = $1, gateway_response = $2, 
           ${newStatus === 'paid' ? 'paid_at = CURRENT_TIMESTAMP' : ''}
       WHERE id = $3`,
      [
        newStatus,
        JSON.stringify({
          ...JSON.parse(payment.gateway_response || '{}'),
          ...additionalData,
          webhook_status: status,
          webhook_received_at: new Date().toISOString()
        }),
        payment.id
      ]
    );

    // Si le paiement est réussi, mettre à jour la commande
    if (newStatus === 'paid') {
      await pool.query(
        'UPDATE orders SET status = $1 WHERE id = $2',
        ['confirmed', payment.order_id]
      );

      // Envoyer une notification de succès
      const io = require('../server').get('io');
      if (io) {
        io.to(`user_${payment.client_id}`).emit('payment_success', {
          paymentId: payment.id,
          orderId: payment.order_id,
          operator,
          amount: payment.amount,
          transactionId: additionalData.transaction_id
        });
      }
    }

  } catch (error) {
    console.error('Erreur traitement webhook:', error);
  }
}

// Rembourser un paiement
router.post('/:id/refund', async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    // Vérifier si le paiement existe et est payé
    const paymentResult = await pool.query(
      'SELECT * FROM payments WHERE id = $1 AND status = $2',
      [id, 'paid']
    );

    if (paymentResult.rows.length === 0) {
      return res.status(404).json({ error: 'Paiement non trouvé ou non payé' });
    }

    const payment = paymentResult.rows[0];

    // Mettre à jour le statut du paiement
    await pool.query(
      `UPDATE payments 
       SET status = $1, refunded_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP,
           gateway_response = $2
       WHERE id = $3`,
      [
        'refunded',
        JSON.stringify({
          refund_reason: reason,
          refund_date: new Date().toISOString(),
          refunded_amount: payment.amount
        }),
        id
      ]
    );

    // Mettre à jour le statut de la commande
    await pool.query(
      'UPDATE orders SET status = $1 WHERE id = $2',
      ['refunded', payment.order_id]
    );

    res.json({
      message: 'Paiement remboursé avec succès',
      refunded_amount: payment.amount
    });

  } catch (error) {
    console.error('Erreur remboursement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
