const axios = require('axios');
const crypto = require('crypto');

class MobileMoneyService {
  constructor() {
    // Configuration des APIs
    this.configs = {
      orange: {
        baseUrl: process.env.ORANGE_API_URL || 'https://api.orange.com/orange-money',
        clientId: process.env.ORANGE_CLIENT_ID,
        clientSecret: process.env.ORANGE_CLIENT_SECRET,
        apiKey: process.env.ORANGE_API_KEY,
        merchantKey: process.env.ORANGE_MERCHANT_KEY,
        country: 'CI' // Côte d'Ivoire
      },
      mtn: {
        baseUrl: process.env.MTN_API_URL || 'https://api.mtn.com/momo',
        clientId: process.env.MTN_CLIENT_ID,
        clientSecret: process.env.MTN_CLIENT_SECRET,
        apiKey: process.env.MTN_API_KEY,
        environment: process.env.NODE_ENV === 'production' ? 'production' : 'sandbox'
      },
      momo: {
        baseUrl: process.env.MOMO_API_URL || 'https://api.momo.africa',
        apiKey: process.env.MOMO_API_KEY,
        merchantId: process.env.MOMO_MERCHANT_ID,
        environment: process.env.NODE_ENV === 'production' ? 'live' : 'test'
      }
    };
  }

  // Orange Money API
  async orangeMoneyPayment(paymentData) {
    try {
      const config = this.configs.orange;
      
      // 1. Obtenir le token d'accès
      const token = await this.getOrangeToken();
      
      // 2. Préparer la requête de paiement
      const paymentRequest = {
        merchant_key: config.merchantKey,
        currency: 'XOF',
        order_id: paymentData.orderId,
        amount: paymentData.amount,
        return_url: paymentData.returnUrl || `${process.env.BASE_URL}/payment/callback/orange`,
        cancel_url: paymentData.cancelUrl || `${process.env.BASE_URL}/payment/cancel/orange`,
        notif_url: paymentData.notifUrl || `${process.env.BASE_URL}/api/payments/orange/webhook`,
        lang: 'fr',
        reference: `DONM-${paymentData.orderId}-${Date.now()}`,
        description: `Paiement DonM - Commande ${paymentData.orderId}`
      };

      // 3. Envoyer la requête de paiement
      const response = await axios.post(
        `${config.baseUrl}/orange-money/payment`,
        paymentRequest,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          timeout: 30000
        }
      );

      return {
        success: true,
        paymentUrl: response.data.payment_url,
        paymentId: response.data.payment_id,
        orderId: paymentData.orderId,
        operator: 'orange'
      };

    } catch (error) {
      console.error('Erreur Orange Money:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.message || 'Erreur lors du paiement Orange Money',
        code: error.response?.status || 500
      };
    }
  }

  async getOrangeToken() {
    try {
      const config = this.configs.orange;
      
      const response = await axios.post(
        `${config.baseUrl}/oauth/token`,
        new URLSearchParams({
          grant_type: 'client_credentials'
        }),
        {
          headers: {
            'Authorization': `Basic ${Buffer.from(`${config.clientId}:${config.clientSecret}`).toString('base64')}`,
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }
      );

      return response.data.access_token;
    } catch (error) {
      throw new Error('Impossible d\'obtenir le token Orange Money');
    }
  }

  // MTN Mobile Money API
  async mtnMobileMoneyPayment(paymentData) {
    try {
      const config = this.configs.mtn;
      
      // 1. Obtenir le token d'accès
      const token = await this.getMTNToken();
      
      // 2. Créer la transaction
      const transactionRequest = {
        amount: paymentData.amount,
        currency: 'XOF',
        externalId: paymentData.orderId,
        payer: {
          partyId: paymentData.phoneNumber,
          partyIdType: 'MSISDN'
        },
        payeeNote: `Paiement DonM - Commande ${paymentData.orderId}`,
        payerMessage: 'Merci pour votre confiance',
        callbackUrl: `${process.env.BASE_URL}/api/payments/mtn/webhook`
      };

      const response = await axios.post(
        `${config.baseUrl}/collection/v1_0/requesttopay`,
        transactionRequest,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'X-Reference-Id': crypto.randomUUID(),
            'X-Target-Environment': config.environment,
            'Content-Type': 'application/json',
            'Ocp-Apim-Subscription-Key': config.apiKey
          },
          timeout: 30000
        }
      );

      // 3. Vérifier le statut de la transaction
      const status = await this.checkMTNTransactionStatus(
        response.headers['x-reference-id'],
        token
      );

      return {
        success: true,
        transactionId: response.headers['x-reference-id'],
        status: status.status,
        orderId: paymentData.orderId,
        operator: 'mtn'
      };

    } catch (error) {
      console.error('Erreur MTN Mobile Money:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.message || 'Erreur lors du paiement MTN Mobile Money',
        code: error.response?.status || 500
      };
    }
  }

  async getMTNToken() {
    try {
      const config = this.configs.mtn;
      
      const response = await axios.post(
        `${config.baseUrl}/collection/oauth2/token`,
        new URLSearchParams({
          grant_type: 'client_credentials'
        }),
        {
          headers: {
            'Authorization': `Basic ${Buffer.from(`${config.clientId}:${config.clientSecret}`).toString('base64')}`,
            'Content-Type': 'application/x-www-form-urlencoded',
            'Ocp-Apim-Subscription-Key': config.apiKey
          }
        }
      );

      return response.data.access_token;
    } catch (error) {
      throw new Error('Impossible d\'obtenir le token MTN Mobile Money');
    }
  }

  async checkMTNTransactionStatus(transactionId, token) {
    try {
      const config = this.configs.mtn;
      
      const response = await axios.get(
        `${config.baseUrl}/collection/v1_0/requesttopay/${transactionId}`,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'X-Target-Environment': config.environment,
            'Ocp-Apim-Subscription-Key': config.apiKey
          }
        }
      );

      return {
        status: response.data.status,
        amount: response.data.amount,
        currency: response.data.currency,
        financialTransactionId: response.data.financialTransactionId
      };
    } catch (error) {
      throw new Error('Impossible de vérifier le statut de la transaction MTN');
    }
  }

  // MoMo API
  async momoPayment(paymentData) {
    try {
      const config = this.configs.momo;
      
      // 1. Créer la session de paiement
      const sessionRequest = {
        merchant_id: config.merchantId,
        amount: paymentData.amount,
        currency: 'XOF',
        order_id: paymentData.orderId,
        customer_email: paymentData.email,
        customer_phone: paymentData.phoneNumber,
        description: `Paiement DonM - Commande ${paymentData.orderId}`,
        callback_url: `${process.env.BASE_URL}/api/payments/momo/webhook`,
        return_url: paymentData.returnUrl || `${process.env.BASE_URL}/payment/success`,
        cancel_url: paymentData.cancelUrl || `${process.env.BASE_URL}/payment/cancel`
      };

      const response = await axios.post(
        `${config.baseUrl}/payments/create`,
        sessionRequest,
        {
          headers: {
            'Authorization': `Bearer ${config.apiKey}`,
            'Content-Type': 'application/json'
          },
          timeout: 30000
        }
      );

      return {
        success: true,
        paymentUrl: response.data.payment_url,
        sessionId: response.data.session_id,
        orderId: paymentData.orderId,
        operator: 'momo'
      };

    } catch (error) {
      console.error('Erreur MoMo:', error.response?.data || error.message);
      return {
        success: false,
        error: error.response?.data?.message || 'Erreur lors du paiement MoMo',
        code: error.response?.status || 500
      };
    }
  }

  // Vérifier le statut d'un paiement (pour tous les opérateurs)
  async checkPaymentStatus(operator, paymentId) {
    try {
      switch (operator.toLowerCase()) {
        case 'orange':
          return await this.checkOrangePaymentStatus(paymentId);
        case 'mtn':
          return await this.checkMTNTransactionStatus(paymentId, await this.getMTNToken());
        case 'momo':
          return await this.checkMomoPaymentStatus(paymentId);
        default:
          throw new Error('Opérateur non supporté');
      }
    } catch (error) {
      console.error(`Erreur vérification statut ${operator}:`, error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async checkOrangePaymentStatus(paymentId) {
    try {
      const token = await this.getOrangeToken();
      const config = this.configs.orange;
      
      const response = await axios.get(
        `${config.baseUrl}/orange-money/payment/${paymentId}`,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        status: response.data.status,
        amount: response.data.amount,
        transactionId: response.data.transaction_id
      };
    } catch (error) {
      throw new Error('Impossible de vérifier le statut du paiement Orange Money');
    }
  }

  async checkMomoPaymentStatus(sessionId) {
    try {
      const config = this.configs.momo;
      
      const response = await axios.get(
        `${config.baseUrl}/payments/status/${sessionId}`,
        {
          headers: {
            'Authorization': `Bearer ${config.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        status: response.data.status,
        amount: response.data.amount,
        transactionId: response.data.transaction_id
      };
    } catch (error) {
      throw new Error('Impossible de vérifier le statut du paiement MoMo');
    }
  }

  // Remboursement
  async refundPayment(operator, paymentData) {
    try {
      switch (operator.toLowerCase()) {
        case 'orange':
          return await this.refundOrangePayment(paymentData);
        case 'mtn':
          return await this.refundMTNPayment(paymentData);
        case 'momo':
          return await this.refundMomoPayment(paymentData);
        default:
          throw new Error('Opérateur non supporté');
      }
    } catch (error) {
      console.error(`Erreur remboursement ${operator}:`, error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async refundOrangePayment(paymentData) {
    try {
      const token = await this.getOrangeToken();
      const config = this.configs.orange;
      
      const refundRequest = {
        merchant_key: config.merchantKey,
        payment_id: paymentData.paymentId,
        amount: paymentData.amount,
        reason: paymentData.reason || 'Remboursement client'
      };

      const response = await axios.post(
        `${config.baseUrl}/orange-money/refund`,
        refundRequest,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        refundId: response.data.refund_id,
        status: 'processed'
      };
    } catch (error) {
      throw new Error('Impossible d\'effectuer le remboursement Orange Money');
    }
  }

  // Validation du numéro de téléphone selon l'opérateur
  validatePhoneNumber(phoneNumber, operator) {
    const patterns = {
      orange: /^(\+225)?(07|01)[0-9]{8}$/,
      mtn: /^(\+225)?(05|07)[0-9]{8}$/,
      momo: /^(\+225)?(07)[0-9]{8}$/
    };

    const pattern = patterns[operator.toLowerCase()];
    if (!pattern) {
      return { valid: false, error: 'Opérateur non supporté' };
    }

    const cleanNumber = phoneNumber.replace(/\s/g, '');
    return {
      valid: pattern.test(cleanNumber),
      error: pattern.test(cleanNumber) ? null : 'Format de numéro invalide'
    };
  }

  // Obtenir les frais de transaction par opérateur
  getTransactionFees(operator, amount) {
    const fees = {
      orange: {
        min: 50,
        percentage: 0.01,
        max: 2500
      },
      mtn: {
        min: 100,
        percentage: 0.015,
        max: 5000
      },
      momo: {
        min: 75,
        percentage: 0.012,
        max: 3000
      }
    };

    const feeConfig = fees[operator.toLowerCase()];
    if (!feeConfig) {
      return 0;
    }

    const calculatedFee = amount * feeConfig.percentage;
    return Math.max(feeConfig.min, Math.min(calculatedFee, feeConfig.max));
  }
}

module.exports = MobileMoneyService;
