-- Script d'optimisation des requêtes PostgreSQL pour DonM

-- 1. Index optimisés pour les performances
-- Index composites pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_orders_client_status_created 
ON orders(client_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_orders_status_created 
ON orders(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_orders_delivery_person_status 
ON orders(delivery_person_id, status);

CREATE INDEX IF NOT EXISTS idx_orders_tracking_code 
ON orders(tracking_code);

CREATE INDEX IF NOT EXISTS idx_orders_pickup_delivery_gin 
ON orders USING GIN(to_tsvector('french', pickup_address || ' ' || delivery_address));

-- Index pour les paiements
CREATE INDEX IF NOT EXISTS idx_payments_order_status 
ON payments(order_id, status);

CREATE INDEX IF NOT EXISTS idx_payments_user_paid_at 
ON payments(user_id, paid_at DESC);

CREATE INDEX IF NOT EXISTS idx_payments_method_status 
ON payments(method, status);

CREATE INDEX IF NOT EXISTS idx_payments_created_at 
ON payments(created_at DESC);

-- Index pour les produits
CREATE INDEX IF NOT EXISTS idx_products_vendor_available 
ON products(vendor_id, is_available);

CREATE INDEX IF NOT EXISTS idx_products_category_available 
ON products(category, is_available);

CREATE INDEX IF NOT EXISTS idx_products_name_gin 
ON products USING GIN(to_tsvector('french', name || ' ' || COALESCE(description, '')));

CREATE INDEX IF NOT EXISTS idx_products_price_range 
ON products(price) WHERE is_available = true;

-- Index pour les utilisateurs
CREATE INDEX IF NOT EXISTS idx_users_role_status 
ON users(role, status);

CREATE INDEX IF NOT EXISTS idx_users_location_available 
ON users(current_location) WHERE role = 'delivery' AND is_available = true;

CREATE INDEX IF NOT EXISTS idx_users_email_role 
ON users(email, role);

CREATE INDEX IF NOT EXISTS idx_users_phone_role 
ON users(phone, role);

-- Index pour les notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_read 
ON notifications(user_id, is_read);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at 
ON notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_type_created 
ON notifications(type, created_at DESC);

-- Index pour les order_items
CREATE INDEX IF NOT EXISTS idx_order_items_order_product 
ON order_items(order_id, product_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_order 
ON order_items(product_id, order_id);

CREATE INDEX IF NOT EXISTS idx_order_items_quantity_price 
ON order_items(quantity, price);

-- 2. Vues optimisées pour les requêtes communes
CREATE OR REPLACE VIEW v_active_orders AS
SELECT 
    o.id,
    o.client_id,
    o.tracking_code,
    o.status,
    o.pickup_address,
    o.delivery_address,
    o.total_amount,
    o.created_at,
    u_client.full_name as client_name,
    u_client.phone as client_phone,
    u_delivery.full_name as delivery_person_name,
    u_delivery.phone as delivery_phone,
    p.method as payment_method,
    p.status as payment_status
FROM orders o
LEFT JOIN users u_client ON o.client_id = u_client.id
LEFT JOIN users u_delivery ON o.delivery_person_id = u_delivery.id
LEFT JOIN payments p ON o.id = p.order_id
WHERE o.status IN ('pending', 'confirmed', 'in_transit');

CREATE OR REPLACE VIEW v_order_summary AS
SELECT 
    o.id,
    o.tracking_code,
    o.status,
    o.total_amount,
    o.created_at,
    u_client.full_name as client_name,
    u_client.phone as client_phone,
    COUNT(oi.id) as item_count,
    SUM(oi.quantity) as total_quantity,
    STRING_AGG(p.name, ', ') as product_names
FROM orders o
LEFT JOIN users u_client ON o.client_id = u_client.id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY o.id, o.tracking_code, o.status, o.total_amount, o.created_at, u_client.full_name, u_client.phone;

CREATE OR REPLACE VIEW v_vendor_performance AS
SELECT 
    u.id as vendor_id,
    u.full_name as vendor_name,
    u.shop_name,
    COUNT(DISTINCT o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    COUNT(DISTINCT p.id) as product_count,
    COUNT(DISTINCT o.client_id) as unique_customers,
    DATE_PART('day', NOW() - MIN(o.created_at)) as days_active
FROM users u
LEFT JOIN products p ON u.id = p.vendor_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
WHERE u.role = 'vendor' AND u.status = 'active'
GROUP BY u.id, u.full_name, u.shop_name;

CREATE OR REPLACE VIEW v_delivery_performance AS
SELECT 
    u.id as delivery_id,
    u.full_name as delivery_name,
    u.vehicle_type,
    u.delivery_level,
    COUNT(DISTINCT o.id) as total_deliveries,
    AVG(EXTRACT(EPOCH FROM (o.updated_at - o.created_at))/3600) as avg_delivery_hours,
    COUNT(DISTINCT CASE WHEN o.status = 'delivered' THEN o.id END) as successful_deliveries,
    (COUNT(DISTINCT CASE WHEN o.status = 'delivered' THEN o.id END) * 100.0 / COUNT(DISTINCT o.id)) as success_rate,
    COALESCE(SUM(o.total_amount) * 0.1, 0) as estimated_earnings
FROM users u
LEFT JOIN orders o ON u.id = o.delivery_person_id
WHERE u.role = 'delivery' AND u.status = 'active'
GROUP BY u.id, u.full_name, u.vehicle_type, u.delivery_level;

CREATE OR REPLACE VIEW v_popular_products AS
SELECT 
    p.id,
    p.name,
    p.category,
    p.price,
    p.vendor_id,
    u.shop_name as vendor_name,
    COUNT(oi.id) as order_count,
    SUM(oi.quantity) as total_sold,
    SUM(oi.quantity * oi.price) as total_revenue,
    AVG(oi.quantity * oi.price) as avg_order_value
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
LEFT JOIN users u ON p.vendor_id = u.id
WHERE p.is_available = true
GROUP BY p.id, p.name, p.category, p.price, p.vendor_id, u.shop_name
ORDER BY total_sold DESC;

-- 3. Fonctions optimisées
CREATE OR REPLACE FUNCTION get_user_orders_optimized(p_user_id VARCHAR(255), p_limit INTEGER DEFAULT 20, p_offset INTEGER DEFAULT 0)
RETURNS TABLE (
    id VARCHAR(255),
    tracking_code VARCHAR(255),
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE,
    item_count INTEGER,
    product_names TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id,
        o.tracking_code,
        o.status,
        o.total_amount,
        o.created_at,
        COUNT(oi.id) as item_count,
        STRING_AGG(p.name, ', ') as product_names
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.id
    WHERE o.client_id = p_user_id
    GROUP BY o.id, o.tracking_code, o.status, o.total_amount, o.created_at
    ORDER BY o.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_vendor_stats_optimized(p_vendor_id VARCHAR(255))
RETURNS TABLE (
    total_orders INTEGER,
    total_revenue DECIMAL(15,2),
    avg_order_value DECIMAL(10,2),
    product_count INTEGER,
    unique_customers INTEGER,
    recent_orders INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT o.id) as total_orders,
        COALESCE(SUM(o.total_amount), 0) as total_revenue,
        COALESCE(AVG(o.total_amount), 0) as avg_order_value,
        COUNT(DISTINCT p.id) as product_count,
        COUNT(DISTINCT o.client_id) as unique_customers,
        COUNT(DISTINCT CASE WHEN o.created_at >= NOW() - INTERVAL '7 days' THEN o.id END) as recent_orders
    FROM users u
    LEFT JOIN products p ON u.id = p.vendor_id
    LEFT JOIN order_items oi ON p.id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'delivered'
    WHERE u.id = p_vendor_id AND u.role = 'vendor'
    GROUP BY u.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_products_optimized(p_search_term TEXT, p_category VARCHAR(100) DEFAULT NULL, p_limit INTEGER DEFAULT 50)
RETURNS TABLE (
    id VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    price DECIMAL(10,2),
    category VARCHAR(100),
    vendor_id VARCHAR(255),
    vendor_name VARCHAR(255),
    shop_name VARCHAR(255),
    is_available BOOLEAN,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.description,
        p.price,
        p.category,
        p.vendor_id,
        u.full_name as vendor_name,
        u.shop_name,
        p.is_available,
        ts_rank(search_vector, plainto_tsquery('french', p_search_term)) as rank
    FROM (
        SELECT 
            p.*,
            to_tsvector('french', p.name || ' ' || COALESCE(p.description, '') || ' ' || COALESCE(p.category, '')) as search_vector
        FROM products p
        WHERE p.is_available = true
        AND (p_category IS NULL OR p.category = p_category)
    ) p
    LEFT JOIN users u ON p.vendor_id = u.id
    WHERE search_vector @@ plainto_tsquery('french', p_search_term)
    ORDER BY rank DESC, p.name
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 4. Procédures de maintenance optimisées
CREATE OR REPLACE PROCEDURE optimize_table_statistics()
LANGUAGE plpgsql AS $$
BEGIN
    -- Analyser les tables fréquemment utilisées
    ANALYZE orders;
    ANALYZE payments;
    ANALYZE products;
    ANALYZE users;
    ANALYZE order_items;
    ANALYZE notifications;
    
    -- Recréer les index si nécessaire
    REINDEX INDEX CONCURRENTLY idx_orders_client_status_created;
    REINDEX INDEX CONCURRENTLY idx_payments_order_status;
    REINDEX INDEX CONCURRENTLY idx_products_vendor_available;
    
    RAISE NOTICE 'Statistiques des tables optimisées';
END;
$$;

CREATE OR REPLACE PROCEDURE cleanup_old_data(p_days_to_keep INTEGER DEFAULT 90)
LANGUAGE plpgsql AS $$
BEGIN
    -- Nettoyer les anciennes notifications lues
    DELETE FROM notifications 
    WHERE is_read = true AND created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
    
    -- Nettoyer les anciennes sessions
    DELETE FROM user_sessions 
    WHERE end_time < NOW() - INTERVAL '1 day' * p_days_to_keep;
    
    -- Archiver les anciennes commandes complétées
    -- (Optionnel: déplacer vers une table d'archive)
    
    RAISE NOTICE 'Nettoyage des anciennes données terminé';
END;
$$;

-- 5. Triggers optimisés pour la performance
CREATE OR REPLACE FUNCTION update_product_search_index()
RETURNS TRIGGER AS $$
BEGIN
    -- Mettre à jour le vecteur de recherche lors de la modification
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        NEW.search_vector := to_tsvector('french', NEW.name || ' ' || COALESCE(NEW.description, '') || ' ' || COALESCE(NEW.category, ''));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Ajouter la colonne de recherche si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'search_vector') THEN
        ALTER TABLE products ADD COLUMN search_vector tsvector;
    END IF;
END $$;

-- Créer le trigger pour la mise à jour automatique
DROP TRIGGER IF EXISTS trigger_update_product_search ON products;
CREATE TRIGGER trigger_update_product_search
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_product_search_index();

-- Mettre à jour les vecteurs de recherche existants
UPDATE products SET search_vector = to_tsvector('french', name || ' ' || COALESCE(description, '') || ' ' || COALESCE(category, ''));

-- 6. Configuration PostgreSQL pour les performances
-- Note: Ces paramètres doivent être configurés dans postgresql.conf
/*
-- Paramètres recommandés pour postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 4MB
min_wal_size = 1GB
max_wal_size = 4GB
max_connections = 100
*/

-- 7. Requêtes optimisées exemples

-- Recherche de produits avec performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT p.*, u.shop_name, u.full_name as vendor_name
FROM products p
LEFT JOIN users u ON p.vendor_id = u.id
WHERE p.is_available = true 
AND p.category = 'Plats chauds'
ORDER BY p.price
LIMIT 20;

-- Commandes d'un utilisateur avec pagination optimisée
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.tracking_code, o.status, o.total_amount, o.created_at,
       COUNT(oi.id) as item_count,
       STRING_AGG(p.name, ', ') as product_names
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.client_id = 'user-123'
GROUP BY o.id, o.tracking_code, o.status, o.total_amount, o.created_at
ORDER BY o.created_at DESC
LIMIT 20 OFFSET 0;

-- Analytics des ventes optimisées
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    DATE(paid_at) as date,
    COUNT(*) as payment_count,
    SUM(amount) as daily_revenue,
    AVG(amount) as avg_payment
FROM payments 
WHERE paid_at >= NOW() - INTERVAL '30 days'
    AND status = 'paid'
GROUP BY DATE(paid_at)
ORDER BY date DESC;

-- 8. Monitoring des performances des requêtes
CREATE OR REPLACE VIEW v_slow_queries AS
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows,
    100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements 
WHERE mean_time > 100 -- requêtes prenant plus de 100ms en moyenne
ORDER BY mean_time DESC;

-- Activer pg_stat_statements si ce n'est pas déjà fait
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- 9. Partitionnement suggéré pour les grandes tables
-- Pour les tables qui pourraient devenir très volumineuses

-- Partitionnement des commandes par mois
/*
CREATE TABLE orders_partitioned (
    LIKE orders INCLUDING ALL
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_01 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE orders_2024_02 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
*/

-- 10. Materialized views pour les rapports fréquents
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_daily_sales_summary AS
SELECT 
    DATE(paid_at) as sale_date,
    COUNT(*) as total_payments,
    SUM(amount) as total_revenue,
    AVG(amount) as avg_payment_amount,
    COUNT(DISTINCT user_id) as unique_customers,
    COUNT(DISTINCT order_id) as unique_orders
FROM payments 
WHERE status = 'paid'
GROUP BY DATE(paid_at)
ORDER BY sale_date DESC;

-- Index pour la materialized view
CREATE INDEX IF NOT EXISTS idx_mv_daily_sales_summary_date 
ON mv_daily_sales_summary(sale_date);

-- Fonction pour rafraîchir la materialized view
CREATE OR REPLACE FUNCTION refresh_daily_sales_summary()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_summary;
END;
$$ LANGUAGE plpgsql;

-- Planifier le rafraîchissement (nécessite pg_cron)
/*
SELECT cron.schedule('refresh-sales-summary', '0 2 * * *', 'SELECT refresh_daily_sales_summary();');
*/

-- 11. Requêtes préparées pour les opérations fréquentes
PREPARE get_user_by_email(TEXT) AS
SELECT id, username, email, role, status, full_name 
FROM users 
WHERE email = $1 AND deleted_at IS NULL;

PREPARE get_orders_by_status(TEXT) AS
SELECT id, tracking_code, client_id, total_amount, created_at
FROM orders 
WHERE status = $1 
ORDER BY created_at DESC 
LIMIT 50;

PREPARE get_available_products(TEXT) AS
SELECT p.*, u.shop_name as vendor_name
FROM products p
LEFT JOIN users u ON p.vendor_id = u.id
WHERE p.is_available = true 
AND (p.category = $1 OR $1 IS NULL)
ORDER BY p.name;

-- 12. Optimisation des jointures
-- S'assurer que les types de données correspondent pour les jointures
-- Ajouter des contraintes CHECK pour la qualité des données
ALTER TABLE orders 
ADD CONSTRAINT check_total_amount_positive CHECK (total_amount > 0),
ADD CONSTRAINT check_status_valid CHECK (status IN ('pending', 'confirmed', 'in_transit', 'delivered', 'cancelled'));

ALTER TABLE payments 
ADD CONSTRAINT check_amount_positive CHECK (amount > 0),
ADD CONSTRAINT check_method_valid CHECK (method IN ('cash', 'mobile_money_orange', 'mobile_money_mtn', 'mobile_money_momo', 'card'));

-- 13. Nettoyage et maintenance automatisée
CREATE OR REPLACE PROCEDURE auto_maintenance()
LANGUAGE plpgsql AS $$
BEGIN
    -- Optimiser les statistiques
    CALL optimize_table_statistics();
    
    -- Nettoyer les anciennes données
    CALL cleanup_old_data(90);
    
    -- Rafraîchir les materialized views
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_summary;
    
    -- Réinitialiser les compteurs de performance
    SELECT pg_stat_reset();
    
    RAISE NOTICE 'Maintenance automatisée terminée';
END;
$$;

-- Exemple d'utilisation des fonctions optimisées
/*
-- Obtenir les commandes d'un utilisateur avec pagination
SELECT * FROM get_user_orders_optimized('user-123', 20, 0);

-- Obtenir les statistiques d'un vendeur
SELECT * FROM get_vendor_stats_optimized('vendor-456');

-- Rechercher des produits
SELECT * FROM search_products_optimized('attiéké', 'Plats chauds', 50);

-- Exécuter la maintenance
CALL auto_maintenance();
*/
