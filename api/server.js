const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

// Importer les routes et middleware
const authRoutes = require('./routes/auth');
const paymentRoutes = require('./routes/payments');
const notificationRoutes = require('./routes/notifications');
const analyticsRoutes = require('./routes/analytics');
const AnalyticsService = require('./services/analyticsService');
const CacheService = require('./services/cacheService');
const MonitoringService = require('./services/monitoringService');
const { createNotification } = require('./routes/notifications');
const { authenticateToken, requireRole, optionalAuth } = require('./middleware/auth');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;

// Stocker l'instance Socket.IO dans l'app pour l'utiliser dans les routes
app.set('io', io);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test de connexion à la base de données
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Erreur de connexion à PostgreSQL:', err);
  } else {
    console.log('Connecté à PostgreSQL:', res.rows[0].now);
  }
});

// Routes API
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'API DonM fonctionne',
    timestamp: new Date().toISOString()
  });
});

// Endpoint Prometheus pour les métriques
app.get('/metrics', (req, res) => {
  res.set('Content-Type', monitoringService.getRegistry().contentType);
  res.end(monitoringService.getMetrics());
});

// Endpoint health check détaillé avec monitoring
app.get('/health/detailed', async (req, res) => {
  try {
    const healthStatus = await monitoringService.getHealthStatus();
    res.json(healthStatus);
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});

// Initialiser les services
const analyticsService = new AnalyticsService();
const cacheService = new CacheService();
const monitoringService = new MonitoringService();

// Rendre les services disponibles globalement
app.set('analyticsService', analyticsService);
app.set('cacheService', cacheService);
app.set('monitoringService', monitoringService);

// Appliquer le middleware de monitoring
app.use(monitoringService.middleware());

// Connexion à Redis
cacheService.connect().then(connected => {
  if (connected) {
    console.log('Cache Redis connecté et prêt');
    // Préchauffer le cache
    cacheService.warmupCache();
  } else {
    console.log('Cache Redis non disponible - fonctionnement sans cache');
  }
}).catch(err => {
  console.error('Erreur de connexion au cache:', err);
});

// Routes d'authentification (publiques)
app.use('/api/auth', authRoutes);

// Routes de paiements (protégées)
app.use('/api/payments', authenticateToken, paymentRoutes);

// Routes de notifications (protégées)
app.use('/api/notifications', authenticateToken, notificationRoutes);

// Routes d'analytiques (protégées)
app.use('/api/analytics', analyticsRoutes);

// Routes Utilisateurs (protégées)
app.get('/api/users', authenticateToken, async (req, res) => {
  try {
    const { role } = req.query;
    let query = 'SELECT id, username, email, phone, first_name, last_name, full_name, role, status, rating, kyc_level, shop_name, current_location, is_available, delivery_level, vehicle_type FROM users WHERE deleted_at IS NULL';
    const params = [];
    
    if (role) {
      query += ' AND role = $1';
      params.push(role);
    }
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur GET /api/users:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.post('/api/users', authenticateToken, async (req, res) => {
  try {
    const { username, email, phone, password_hash, first_name, last_name, role, shop_name, shop_address } = req.body;
    
    const query = `
      INSERT INTO users (username, email, phone, password_hash, first_name, last_name, role, shop_name, shop_address, full_name)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING id, username, email, first_name, last_name, full_name, role, created_at
    `;
    
    const values = [username, email, phone, password_hash, first_name, last_name, role, shop_name, shop_address, `${first_name} ${last_name}`];
    
    const result = await pool.query(query, values);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erreur POST /api/users:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Routes Produits
app.get('/api/products', optionalAuth, async (req, res) => {
  try {
    const { vendor_id, category, available } = req.query;
    let query = `
      SELECT p.*, u.full_name as vendor_name, u.shop_name 
      FROM products p 
      LEFT JOIN users u ON p.vendor_id = u.id 
      WHERE p.deleted_at IS NULL
    `;
    const params = [];
    let paramIndex = 1;
    
    if (vendor_id) {
      query += ` AND p.vendor_id = $${paramIndex++}`;
      params.push(vendor_id);
    }
    
    if (category) {
      query += ` AND p.category = $${paramIndex++}`;
      params.push(category);
    }
    
    if (available !== undefined) {
      query += ` AND p.is_available = $${paramIndex++}`;
      params.push(available === 'true');
    }
    
    query += ' ORDER BY p.created_at DESC';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur GET /api/products:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.post('/api/products', authenticateToken, requireRole(['vendor']), async (req, res) => {
  try {
    const { vendor_id, name, description, short_description, price, category, images, is_available } = req.body;
    
    // Générer le slug
    const slug = name.toLowerCase().replace(/[^a-z0-9]/g, '-');
    
    const query = `
      INSERT INTO products (vendor_id, name, slug, description, short_description, price, category, images, is_available)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `;
    
    const values = [vendor_id, name, slug, description, short_description, price, category, JSON.stringify(images || []), is_available !== false];
    
    const result = await pool.query(query, values);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erreur POST /api/products:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.put('/api/products/:id', authenticateToken, requireRole(['vendor']), async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, short_description, price, category, images, is_available } = req.body;
    
    // Générer le slug si le nom change
    const slug = name.toLowerCase().replace(/[^a-z0-9]/g, '-');
    
    const query = `
      UPDATE products 
      SET name = $1, slug = $2, description = $3, short_description = $4, price = $5, category = $6, images = $7, is_available = $8, updated_at = CURRENT_TIMESTAMP
      WHERE id = $9 AND deleted_at IS NULL
      RETURNING *
    `;
    
    const values = [name, slug, description, short_description, price, category, JSON.stringify(images || []), is_available !== false, id];
    
    const result = await pool.query(query, values);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produit non trouvé' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur PUT /api/products/:id:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.delete('/api/products/:id', authenticateToken, requireRole(['vendor']), async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = `
      UPDATE products 
      SET deleted_at = CURRENT_TIMESTAMP 
      WHERE id = $1 AND deleted_at IS NULL
    `;
    
    const result = await pool.query(query, [id]);
    
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Produit non trouvé' });
    }
    
    res.json({ message: 'Produit supprimé avec succès' });
  } catch (error) {
    console.error('Erreur DELETE /api/products/:id:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Routes Commandes
app.get('/api/orders', authenticateToken, async (req, res) => {
  try {
    const { client_id, status, delivery_person_id } = req.query;
    let query = `
      SELECT o.*, 
             c.full_name as client_name, 
             c.phone as client_phone,
             d.full_name as delivery_person_name,
             d.phone as delivery_person_phone,
             v.shop_name as vendor_name
      FROM orders o
      LEFT JOIN users c ON o.client_id = c.id
      LEFT JOIN users d ON o.delivery_person_id = d.id
      LEFT JOIN users v ON o.vendor_id = v.id
      WHERE 1=1
    `;
    const params = [];
    let paramIndex = 1;
    
    if (client_id) {
      query += ` AND o.client_id = $${paramIndex++}`;
      params.push(client_id);
    }
    
    if (status) {
      query += ` AND o.status = $${paramIndex++}`;
      params.push(status);
    }
    
    if (delivery_person_id) {
      query += ` AND o.delivery_person_id = $${paramIndex++}`;
      params.push(delivery_person_id);
    }
    
    query += ' ORDER BY o.created_at DESC';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur GET /api/orders:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.post('/api/orders', authenticateToken, requireRole(['client']), async (req, res) => {
  try {
    const { client_id, pickup_address, delivery_address, distance, base_price, delivery_fee, total_amount, pickup_instructions, delivery_instructions } = req.body;
    
    // Générer order_number et tracking_code
    const order_number = 'ORD-' + Date.now();
    const tracking_code = 'TRK-' + Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    
    const query = `
      INSERT INTO orders (client_id, order_number, pickup_address, delivery_address, distance, base_price, delivery_fee, total_amount, tracking_code, pickup_instructions, delivery_instructions)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *
    `;
    
    const values = [client_id, order_number, pickup_address, delivery_address, distance, base_price, delivery_fee, total_amount, tracking_code, pickup_instructions, delivery_instructions];
    
    const result = await pool.query(query, values);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Erreur POST /api/orders:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

app.put('/api/orders/:id/status', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, delivery_person_id } = req.body;
    
    const query = `
      UPDATE orders 
      SET status = $1, delivery_person_id = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *
    `;
    
    const values = [status, delivery_person_id, id];
    
    const result = await pool.query(query, values);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Commande non trouvée' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur PUT /api/orders/:id/status:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Route pour les livreurs disponibles
app.get('/api/delivery-persons/available', optionalAuth, async (req, res) => {
  try {
    const query = `
      SELECT id, full_name, phone, rating, delivery_level, current_location, latitude, longitude, vehicle_type, max_delivery_distance
      FROM users 
      WHERE role = 'delivery' 
        AND status = 'active' 
        AND is_available = true 
        AND deleted_at IS NULL
      ORDER BY rating DESC
    `;
    
    const result = await pool.query(query);
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur GET /api/delivery-persons/available:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Socket.IO - Connexions des utilisateurs
io.on('connection', (socket) => {
  console.log(`Utilisateur connecté: ${socket.id}`);

  // Rejoindre une room spécifique à l'utilisateur
  socket.on('join_user_room', (userId) => {
    socket.join(`user_${userId}`);
    console.log(`Utilisateur ${userId} a rejoint sa room`);
  });

  // Quitter la room utilisateur
  socket.on('leave_user_room', (userId) => {
    socket.leave(`user_${userId}`);
    console.log(`Utilisateur ${userId} a quitté sa room`);
  });

  // Rejoindre une room de commande
  socket.on('join_order_room', (orderId) => {
    socket.join(`order_${orderId}`);
    console.log(`Utilisateur a rejoint la room commande ${orderId}`);
  });

  // Déconnexion
  socket.on('disconnect', () => {
    console.log(`Utilisateur déconnecté: ${socket.id}`);
  });
});

// Gestion des erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Erreur interne du serveur' });
});

// Démarrage du serveur
server.listen(PORT, () => {
  console.log(`Serveur DonM API démarré sur le port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Prometheus metrics: http://localhost:${PORT}/metrics`);
  console.log(`Health check: http://localhost:${PORT}/health/detailed`);
  
  // Démarrer le monitoring en temps réel
  monitoringService.startRealTimeMonitoring(30000); // Toutes les 30 secondes
  
  console.log('Monitoring système démarré');
});
