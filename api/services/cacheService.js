const redis = require('redis');
const crypto = require('crypto');

class CacheService {
  constructor() {
    this.client = null;
    this.isConnected = false;
    this.defaultTTL = 3600; // 1 heure par défaut
    this.keyPrefix = 'donm:';
    this.stats = {
      hits: 0,
      misses: 0,
      sets: 0,
      deletes: 0,
      errors: 0
    };
  }

  // Connexion à Redis
  async connect() {
    try {
      this.client = redis.createClient({
        host: process.env.REDIS_HOST || 'localhost',
        port: process.env.REDIS_PORT || 6379,
        password: process.env.REDIS_PASSWORD,
        db: process.env.REDIS_DB || 0,
        retryDelayOnFailover: 100,
        maxRetriesPerRequest: 3,
        lazyConnect: true
      });

      this.client.on('connect', () => {
        console.log('Redis connecté');
        this.isConnected = true;
      });

      this.client.on('error', (err) => {
        console.error('Redis error:', err);
        this.isConnected = false;
        this.stats.errors++;
      });

      this.client.on('end', () => {
        console.log('Redis déconnecté');
        this.isConnected = false;
      });

      await this.client.connect();
      return true;
    } catch (error) {
      console.error('Erreur connexion Redis:', error);
      this.isConnected = false;
      return false;
    }
  }

  // Déconnexion
  async disconnect() {
    if (this.client) {
      await this.client.quit();
      this.client = null;
      this.isConnected = false;
    }
  }

  // Vérifier si Redis est connecté
  isRedisConnected() {
    return this.isConnected && this.client;
  }

  // Générer une clé de cache
  generateKey(key, namespace = '') {
    const fullKey = namespace ? `${this.keyPrefix}${namespace}:${key}` : `${this.keyPrefix}${key}`;
    return fullKey.replace(/[^a-zA-Z0-9:_-]/g, '_');
  }

  // Mettre en cache une valeur
  async set(key, value, ttl = this.defaultTTL, namespace = '') {
    try {
      if (!this.isRedisConnected()) {
        return false;
      }

      const cacheKey = this.generateKey(key, namespace);
      const serializedValue = JSON.stringify({
        data: value,
        timestamp: Date.now(),
        ttl: ttl
      });

      await this.client.setEx(cacheKey, ttl, serializedValue);
      this.stats.sets++;
      return true;
    } catch (error) {
      console.error('Erreur cache set:', error);
      this.stats.errors++;
      return false;
    }
  }

  // Récupérer une valeur du cache
  async get(key, namespace = '') {
    try {
      if (!this.isRedisConnected()) {
        this.stats.misses++;
        return null;
      }

      const cacheKey = this.generateKey(key, namespace);
      const cachedValue = await this.client.get(cacheKey);

      if (cachedValue) {
        const parsed = JSON.parse(cachedValue);
        
        // Vérifier si le cache est expiré manuellement
        if (this.isExpired(parsed)) {
          await this.delete(key, namespace);
          this.stats.misses++;
          return null;
        }

        this.stats.hits++;
        return parsed.data;
      }

      this.stats.misses++;
      return null;
    } catch (error) {
      console.error('Erreur cache get:', error);
      this.stats.errors++;
      this.stats.misses++;
      return null;
    }
  }

  // Supprimer une clé du cache
  async delete(key, namespace = '') {
    try {
      if (!this.isRedisConnected()) {
        return false;
      }

      const cacheKey = this.generateKey(key, namespace);
      const result = await this.client.del(cacheKey);
      
      if (result > 0) {
        this.stats.deletes++;
        return true;
      }
      return false;
    } catch (error) {
      console.error('Erreur cache delete:', error);
      this.stats.errors++;
      return false;
    }
  }

  // Vérifier si une clé existe
  async exists(key, namespace = '') {
    try {
      if (!this.isRedisConnected()) {
        return false;
      }

      const cacheKey = this.generateKey(key, namespace);
      const result = await this.client.exists(cacheKey);
      return result === 1;
    } catch (error) {
      console.error('Erreur cache exists:', error);
      this.stats.errors++;
      return false;
    }
  }

  // Vider le cache
  async clear(namespace = '') {
    try {
      if (!this.isRedisConnected()) {
        return false;
      }

      const pattern = namespace ? 
        `${this.keyPrefix}${namespace}:*` : 
        `${this.keyPrefix}*`;
      
      const keys = await this.client.keys(pattern);
      
      if (keys.length > 0) {
        await this.client.del(keys);
        this.stats.deletes += keys.length;
        return true;
      }
      return true;
    } catch (error) {
      console.error('Erreur cache clear:', error);
      this.stats.errors++;
      return false;
    }
  }

  // Mettre en cache avec expiration automatique
  async setWithAutoExpiry(key, value, ttl = this.defaultTTL, namespace = '') {
    return this.set(key, value, ttl, namespace);
  }

  // Récupérer avec callback si absent (cache-aside pattern)
  async getOrSet(key, callback, ttl = this.defaultTTL, namespace = '') {
    try {
      // Essayer de récupérer du cache
      const cached = await this.get(key, namespace);
      if (cached !== null) {
        return cached;
      }

      // Si absent, exécuter le callback
      const value = await callback();
      
      // Mettre en cache le résultat
      if (value !== null && value !== undefined) {
        await this.set(key, value, ttl, namespace);
      }

      return value;
    } catch (error) {
      console.error('Erreur getOrSet:', error);
      this.stats.errors++;
      return callback();
    }
  }

  // Cache pour les requêtes API
  async cacheApiResponse(key, apiCallback, ttl = 300) { // 5 minutes par défaut
    return this.getOrSet(key, apiCallback, ttl, 'api');
  }

  // Cache pour les données utilisateur
  async cacheUserData(userId, userData, ttl = 1800) { // 30 minutes par défaut
    return this.set(userId, userData, ttl, 'user');
  }

  // Récupérer les données utilisateur avec cache
  async getUserData(userId, callback) {
    return this.getOrSet(userId, callback, 1800, 'user');
  }

  // Cache pour les produits
  async cacheProducts(products, ttl = 600) { // 10 minutes par défaut
    return this.set('all_products', products, ttl, 'products');
  }

  // Récupérer les produits avec cache
  async getProducts(callback) {
    return this.getOrSet('all_products', callback, 600, 'products');
  }

  // Cache pour les commandes
  async cacheUserOrders(userId, orders, ttl = 300) { // 5 minutes par défaut
    return this.set(userId, orders, ttl, 'orders');
  }

  // Récupérer les commandes utilisateur avec cache
  async getUserOrders(userId, callback) {
    return this.getOrSet(userId, callback, 300, 'orders');
  }

  // Cache pour les sessions
  async cacheSession(sessionId, sessionData, ttl = 7200) { // 2 heures par défaut
    return this.set(sessionId, sessionData, ttl, 'session');
  }

  // Récupérer les données de session avec cache
  async getSession(sessionId, callback) {
    return this.getOrSet(sessionId, callback, 7200, 'session');
  }

  // Cache pour les analytics
  async cacheAnalytics(data, ttl = 900) { // 15 minutes par défaut
    return this.set('dashboard', data, ttl, 'analytics');
  }

  // Récupérer les analytics avec cache
  async getAnalytics(callback) {
    return this.getOrSet('dashboard', callback, 900, 'analytics');
  }

  // Invalider le cache utilisateur
  async invalidateUserCache(userId) {
    const patterns = [
      `user:${userId}`,
      `orders:${userId}`,
      `session:${userId}`
    ];

    const promises = patterns.map(pattern => this.clear(pattern.split(':')[0]));
    await Promise.all(promises);
  }

  // Invalider le cache des produits
  async invalidateProductsCache() {
    return this.clear('products');
  }

  // Invalider le cache analytics
  async invalidateAnalyticsCache() {
    return this.clear('analytics');
  }

  // Préchauffer les données communes
  async warmupCache() {
    try {
      const commonData = [
        { key: 'all_products', ttl: 600, namespace: 'products' },
        { key: 'dashboard', ttl: 900, namespace: 'analytics' },
        { key: 'popular_categories', ttl: 1800, namespace: 'products' }
      ];

      // Ces données seraient préchargées depuis la base de données
      // Pour l'instant, nous mettons juste des placeholders
      for (const item of commonData) {
        await this.set(item.key, { warmed_up: true, timestamp: Date.now() }, item.ttl, item.namespace);
      }

      console.log('Cache préchauffé avec succès');
      return true;
    } catch (error) {
      console.error('Erreur préchauffage cache:', error);
      return false;
    }
  }

  // Obtenir les statistiques du cache
  getStats() {
    const total = this.stats.hits + this.stats.misses;
    const hitRate = total > 0 ? (this.stats.hits / total) * 100 : 0;
    
    return {
      ...this.stats,
      hit_rate: hitRate.toFixed(2) + '%',
      total_requests: total,
      is_connected: this.isConnected
    };
  }

  // Réinitialiser les statistiques
  resetStats() {
    this.stats = {
      hits: 0,
      misses: 0,
      sets: 0,
      deletes: 0,
      errors: 0
    };
  }

  // Vérifier si une valeur cachée est expirée
  isExpired(cachedValue) {
    if (!cachedValue.timestamp || !cachedValue.ttl) {
      return false;
    }
    
    const now = Date.now();
    const age = now - cachedValue.timestamp;
    const maxAge = cachedValue.ttl * 1000; // Convertir TTL en millisecondes
    
    return age > maxAge;
  }

  // Nettoyer les clés expirées
  async cleanupExpired() {
    try {
      if (!this.isRedisConnected()) {
        return false;
      }

      const pattern = `${this.keyPrefix}*`;
      const keys = await this.client.keys(pattern);
      let cleaned = 0;

      for (const key of keys) {
        const value = await this.client.get(key);
        if (value) {
          const parsed = JSON.parse(value);
          if (this.isExpired(parsed)) {
            await this.client.del(key);
            cleaned++;
          }
        }
      }

      console.log(`Nettoyage terminé: ${cleaned} clés expirées supprimées`);
      return cleaned;
    } catch (error) {
      console.error('Erreur nettoyage cache expiré:', error);
      this.stats.errors++;
      return 0;
    }
  }

  // Compression des données pour le cache
  async compressAndSet(key, value, ttl = this.defaultTTL, namespace = '') {
    try {
      // Pour les grandes données, on pourrait utiliser la compression
      // Pour l'instant, nous utilisons JSON.stringify normal
      const compressed = JSON.stringify(value);
      return this.set(key, compressed, ttl, namespace);
    } catch (error) {
      console.error('Erreur compression cache:', error);
      return false;
    }
  }

  // Décompression des données du cache
  async getAndDecompress(key, namespace = '') {
    try {
      const compressed = await this.get(key, namespace);
      if (compressed) {
        return JSON.parse(compressed);
      }
      return null;
    } catch (error) {
      console.error('Erreur décompression cache:', error);
      return null;
    }
  }

  // Cache distribué (pour plusieurs instances)
  async distributedSet(key, value, ttl = this.defaultTTL, namespace = '') {
    try {
      const success = await this.set(key, value, ttl, namespace);
      
      // Notifier les autres instances via Redis pub/sub
      if (success && this.client) {
        await this.client.publish('cache_updates', JSON.stringify({
          action: 'set',
          key: key,
          namespace: namespace,
          timestamp: Date.now()
        }));
      }
      
      return success;
    } catch (error) {
      console.error('Erreur cache distribué set:', error);
      return false;
    }
  }

  // Cache distribué - suppression
  async distributedDelete(key, namespace = '') {
    try {
      const success = await this.delete(key, namespace);
      
      // Notifier les autres instances
      if (success && this.client) {
        await this.client.publish('cache_updates', JSON.stringify({
          action: 'delete',
          key: key,
          namespace: namespace,
          timestamp: Date.now()
        }));
      }
      
      return success;
    } catch (error) {
      console.error('Erreur cache distribué delete:', error);
      return false;
    }
  }

  // Pipeline pour les opérations multiples
  async pipeline(operations) {
    try {
      if (!this.isRedisConnected()) {
        return false;
      }

      const pipeline = this.client.multi();
      
      operations.forEach(op => {
        switch (op.type) {
          case 'set':
            pipeline.setEx(op.key, op.ttl || this.defaultTTL, JSON.stringify(op.value));
            break;
          case 'get':
            pipeline.get(op.key);
            break;
          case 'delete':
            pipeline.del(op.key);
            break;
          case 'exists':
            pipeline.exists(op.key);
            break;
        }
      });

      const results = await pipeline.exec();
      return results;
    } catch (error) {
      console.error('Erreur pipeline cache:', error);
      this.stats.errors++;
      return false;
    }
  }

  // Cache hiérarchique (L1: mémoire, L2: Redis)
  async hierarchicalSet(key, value, ttl = this.defaultTTL, namespace = '') {
    // L1: Cache en mémoire (Node.js)
    const memoryCache = this.getMemoryCache();
    memoryCache.set(this.generateKey(key, namespace), {
      data: value,
      timestamp: Date.now(),
      ttl: ttl
    });

    // L2: Cache Redis
    return this.set(key, value, ttl, namespace);
  }

  // Cache hiérarchique - récupération
  async hierarchicalGet(key, namespace = '') {
    const cacheKey = this.generateKey(key, namespace);
    
    // L1: Cache en mémoire
    const memoryCache = this.getMemoryCache();
    const memoryData = memoryCache.get(cacheKey);
    
    if (memoryData && !this.isExpired(memoryData)) {
      this.stats.hits++;
      return memoryData.data;
    }

    // L2: Cache Redis
    const redisData = await this.get(key, namespace);
    if (redisData) {
      // Remplir le cache L1
      memoryCache.set(cacheKey, {
        data: redisData,
        timestamp: Date.now(),
        ttl: this.defaultTTL
      });
    }

    return redisData;
  }

  // Cache en mémoire simple
  getMemoryCache() {
    if (!this.memoryCache) {
      this.memoryCache = new Map();
      
      // Nettoyage périodique du cache mémoire
      setInterval(() => {
        this.cleanupMemoryCache();
      }, 60000); // Chaque minute
    }
    return this.memoryCache;
  }

  // Nettoyer le cache mémoire
  cleanupMemoryCache() {
    const memoryCache = this.getMemoryCache();
    const now = Date.now();
    let cleaned = 0;

    for (const [key, value] of memoryCache.entries()) {
      if (this.isExpired(value)) {
        memoryCache.delete(key);
        cleaned++;
      }
    }

    if (cleaned > 0) {
      console.log(`Cache mémoire nettoyé: ${cleaned} clés supprimées`);
    }
  }

  // Health check du cache
  async healthCheck() {
    try {
      const testKey = 'health_check';
      const testValue = { test: true, timestamp: Date.now() };
      
      // Test set
      const setResult = await this.set(testKey, testValue, 10, 'health');
      if (!setResult) {
        return { status: 'unhealthy', message: 'Set operation failed' };
      }

      // Test get
      const getResult = await this.get(testKey, 'health');
      if (!getResult || getResult.test !== true) {
        return { status: 'unhealthy', message: 'Get operation failed' };
      }

      // Test delete
      const deleteResult = await this.delete(testKey, 'health');
      if (!deleteResult) {
        return { status: 'unhealthy', message: 'Delete operation failed' };
      }

      return {
        status: 'healthy',
        message: 'All cache operations successful',
        stats: this.getStats()
      };
    } catch (error) {
      console.error('Health check error:', error);
      return { status: 'unhealthy', message: error.message };
    }
  }
}

module.exports = CacheService;
