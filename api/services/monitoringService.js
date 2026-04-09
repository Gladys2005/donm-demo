const client = require('prom-client');
const EventEmitter = require('events');

class MonitoringService extends EventEmitter {
  constructor() {
    super();
    this.register = new client.Registry();
    this.initializeMetrics();
    this.setupDefaultMetrics();
  }

  // Initialiser les métriques Prometheus
  initializeMetrics() {
    // Métriques HTTP
    this.httpRequestDuration = new client.Histogram({
      name: 'http_request_duration_seconds',
      help: 'Duration of HTTP requests in seconds',
      labelNames: ['method', 'route', 'status_code'],
      buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5]
    });

    this.httpRequestTotal = new client.Counter({
      name: 'http_requests_total',
      help: 'Total number of HTTP requests',
      labelNames: ['method', 'route', 'status_code']
    });

    // Métriques d'authentification
    this.authAttempts = new client.Counter({
      name: 'auth_attempts_total',
      help: 'Total number of authentication attempts',
      labelNames: ['type', 'success']
    });

    this.activeUsers = new client.Gauge({
      name: 'active_users_total',
      help: 'Number of currently active users',
      labelNames: ['role']
    });

    // Métriques de commandes
    this.ordersTotal = new client.Counter({
      name: 'orders_total',
      help: 'Total number of orders',
      labelNames: ['status']
    });

    this.orderValue = new client.Histogram({
      name: 'order_value_fcfa',
      help: 'Order value in FCFA',
      labelNames: ['status'],
      buckets: [1000, 2000, 5000, 10000, 20000, 50000, 100000]
    });

    // Métriques de paiements
    this.paymentAttempts = new client.Counter({
      name: 'payment_attempts_total',
      help: 'Total number of payment attempts',
      labelNames: ['method', 'success']
    });

    this.paymentValue = new client.Histogram({
      name: 'payment_value_fcfa',
      help: 'Payment value in FCFA',
      labelNames: ['method', 'status'],
      buckets: [1000, 2000, 5000, 10000, 20000, 50000, 100000]
    });

    // Métriques de produits
    this.productsTotal = new client.Gauge({
      name: 'products_total',
      help: 'Total number of products',
      labelNames: ['category', 'available']
    });

    // Métriques de base de données
    this.dbConnectionPool = new client.Gauge({
      name: 'db_connection_pool_active',
      help: 'Number of active database connections'
    });

    this.dbQueryDuration = new client.Histogram({
      name: 'db_query_duration_seconds',
      help: 'Duration of database queries in seconds',
      labelNames: ['query_type'],
      buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 2]
    });

    // Métriques de cache
    this.cacheHits = new client.Counter({
      name: 'cache_hits_total',
      help: 'Total number of cache hits',
      labelNames: ['cache_type']
    });

    this.cacheMisses = new client.Counter({
      name: 'cache_misses_total',
      help: 'Total number of cache misses',
      labelNames: ['cache_type']
    });

    // Métriques de notifications
    this.notificationsSent = new client.Counter({
      name: 'notifications_sent_total',
      help: 'Total number of notifications sent',
      labelNames: ['type', 'channel']
    });

    // Métriques système
    this.memoryUsage = new client.Gauge({
      name: 'memory_usage_bytes',
      help: 'Memory usage in bytes'
    });

    this.cpuUsage = new client.Gauge({
      name: 'cpu_usage_percent',
      help: 'CPU usage percentage'
    });

    // Métriques d'erreurs
    this.errorTotal = new client.Counter({
      name: 'errors_total',
      help: 'Total number of errors',
      labelNames: ['type', 'severity']
    });

    // Métriques Mobile Money
    this.mobileMoneyTransactions = new client.Counter({
      name: 'mobile_money_transactions_total',
      help: 'Total number of mobile money transactions',
      labelNames: ['operator', 'status']
    });

    this.mobileMoneyValue = new client.Histogram({
      name: 'mobile_money_value_fcfa',
      help: 'Mobile money transaction value in FCFA',
      labelNames: ['operator', 'status'],
      buckets: [1000, 2000, 5000, 10000, 20000, 50000, 100000]
    });

    // Métriques Socket.IO
    this.socketConnections = new client.Gauge({
      name: 'socket_connections_total',
      help: 'Total number of active socket connections'
    });

    this.socketEvents = new client.Counter({
      name: 'socket_events_total',
      help: 'Total number of socket events',
      labelNames: ['event_type']
    });

    // Enregistrer toutes les métriques
    this.register.registerMetric(this.httpRequestDuration);
    this.register.registerMetric(this.httpRequestTotal);
    this.register.registerMetric(this.authAttempts);
    this.register.registerMetric(this.activeUsers);
    this.register.registerMetric(this.ordersTotal);
    this.register.registerMetric(this.orderValue);
    this.register.registerMetric(this.paymentAttempts);
    this.register.registerMetric(this.paymentValue);
    this.register.registerMetric(this.productsTotal);
    this.register.registerMetric(this.dbConnectionPool);
    this.register.registerMetric(this.dbQueryDuration);
    this.register.registerMetric(this.cacheHits);
    this.register.registerMetric(this.cacheMisses);
    this.register.registerMetric(this.notificationsSent);
    this.register.registerMetric(this.memoryUsage);
    this.register.registerMetric(this.cpuUsage);
    this.register.registerMetric(this.errorTotal);
    this.register.registerMetric(this.mobileMoneyTransactions);
    this.register.registerMetric(this.mobileMoneyValue);
    this.register.registerMetric(this.socketConnections);
    this.register.registerMetric(this.socketEvents);
  }

  // Configurer les métriques par défaut
  setupDefaultMetrics() {
    client.collectDefaultMetrics({
      register: this.register,
      prefix: 'donm_'
    });
  }

  // Middleware Express pour le monitoring
  middleware() {
    return (req, res, next) => {
      const start = Date.now();
      
      res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;
        const route = req.route ? req.route.path : req.path;
        
        this.httpRequestDuration
          .labels(req.method, route, res.statusCode)
          .observe(duration);
        
        this.httpRequestTotal
          .labels(req.method, route, res.statusCode)
          .inc();
        
        // Émettre l'événement pour le monitoring en temps réel
        this.emit('httpRequest', {
          method: req.method,
          route: route,
          statusCode: res.statusCode,
          duration: duration,
          userAgent: req.get('User-Agent'),
          ip: req.ip
        });
      });
      
      next();
    };
  }

  // Tracker les tentatives d'authentification
  trackAuthAttempt(type, success, userId = null) {
    this.authAttempts.labels(type, success.toString()).inc();
    
    this.emit('authAttempt', {
      type: type,
      success: success,
      userId: userId,
      timestamp: new Date()
    });
  }

  // Tracker les utilisateurs actifs
  updateActiveUsers(role, count) {
    this.activeUsers.labels(role).set(count);
  }

  // Tracker les commandes
  trackOrder(status, value = null) {
    this.ordersTotal.labels(status).inc();
    
    if (value) {
      this.orderValue.labels(status).observe(value);
    }
    
    this.emit('orderEvent', {
      status: status,
      value: value,
      timestamp: new Date()
    });
  }

  // Tracker les paiements
  trackPayment(method, success, value = null) {
    this.paymentAttempts.labels(method, success.toString()).inc();
    
    if (value) {
      this.paymentValue.labels(method, success ? 'success' : 'failed').observe(value);
    }
    
    this.emit('paymentEvent', {
      method: method,
      success: success,
      value: value,
      timestamp: new Date()
    });
  }

  // Tracker les produits
  updateProducts(category, available, count) {
    this.productsTotal.labels(category, available.toString()).set(count);
  }

  // Tracker les connexions à la base de données
  updateDbConnections(active) {
    this.dbConnectionPool.set(active);
  }

  // Tracker les requêtes base de données
  trackDbQuery(queryType, duration) {
    this.dbQueryDuration.labels(queryType).observe(duration);
  }

  // Tracker le cache
  trackCacheHit(cacheType) {
    this.cacheHits.labels(cacheType).inc();
  }

  trackCacheMiss(cacheType) {
    this.cacheMisses.labels(cacheType).inc();
  }

  // Tracker les notifications
  trackNotification(type, channel) {
    this.notificationsSent.labels(type, channel).inc();
    
    this.emit('notificationSent', {
      type: type,
      channel: channel,
      timestamp: new Date()
    });
  }

  // Tracker les erreurs
  trackError(type, severity, error = null) {
    this.errorTotal.labels(type, severity).inc();
    
    this.emit('error', {
      type: type,
      severity: severity,
      error: error ? error.message : null,
      stack: error ? error.stack : null,
      timestamp: new Date()
    });
  }

  // Tracker les transactions Mobile Money
  trackMobileMoneyTransaction(operator, status, value = null) {
    this.mobileMoneyTransactions.labels(operator, status).inc();
    
    if (value) {
      this.mobileMoneyValue.labels(operator, status).observe(value);
    }
    
    this.emit('mobileMoneyTransaction', {
      operator: operator,
      status: status,
      value: value,
      timestamp: new Date()
    });
  }

  // Tracker les connexions Socket.IO
  updateSocketConnections(count) {
    this.socketConnections.set(count);
  }

  // Tracker les événements Socket.IO
  trackSocketEvent(eventType) {
    this.socketEvents.labels(eventType).inc();
  }

  // Mettre à jour les métriques système
  updateSystemMetrics() {
    const memUsage = process.memoryUsage();
    this.memoryUsage.set(memUsage.heapUsed);
    
    // CPU usage (nécessite une bibliothèque supplémentaire pour une mesure précise)
    if (process.cpuUsage) {
      const cpuUsage = process.cpuUsage();
      const totalUsage = (cpuUsage.user + cpuUsage.system) / 1000000; // Convertir en secondes
      this.cpuUsage.set(totalUsage);
    }
  }

  // Obtenir les métriques au format Prometheus
  getMetrics() {
    return this.register.metrics();
  }

  // Obtenir le registre
  getRegistry() {
    return this.register;
  }

  // Réinitialiser les métriques
  resetMetrics() {
    this.register.reset();
  }

  // Health check détaillé
  async getHealthStatus() {
    const memUsage = process.memoryUsage();
    const uptime = process.uptime();
    
    return {
      status: 'healthy',
      uptime: uptime,
      memory: {
        used: memUsage.heapUsed,
        total: memUsage.heapTotal,
        external: memUsage.external,
        rss: memUsage.rss
      },
      metrics: {
        total: this.register.getMetricsAsJSON().length,
        http_requests: this.httpRequestTotal.get(),
        active_users: this.activeUsers.get(),
        orders: this.ordersTotal.get(),
        payments: this.paymentAttempts.get()
      },
      timestamp: new Date()
    };
  }

  // Dashboard personnalisé pour Grafana
  getGrafanaDashboard() {
    return {
      dashboard: {
        title: "DonM Application Monitoring",
        tags: ["donm", "production"],
        timezone: "browser",
        panels: [
          {
            title: "HTTP Requests Rate",
            type: "graph",
            targets: [
              {
                expr: "rate(donm_http_requests_total[5m])",
                legendFormat: "{{method}} {{route}}"
              }
            ],
            gridPos: { h: 8, w: 12, x: 0, y: 0 }
          },
          {
            title: "HTTP Request Duration",
            type: "graph",
            targets: [
              {
                expr: "histogram_quantile(0.95, rate(donm_http_request_duration_seconds_bucket[5m]))",
                legendFormat: "95th percentile"
              },
              {
                expr: "histogram_quantile(0.50, rate(donm_http_request_duration_seconds_bucket[5m]))",
                legendFormat: "50th percentile"
              }
            ],
            gridPos: { h: 8, w: 12, x: 12, y: 0 }
          },
          {
            title: "Active Users",
            type: "stat",
            targets: [
              {
                expr: "donm_active_users_total",
                legendFormat: "{{role}}"
              }
            ],
            gridPos: { h: 8, w: 6, x: 0, y: 8 }
          },
          {
            title: "Orders by Status",
            type: "piechart",
            targets: [
              {
                expr: "donm_orders_total",
                legendFormat: "{{status}}"
              }
            ],
            gridPos: { h: 8, w: 6, x: 6, y: 8 }
          },
          {
            title: "Payment Success Rate",
            type: "stat",
            targets: [
              {
                expr: "rate(donm_payment_attempts_total{success=\"true\"}[5m]) / rate(donm_payment_attempts_total[5m]) * 100",
                legendFormat: "Success Rate %"
              }
            ],
            gridPos: { h: 8, w: 6, x: 12, y: 8 }
          },
          {
            title: "Memory Usage",
            type: "graph",
            targets: [
              {
                expr: "donm_memory_usage_bytes / 1024 / 1024",
                legendFormat: "MB"
              }
            ],
            gridPos: { h: 8, w: 6, x: 18, y: 8 }
          },
          {
            title: "Order Values",
            type: "graph",
            targets: [
              {
                expr: "histogram_quantile(0.95, rate(donm_order_value_fcfa_bucket[5m]))",
                legendFormat: "95th percentile"
              }
            ],
            gridPos: { h: 8, w: 12, x: 0, y: 16 }
          },
          {
            title: "Mobile Money Transactions",
            type: "graph",
            targets: [
              {
                expr: "rate(donm_mobile_money_transactions_total[5m])",
                legendFormat: "{{operator}} {{status}}"
              }
            ],
            gridPos: { h: 8, w: 12, x: 12, y: 16 }
          },
          {
            title: "Error Rate",
            type: "graph",
            targets: [
              {
                expr: "rate(donm_errors_total[5m])",
                legendFormat: "{{type}} {{severity}}"
              }
            ],
            gridPos: { h: 8, w: 24, x: 0, y: 24 }
          }
        ],
        time: {
          from: "now-1h",
          to: "now"
        },
        refresh: "5s"
      }
    };
  }

  // Alertes personnalisées
  getAlertRules() {
    return {
      groups: [
        {
          name: "donm.rules",
          rules: [
            {
              alert: "HighErrorRate",
              expr: "rate(donm_errors_total[5m]) > 0.1",
              for: "5m",
              labels: {
                severity: "warning"
              },
              annotations: {
                summary: "High error rate detected",
                description: "Error rate is {{ $value }} errors per second"
              }
            },
            {
              alert: "HighMemoryUsage",
              expr: "donm_memory_usage_bytes / donm_memory_usage_bytes > 0.9",
              for: "5m",
              labels: {
                severity: "critical"
              },
              annotations: {
                summary: "High memory usage",
                description: "Memory usage is above 90%"
              }
            },
            {
              alert: "NoActiveUsers",
              expr: "sum(donm_active_users_total) == 0",
              for: "10m",
              labels: {
                severity: "warning"
              },
              annotations: {
                summary: "No active users",
                description: "No users have been active for 10 minutes"
              }
            },
            {
              alert: "PaymentFailureRate",
              expr: "rate(donm_payment_attempts_total{success=\"false\"}[5m]) / rate(donm_payment_attempts_total[5m]) > 0.3",
              for: "5m",
              labels: {
                severity: "critical"
              },
              annotations: {
                summary: "High payment failure rate",
                description: "Payment failure rate is {{ $value | humanizePercentage }}"
              }
            },
            {
              alert: "SlowHTTPRequests",
              expr: "histogram_quantile(0.95, rate(donm_http_request_duration_seconds_bucket[5m])) > 2",
              for: "5m",
              labels: {
                severity: "warning"
              },
              annotations: {
                summary: "Slow HTTP requests",
                description: "95th percentile response time is {{ $value }}s"
              }
            }
          ]
        }
      ]
    };
  }

  // Monitoring des performances en temps réel
  startRealTimeMonitoring(intervalMs = 30000) {
    setInterval(() => {
      this.updateSystemMetrics();
      this.emit('systemMetricsUpdated', {
        timestamp: new Date(),
        memory: process.memoryUsage(),
        uptime: process.uptime()
      });
    }, intervalMs);
  }

  // Export des métriques pour l'intégration externe
  exportMetrics(format = 'prometheus') {
    switch (format) {
      case 'prometheus':
        return this.getMetrics();
      case 'json':
        return this.register.getMetricsAsJSON();
      case 'influx':
        return this.convertToInfluxFormat();
      default:
        return this.getMetrics();
    }
  }

  // Conversion au format InfluxDB
  convertToInfluxFormat() {
    const metrics = this.register.getMetricsAsJSON();
    const influxData = [];
    
    metrics.forEach(metric => {
      metric.values.forEach(value => {
        const point = {
          measurement: metric.name,
          tags: value.labels,
          fields: {
            value: value.value
          },
          timestamp: new Date().toISOString()
        };
        influxData.push(point);
      });
    });
    
    return influxData;
  }
}

module.exports = MonitoringService;
