const { Pool } = require('pg');
const EventEmitter = require('events');

class AnalyticsService extends EventEmitter {
  constructor() {
    super();
    this.pool = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      ssl: false,
    });
    
    this.metrics = new Map();
    this.realTimeData = new Map();
    this.initializeMetrics();
  }

  initializeMetrics() {
    // Initialiser les compteurs de métriques
    this.metrics.set('users', {
      total: 0,
      active_today: 0,
      new_today: 0,
      by_role: { client: 0, vendor: 0, delivery: 0 }
    });
    
    this.metrics.set('orders', {
      total: 0,
      today: 0,
      pending: 0,
      confirmed: 0,
      in_transit: 0,
      delivered: 0,
      cancelled: 0,
      avg_value: 0,
      total_revenue: 0
    });
    
    this.metrics.set('payments', {
      total: 0,
      today: 0,
      successful: 0,
      failed: 0,
      pending: 0,
      by_method: { cash: 0, mobile_money_orange: 0, mobile_money_mtn: 0, mobile_money_momo: 0, card: 0 },
      total_amount: 0,
      avg_amount: 0
    });
    
    this.metrics.set('products', {
      total: 0,
      active: 0,
      inactive: 0,
      by_category: {},
      avg_price: 0,
      most_viewed: [],
      most_sold: []
    });
    
    this.metrics.set('performance', {
      api_response_time: 0,
      db_query_time: 0,
      error_rate: 0,
      uptime: 0,
      concurrent_users: 0,
      requests_per_second: 0
    });
  }

  // Tracker les événements utilisateur
  async trackUserEvent(eventType, userId, data = {}) {
    try {
      const event = {
        id: this.generateId(),
        event_type: eventType,
        user_id: userId,
        data: JSON.stringify(data),
        timestamp: new Date(),
        ip_address: data.ip_address,
        user_agent: data.user_agent,
        session_id: data.session_id
      };

      // Insérer dans la base de données
      await this.pool.query(
        `INSERT INTO analytics_events (id, event_type, user_id, data, timestamp, ip_address, user_agent, session_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [event.id, event.event_type, event.user_id, event.data, event.timestamp, event.ip_address, event.user_agent, event.session_id]
      );

      // Mettre à jour les métriques en temps réel
      this.updateRealTimeMetrics(eventType, data);

      // Émettre l'événement pour le monitoring en temps réel
      this.emit('userEvent', event);

      return event;
    } catch (error) {
      console.error('Erreur tracking user event:', error);
      throw error;
    }
  }

  // Tracker les événements de commande
  async trackOrderEvent(eventType, orderId, data = {}) {
    try {
      const event = {
        id: this.generateId(),
        event_type: eventType,
        order_id: orderId,
        data: JSON.stringify(data),
        timestamp: new Date(),
        user_id: data.user_id,
        amount: data.amount
      };

      await this.pool.query(
        `INSERT INTO order_analytics (id, event_type, order_id, data, timestamp, user_id, amount)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [event.id, event.event_type, event.order_id, event.data, event.timestamp, event.user_id, event.amount]
      );

      this.updateOrderMetrics(eventType, data);
      this.emit('orderEvent', event);

      return event;
    } catch (error) {
      console.error('Erreur tracking order event:', error);
      throw error;
    }
  }

  // Tracker les événements de paiement
  async trackPaymentEvent(eventType, paymentId, data = {}) {
    try {
      const event = {
        id: this.generateId(),
        event_type: eventType,
        payment_id: paymentId,
        data: JSON.stringify(data),
        timestamp: new Date(),
        amount: data.amount,
        method: data.method,
        status: data.status
      };

      await this.pool.query(
        `INSERT INTO payment_analytics (id, event_type, payment_id, data, timestamp, amount, method, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [event.id, event.event_type, event.payment_id, event.data, event.timestamp, event.amount, event.method, event.status]
      );

      this.updatePaymentMetrics(eventType, data);
      this.emit('paymentEvent', event);

      return event;
    } catch (error) {
      console.error('Erreur tracking payment event:', error);
      throw error;
    }
  }

  // Tracker les performances API
  trackPerformance(endpoint, responseTime, statusCode, error = null) {
    const performanceData = {
      endpoint,
      response_time: responseTime,
      status_code: statusCode,
      error: error,
      timestamp: new Date()
    };

    // Mettre à jour les métriques de performance
    const currentMetrics = this.metrics.get('performance');
    currentMetrics.api_response_time = this.calculateAverageResponseTime(responseTime, currentMetrics.api_response_time);
    
    if (statusCode >= 400) {
      currentMetrics.error_rate = this.calculateErrorRate(statusCode, currentMetrics.error_rate);
    }

    this.emit('performanceUpdate', performanceData);
  }

  // Obtenir les métriques en temps réel
  getRealTimeMetrics() {
    return {
      timestamp: new Date(),
      metrics: Object.fromEntries(this.metrics),
      real_time_data: Object.fromEntries(this.realTimeData)
    };
  }

  // Obtenir les analytics par période
  async getAnalyticsByPeriod(period = '24h', filters = {}) {
    try {
      let timeFilter;
      switch (period) {
        case '1h':
          timeFilter = "timestamp >= NOW() - INTERVAL '1 hour'";
          break;
        case '24h':
          timeFilter = "timestamp >= NOW() - INTERVAL '24 hours'";
          break;
        case '7d':
          timeFilter = "timestamp >= NOW() - INTERVAL '7 days'";
          break;
        case '30d':
          timeFilter = "timestamp >= NOW() - INTERVAL '30 days'";
          break;
        default:
          timeFilter = "timestamp >= NOW() - INTERVAL '24 hours'";
      }

      const queries = {
        user_events: `
          SELECT event_type, COUNT(*) as count, 
                 DATE_TRUNC('hour', timestamp) as hour
          FROM analytics_events 
          WHERE ${timeFilter}
          ${filters.user_id ? 'AND user_id = $1' : ''}
          GROUP BY event_type, DATE_TRUNC('hour', timestamp)
          ORDER BY hour DESC
        `,
        orders: `
          SELECT event_type, COUNT(*) as count,
                 AVG(CAST(data->>'amount' AS DECIMAL)) as avg_amount,
                 DATE_TRUNC('hour', timestamp) as hour
          FROM order_analytics 
          WHERE ${timeFilter}
          ${filters.user_id ? 'AND user_id = $1' : ''}
          GROUP BY event_type, DATE_TRUNC('hour', timestamp)
          ORDER BY hour DESC
        `,
        payments: `
          SELECT method, status, COUNT(*) as count,
                 AVG(amount) as avg_amount,
                 SUM(amount) as total_amount,
                 DATE_TRUNC('hour', timestamp) as hour
          FROM payment_analytics 
          WHERE ${timeFilter}
          ${filters.user_id ? 'AND user_id = $1' : ''}
          GROUP BY method, status, DATE_TRUNC('hour', timestamp)
          ORDER BY hour DESC
        `
      };

      const params = filters.user_id ? [filters.user_id] : [];
      
      const [userEvents, orders, payments] = await Promise.all([
        this.pool.query(queries.user_events, params),
        this.pool.query(queries.orders, params),
        this.pool.query(queries.payments, params)
      ]);

      return {
        period,
        filters,
        data: {
          user_events: userEvents.rows,
          orders: orders.rows,
          payments: payments.rows
        },
        summary: this.calculateSummary(userEvents.rows, orders.rows, payments.rows)
      };
    } catch (error) {
      console.error('Erreur getting analytics by period:', error);
      throw error;
    }
  }

  // Obtenir le dashboard analytics
  async getDashboardAnalytics() {
    try {
      const queries = {
        total_users: 'SELECT COUNT(*) as count FROM users',
        active_users_today: `
          SELECT COUNT(DISTINCT user_id) as count 
          FROM analytics_events 
          WHERE DATE(timestamp) = CURRENT_DATE
        `,
        new_users_today: `
          SELECT COUNT(*) as count 
          FROM users 
          WHERE DATE(created_at) = CURRENT_DATE
        `,
        total_orders: 'SELECT COUNT(*) as count FROM orders',
        orders_today: `
          SELECT COUNT(*) as count,
                 AVG(total_amount) as avg_amount,
                 SUM(total_amount) as total_revenue
          FROM orders 
          WHERE DATE(created_at) = CURRENT_DATE
        `,
        total_payments: 'SELECT COUNT(*) as count FROM payments',
        payments_today: `
          SELECT COUNT(*) as count,
                 SUM(amount) as total_amount,
                 AVG(amount) as avg_amount
          FROM payments 
          WHERE DATE(paid_at) = CURRENT_DATE
        `,
        payment_methods: `
          SELECT method, COUNT(*) as count,
                 SUM(amount) as total_amount
          FROM payments 
          WHERE DATE(paid_at) = CURRENT_DATE
          GROUP BY method
        `,
        order_status: `
          SELECT status, COUNT(*) as count
          FROM orders 
          GROUP BY status
        `,
        top_products: `
          SELECT p.name, COUNT(oi.id) as order_count,
                 SUM(oi.quantity) as total_quantity
          FROM products p
          LEFT JOIN order_items oi ON p.id = oi.product_id
          GROUP BY p.id, p.name
          ORDER BY order_count DESC
          LIMIT 10
        `,
        user_growth: `
          SELECT DATE(created_at) as date, COUNT(*) as count
          FROM users 
          WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
          GROUP BY DATE(created_at)
          ORDER BY date
        `,
        revenue_trend: `
          SELECT DATE(paid_at) as date, 
                 SUM(amount) as daily_revenue,
                 COUNT(*) as payment_count
          FROM payments 
          WHERE paid_at >= CURRENT_DATE - INTERVAL '30 days'
          GROUP BY DATE(paid_at)
          ORDER BY date
        `
      };

      const [
        totalUsers,
        activeUsersToday,
        newUsersToday,
        totalOrders,
        ordersToday,
        totalPayments,
        paymentsToday,
        paymentMethods,
        orderStatus,
        topProducts,
        userGrowth,
        revenueTrend
      ] = await Promise.all([
        this.pool.query(queries.total_users),
        this.pool.query(queries.active_users_today),
        this.pool.query(queries.new_users_today),
        this.pool.query(queries.total_orders),
        this.pool.query(queries.orders_today),
        this.pool.query(queries.total_payments),
        this.pool.query(queries.payments_today),
        this.pool.query(queries.payment_methods),
        this.pool.query(queries.order_status),
        this.pool.query(queries.top_products),
        this.pool.query(queries.user_growth),
        this.pool.query(queries.revenue_trend)
      ]);

      return {
        users: {
          total: parseInt(totalUsers.rows[0].count),
          active_today: parseInt(activeUsersToday.rows[0].count),
          new_today: parseInt(newUsersToday.rows[0].count),
          growth: userGrowth.rows
        },
        orders: {
          total: parseInt(totalOrders.rows[0].count),
          today: parseInt(ordersToday.rows[0].count),
          avg_amount: parseFloat(ordersToday.rows[0].avg_amount || 0),
          total_revenue: parseFloat(ordersToday.rows[0].total_revenue || 0),
          status_breakdown: orderStatus.rows
        },
        payments: {
          total: parseInt(totalPayments.rows[0].count),
          today: parseInt(paymentsToday.rows[0].count),
          total_amount: parseFloat(paymentsToday.rows[0].total_amount || 0),
          avg_amount: parseFloat(paymentsToday.rows[0].avg_amount || 0),
          methods: paymentMethods.rows
        },
        products: {
          top_products: topProducts.rows
        },
        revenue: {
          trend: revenueTrend.rows,
          today: parseFloat(paymentsToday.rows[0].total_amount || 0)
        },
        performance: this.metrics.get('performance')
      };
    } catch (error) {
      console.error('Erreur getting dashboard analytics:', error);
      throw error;
    }
  }

  // Obtenir les analytics par utilisateur
  async getUserAnalytics(userId, period = '30d') {
    try {
      const timeFilter = this.getTimeFilter(period);

      const queries = {
        user_events: `
          SELECT event_type, COUNT(*) as count,
                 DATE_TRUNC('day', timestamp) as date
          FROM analytics_events 
          WHERE user_id = $1 AND ${timeFilter}
          GROUP BY event_type, DATE_TRUNC('day', timestamp)
          ORDER BY date DESC
        `,
        user_orders: `
          SELECT status, COUNT(*) as count,
                 AVG(total_amount) as avg_amount,
                 SUM(total_amount) as total_spent,
                 DATE_TRUNC('day', created_at) as date
          FROM orders 
          WHERE client_id = $1 AND ${timeFilter}
          GROUP BY status, DATE_TRUNC('day', created_at)
          ORDER BY date DESC
        `,
        user_payments: `
          SELECT method, status, COUNT(*) as count,
                 AVG(amount) as avg_amount,
                 SUM(amount) as total_amount,
                 DATE_TRUNC('day', paid_at) as date
          FROM payments 
          WHERE user_id = $1 AND ${timeFilter}
          GROUP BY method, status, DATE_TRUNC('day', paid_at)
          ORDER BY date DESC
        `
      };

      const [userEvents, userOrders, userPayments] = await Promise.all([
        this.pool.query(queries.user_events, [userId]),
        this.pool.query(queries.user_orders, [userId]),
        this.pool.query(queries.user_payments, [userId])
      ]);

      return {
        user_id: userId,
        period,
        events: userEvents.rows,
        orders: userOrders.rows,
        payments: userPayments.rows,
        summary: this.calculateUserSummary(userEvents.rows, userOrders.rows, userPayments.rows)
      };
    } catch (error) {
      console.error('Erreur getting user analytics:', error);
      throw error;
    }
  }

  // Mettre à jour les métriques en temps réel
  updateRealTimeMetrics(eventType, data) {
    const currentData = this.realTimeData.get(eventType) || { count: 0, last_updated: new Date() };
    currentData.count++;
    currentData.last_updated = new Date();
    currentData.last_data = data;
    
    this.realTimeData.set(eventType, currentData);
  }

  // Mettre à jour les métriques de commandes
  updateOrderMetrics(eventType, data) {
    const orderMetrics = this.metrics.get('orders');
    
    switch (eventType) {
      case 'order_created':
        orderMetrics.total++;
        orderMetrics.today++;
        orderMetrics.pending++;
        break;
      case 'order_confirmed':
        orderMetrics.pending--;
        orderMetrics.confirmed++;
        break;
      case 'order_in_transit':
        orderMetrics.confirmed--;
        orderMetrics.in_transit++;
        break;
      case 'order_delivered':
        orderMetrics.in_transit--;
        orderMetrics.delivered++;
        orderMetrics.total_revenue += data.amount || 0;
        break;
      case 'order_cancelled':
        orderMetrics.pending--;
        orderMetrics.cancelled++;
        break;
    }
    
    // Calculer la valeur moyenne
    if (orderMetrics.total > 0) {
      orderMetrics.avg_value = orderMetrics.total_revenue / orderMetrics.delivered;
    }
  }

  // Mettre à jour les métriques de paiements
  updatePaymentMetrics(eventType, data) {
    const paymentMetrics = this.metrics.get('payments');
    
    switch (eventType) {
      case 'payment_initiated':
        paymentMetrics.total++;
        paymentMetrics.today++;
        paymentMetrics.pending++;
        break;
      case 'payment_successful':
        paymentMetrics.pending--;
        paymentMetrics.successful++;
        paymentMetrics.total_amount += data.amount || 0;
        if (data.method) {
          paymentMetrics.by_method[data.method] = (paymentMetrics.by_method[data.method] || 0) + 1;
        }
        break;
      case 'payment_failed':
        paymentMetrics.pending--;
        paymentMetrics.failed++;
        break;
    }
    
    // Calculer le montant moyen
    if (paymentMetrics.successful > 0) {
      paymentMetrics.avg_amount = paymentMetrics.total_amount / paymentMetrics.successful;
    }
  }

  // Calculer le temps de réponse moyen
  calculateAverageResponseTime(newTime, currentAverage) {
    if (currentAverage === 0) return newTime;
    return (currentAverage + newTime) / 2;
  }

  // Calculer le taux d'erreur
  calculateErrorRate(statusCode, currentRate) {
    return statusCode >= 400 ? Math.min(currentRate + 0.01, 1) : Math.max(currentRate - 0.01, 0);
  }

  // Obtenir le filtre de temps
  getTimeFilter(period) {
    switch (period) {
      case '1h':
        return "timestamp >= NOW() - INTERVAL '1 hour'";
      case '24h':
        return "timestamp >= NOW() - INTERVAL '24 hours'";
      case '7d':
        return "timestamp >= NOW() - INTERVAL '7 days'";
      case '30d':
        return "timestamp >= NOW() - INTERVAL '30 days'";
      default:
        return "timestamp >= NOW() - INTERVAL '24 hours'";
    }
  }

  // Calculer le résumé des analytics
  calculateSummary(userEvents, orders, payments) {
    return {
      total_events: userEvents.reduce((sum, event) => sum + parseInt(event.count), 0),
      total_orders: orders.reduce((sum, order) => sum + parseInt(order.count), 0),
      total_payments: payments.reduce((sum, payment) => sum + parseInt(payment.count), 0),
      avg_order_value: orders.reduce((sum, order) => sum + parseFloat(order.avg_amount || 0), 0) / orders.length || 0,
      avg_payment_amount: payments.reduce((sum, payment) => sum + parseFloat(payment.avg_amount || 0), 0) / payments.length || 0
    };
  }

  // Calculer le résumé utilisateur
  calculateUserSummary(events, orders, payments) {
    return {
      total_events: events.reduce((sum, event) => sum + parseInt(event.count), 0),
      total_orders: orders.reduce((sum, order) => sum + parseInt(order.count), 0),
      total_spent: payments.reduce((sum, payment) => sum + parseFloat(payment.total_amount || 0), 0),
      avg_order_value: orders.reduce((sum, order) => sum + parseFloat(order.avg_amount || 0), 0) / orders.length || 0,
      favorite_payment_method: this.getFavoritePaymentMethod(payments)
    };
  }

  // Obtenir la méthode de paiement préférée
  getFavoritePaymentMethod(payments) {
    const methodCounts = {};
    payments.forEach(payment => {
      methodCounts[payment.method] = (methodCounts[payment.method] || 0) + parseInt(payment.count);
    });
    
    return Object.keys(methodCounts).reduce((a, b) => methodCounts[a] > methodCounts[b] ? a : b, null);
  }

  // Générer un ID unique
  generateId() {
    return `analytics_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  // Nettoyer les anciennes données
  async cleanupOldData(daysToKeep = 90) {
    try {
      await this.pool.query(
        `DELETE FROM analytics_events WHERE timestamp < NOW() - INTERVAL '${daysToKeep} days'`
      );
      await this.pool.query(
        `DELETE FROM order_analytics WHERE timestamp < NOW() - INTERVAL '${daysToKeep} days'`
      );
      await this.pool.query(
        `DELETE FROM payment_analytics WHERE timestamp < NOW() - INTERVAL '${daysToKeep} days'`
      );
      
      console.log(`Nettoyage des données analytics de plus de ${daysToKeep} jours terminé`);
    } catch (error) {
      console.error('Erreur lors du nettoyage des anciennes données:', error);
    }
  }
}

module.exports = AnalyticsService;
