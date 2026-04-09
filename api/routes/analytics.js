const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const AnalyticsService = require('../services/analyticsService');

// Configuration PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: false,
});

// Initialiser le service d'analytics
const analyticsService = new AnalyticsService();

// Middleware pour tracker les événements API
const trackApiCall = (req, res, next) => {
  const startTime = Date.now();
  
  res.on('finish', () => {
    const responseTime = Date.now() - startTime;
    
    // Tracker les performances
    analyticsService.trackPerformance(req.path, responseTime, res.statusCode);
    
    // Tracker les événements utilisateur si authentifié
    if (req.user) {
      analyticsService.trackUserEvent('api_call', req.user.id, {
        endpoint: req.path,
        method: req.method,
        response_time: responseTime,
        status_code: res.statusCode,
        ip_address: req.ip,
        user_agent: req.get('User-Agent')
      }).catch(err => console.error('Analytics tracking error:', err));
    }
  });
  
  next();
};

// Appliquer le middleware de tracking à toutes les routes analytics
router.use(trackApiCall);

// Obtenir le dashboard analytics (admin seulement)
router.get('/dashboard', async (req, res) => {
  try {
    // Vérifier si l'utilisateur est admin
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }

    const dashboardData = await analyticsService.getDashboardAnalytics();
    res.json(dashboardData);
  } catch (error) {
    console.error('Erreur dashboard analytics:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics par période
router.get('/period/:period', async (req, res) => {
  try {
    const { period } = req.params;
    const { user_id, start_date, end_date } = req.query;
    
    // Valider la période
    const validPeriods = ['1h', '24h', '7d', '30d'];
    if (!validPeriods.includes(period)) {
      return res.status(400).json({ error: 'Période invalide' });
    }

    const filters = {};
    if (user_id) filters.user_id = user_id;
    if (start_date) filters.start_date = start_date;
    if (end_date) filters.end_date = end_date;

    const analyticsData = await analyticsService.getAnalyticsByPeriod(period, filters);
    res.json(analyticsData);
  } catch (error) {
    console.error('Erreur analytics par période:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics d'un utilisateur spécifique
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { period = '30d' } = req.query;
    
    // Vérifier si l'utilisateur peut voir ces analytics
    if (req.user?.role !== 'admin' && req.user?.id !== userId) {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }

    const userAnalytics = await analyticsService.getUserAnalytics(userId, period);
    res.json(userAnalytics);
  } catch (error) {
    console.error('Erreur analytics utilisateur:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les métriques en temps réel
router.get('/realtime', async (req, res) => {
  try {
    // Vérifier si l'utilisateur est admin
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }

    const realTimeMetrics = analyticsService.getRealTimeMetrics();
    res.json(realTimeMetrics);
  } catch (error) {
    console.error('Erreur métriques temps réel:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Tracker un événement utilisateur manuellement
router.post('/track', async (req, res) => {
  try {
    const { event_type, data } = req.body;
    
    if (!event_type) {
      return res.status(400).json({ error: 'event_type est requis' });
    }

    const event = await analyticsService.trackUserEvent(event_type, req.user?.id, {
      ...data,
      ip_address: req.ip,
      user_agent: req.get('User-Agent'),
      session_id: req.session?.id
    });

    res.json({ success: true, event });
  } catch (error) {
    console.error('Erreur tracking événement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics de produits
router.get('/products', async (req, res) => {
  try {
    const { period = '30d', category, vendor_id } = req.query;
    
    let query = `
      SELECT p.id, p.name, p.category, p.price, p.vendor_id,
             COUNT(oi.id) as order_count,
             SUM(oi.quantity) as total_quantity,
             SUM(oi.quantity * oi.price) as total_revenue,
             AVG(oi.price) as avg_price
      FROM products p
      LEFT JOIN order_items oi ON p.id = oi.product_id
      LEFT JOIN orders o ON oi.order_id = o.id
      WHERE o.created_at >= NOW() - INTERVAL '${period}'
    `;
    
    const params = [];
    const conditions = [];
    
    if (category) {
      conditions.push('p.category = $' + (params.length + 1));
      params.push(category);
    }
    
    if (vendor_id) {
      conditions.push('p.vendor_id = $' + (params.length + 1));
      params.push(vendor_id);
    }
    
    if (conditions.length > 0) {
      query += ' AND ' + conditions.join(' AND ');
    }
    
    query += `
      GROUP BY p.id, p.name, p.category, p.price, p.vendor_id
      ORDER BY total_revenue DESC
      LIMIT 50
    `;
    
    const result = await pool.query(query, params);
    
    res.json({
      period,
      products: result.rows,
      summary: {
        total_products: result.rows.length,
        total_revenue: result.rows.reduce((sum, p) => sum + parseFloat(p.total_revenue || 0), 0),
        avg_revenue_per_product: result.rows.reduce((sum, p) => sum + parseFloat(p.total_revenue || 0), 0) / result.rows.length || 0
      }
    });
  } catch (error) {
    console.error('Erreur analytics produits:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics de revenus
router.get('/revenue', async (req, res) => {
  try {
    const { period = '30d', group_by = 'day' } = req.query;
    
    let groupBy;
    switch (group_by) {
      case 'hour':
        groupBy = 'DATE_TRUNC(\'hour\', paid_at)';
        break;
      case 'day':
        groupBy = 'DATE_TRUNC(\'day\', paid_at)';
        break;
      case 'week':
        groupBy = 'DATE_TRUNC(\'week\', paid_at)';
        break;
      case 'month':
        groupBy = 'DATE_TRUNC(\'month\', paid_at)';
        break;
      default:
        groupBy = 'DATE_TRUNC(\'day\', paid_at)';
    }
    
    const query = `
      SELECT ${groupBy} as period,
             COUNT(*) as payment_count,
             SUM(amount) as total_revenue,
             AVG(amount) as avg_amount,
             MIN(amount) as min_amount,
             MAX(amount) as max_amount
      FROM payments 
      WHERE paid_at >= NOW() - INTERVAL '${period}'
      GROUP BY ${groupBy}
      ORDER BY period DESC
    `;
    
    const result = await pool.query(query);
    
    // Calculer les tendances
    const revenues = result.rows.map(row => parseFloat(row.total_revenue || 0));
    const trend = revenues.length > 1 ? 
      ((revenues[0] - revenues[revenues.length - 1]) / revenues[revenues.length - 1]) * 100 : 0;
    
    res.json({
      period,
      group_by,
      data: result.rows,
      summary: {
        total_revenue: revenues.reduce((sum, r) => sum + r, 0),
        avg_daily_revenue: revenues.reduce((sum, r) => sum + r, 0) / revenues.length || 0,
        trend_percentage: trend,
        total_payments: result.rows.reduce((sum, r) => sum + parseInt(r.payment_count), 0)
      }
    });
  } catch (error) {
    console.error('Erreur analytics revenus:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics d'utilisateurs
router.get('/users', async (req, res) => {
  try {
    const { period = '30d', role, active_only = false } = req.query;
    
    let query = `
      SELECT u.id, u.email, u.role, u.created_at,
             COUNT(DISTINCT o.id) as order_count,
             COUNT(DISTINCT p.id) as payment_count,
             COALESCE(SUM(p.amount), 0) as total_spent,
             COALESCE(AVG(p.amount), 0) as avg_payment,
             MAX(ae.timestamp) as last_activity
      FROM users u
      LEFT JOIN orders o ON u.id = o.client_id
      LEFT JOIN payments p ON u.id = p.user_id
      LEFT JOIN analytics_events ae ON u.id = ae.user_id
    `;
    
    const params = [];
    const conditions = [];
    
    if (role) {
      conditions.push('u.role = $' + (params.length + 1));
      params.push(role);
    }
    
    if (active_only === 'true') {
      conditions.push('ae.timestamp >= NOW() - INTERVAL \'' + period + '\'');
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += `
      GROUP BY u.id, u.email, u.role, u.created_at
      ORDER BY total_spent DESC
      LIMIT 100
    `;
    
    const result = await pool.query(query, params);
    
    res.json({
      period,
      users: result.rows,
      summary: {
        total_users: result.rows.length,
        total_revenue: result.rows.reduce((sum, u) => sum + parseFloat(u.total_spent || 0), 0),
        avg_spent_per_user: result.rows.reduce((sum, u) => sum + parseFloat(u.total_spent || 0), 0) / result.rows.length || 0,
        active_users: result.rows.filter(u => u.last_activity).length
      }
    });
  } catch (error) {
    console.error('Erreur analytics utilisateurs:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics de performance
router.get('/performance', async (req, res) => {
  try {
    const { period = '24h' } = req.query;
    
    const queries = {
      response_times: `
        SELECT endpoint,
               AVG(response_time) as avg_response_time,
               MIN(response_time) as min_response_time,
               MAX(response_time) as max_response_time,
               COUNT(*) as request_count
        FROM performance_logs 
        WHERE timestamp >= NOW() - INTERVAL '${period}'
        GROUP BY endpoint
        ORDER BY avg_response_time DESC
      `,
      error_rates: `
        SELECT endpoint,
               COUNT(*) as total_requests,
               SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) as error_count,
               (SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as error_rate
        FROM performance_logs 
        WHERE timestamp >= NOW() - INTERVAL '${period}'
        GROUP BY endpoint
        ORDER BY error_rate DESC
      `,
      traffic_patterns: `
        SELECT DATE_TRUNC('hour', timestamp) as hour,
               COUNT(*) as request_count,
               AVG(response_time) as avg_response_time
        FROM performance_logs 
        WHERE timestamp >= NOW() - INTERVAL '${period}'
        GROUP BY DATE_TRUNC('hour', timestamp)
        ORDER BY hour DESC
      `
    };
    
    const [responseTimes, errorRates, trafficPatterns] = await Promise.all([
      pool.query(queries.response_times),
      pool.query(queries.error_rates),
      pool.query(queries.traffic_patterns)
    ]);
    
    res.json({
      period,
      response_times: responseTimes.rows,
      error_rates: errorRates.rows,
      traffic_patterns: trafficPatterns.rows,
      summary: {
        avg_response_time: responseTimes.rows.reduce((sum, r) => sum + parseFloat(r.avg_response_time || 0), 0) / responseTimes.rows.length || 0,
        overall_error_rate: errorRates.rows.reduce((sum, r) => sum + parseFloat(r.error_rate || 0), 0) / errorRates.rows.length || 0,
        total_requests: responseTimes.rows.reduce((sum, r) => sum + parseInt(r.request_count), 0)
      }
    });
  } catch (error) {
    console.error('Erreur analytics performance:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir les analytics géographiques
router.get('/geographic', async (req, res) => {
  try {
    const { period = '30d' } = req.query;
    
    const queries = {
      orders_by_location: `
        SELECT 
               CASE 
                 WHEN pickup_address LIKE '%Abidjan%' THEN 'Abidjan'
                 WHEN pickup_address LIKE '%Bouaké%' THEN 'Bouaké'
                 WHEN pickup_address LIKE '%Daloa%' THEN 'Daloa'
                 ELSE 'Autre'
               END as city,
               COUNT(*) as order_count,
               SUM(total_amount) as total_revenue
        FROM orders 
        WHERE created_at >= NOW() - INTERVAL '${period}'
        GROUP BY city
        ORDER BY order_count DESC
      `,
      users_by_location: `
        SELECT 
               CASE 
                 WHEN phone_number LIKE '+22507%' THEN 'Abidjan'
                 WHEN phone_number LIKE '+22505%' THEN 'Intérieur'
                 ELSE 'Autre'
               END as region,
               COUNT(*) as user_count
        FROM users 
        WHERE created_at >= NOW() - INTERVAL '${period}'
        GROUP BY region
        ORDER BY user_count DESC
      `
    };
    
    const [ordersByLocation, usersByLocation] = await Promise.all([
      pool.query(queries.orders_by_location),
      pool.query(queries.users_by_location)
    ]);
    
    res.json({
      period,
      orders_by_location: ordersByLocation.rows,
      users_by_location: usersByLocation.rows
    });
  } catch (error) {
    console.error('Erreur analytics géographiques:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Exporter les analytics
router.get('/export', async (req, res) => {
  try {
    const { type = 'dashboard', format = 'json', period = '30d' } = req.query;
    
    // Vérifier si l'utilisateur est admin
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }
    
    let data;
    
    switch (type) {
      case 'dashboard':
        data = await analyticsService.getDashboardAnalytics();
        break;
      case 'users':
        data = await analyticsService.getAnalyticsByPeriod(period, {});
        break;
      case 'products':
        const productsQuery = `
          SELECT p.*, COUNT(oi.id) as order_count
          FROM products p
          LEFT JOIN order_items oi ON p.id = oi.product_id
          GROUP BY p.id
          ORDER BY order_count DESC
        `;
        const productsResult = await pool.query(productsQuery);
        data = { products: productsResult.rows };
        break;
      default:
        return res.status(400).json({ error: 'Type d\'export invalide' });
    }
    
    // Format de sortie
    switch (format) {
      case 'csv':
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="analytics_${type}_${period}.csv"`);
        // Convertir en CSV (simplifié)
        res.send(JSON.stringify(data));
        break;
      case 'excel':
        res.setHeader('Content-Type', 'application/vnd.ms-excel');
        res.setHeader('Content-Disposition', `attachment; filename="analytics_${type}_${period}.xlsx"`);
        // Convertir en Excel (nécessiterait une bibliothèque comme xlsx)
        res.send(JSON.stringify(data));
        break;
      default:
        res.json(data);
    }
  } catch (error) {
    console.error('Erreur export analytics:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Nettoyer les anciennes données (admin seulement)
router.delete('/cleanup', async (req, res) => {
  try {
    // Vérifier si l'utilisateur est admin
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }
    
    const { days_to_keep = 90 } = req.body;
    
    await analyticsService.cleanupOldData(days_to_keep);
    
    res.json({ 
      success: true, 
      message: `Données de plus de ${days_to_keep} jours supprimées avec succès` 
    });
  } catch (error) {
    console.error('Erreur nettoyage analytics:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// WebSocket endpoint pour les mises à jour en temps réel
router.get('/ws', (req, res) => {
  // Implémenter WebSocket pour les mises à jour en temps réel
  res.json({ message: 'WebSocket endpoint pour analytics en temps réel' });
});

module.exports = router;
