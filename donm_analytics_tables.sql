-- Tables pour le système d'analytics DonM

-- Table pour les événements utilisateur
CREATE TABLE IF NOT EXISTS analytics_events (
    id VARCHAR(255) PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    user_id VARCHAR(255) REFERENCES users(id),
    data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les analytics de commandes
CREATE TABLE IF NOT EXISTS order_analytics (
    id VARCHAR(255) PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    order_id VARCHAR(255) REFERENCES orders(id),
    data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_id VARCHAR(255) REFERENCES users(id),
    amount DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les analytics de paiements
CREATE TABLE IF NOT EXISTS payment_analytics (
    id VARCHAR(255) PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    payment_id VARCHAR(255) REFERENCES payments(id),
    data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2),
    method VARCHAR(50),
    status VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les logs de performance
CREATE TABLE IF NOT EXISTS performance_logs (
    id SERIAL PRIMARY KEY,
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    response_time INTEGER NOT NULL, -- en millisecondes
    status_code INTEGER NOT NULL,
    user_id VARCHAR(255) REFERENCES users(id),
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les sessions utilisateur
CREATE TABLE IF NOT EXISTS user_sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id),
    session_data JSONB,
    start_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- en secondes
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les funnels de conversion
CREATE TABLE IF NOT EXISTS conversion_funnels (
    id SERIAL PRIMARY KEY,
    funnel_name VARCHAR(100) NOT NULL,
    step_name VARCHAR(100) NOT NULL,
    step_order INTEGER NOT NULL,
    user_count INTEGER NOT NULL,
    conversion_rate DECIMAL(5, 2),
    date_bucket DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les métriques quotidiennes
CREATE TABLE IF NOT EXISTS daily_metrics (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15, 2) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(date, metric_name)
);

-- Table pour les événements de produits
CREATE TABLE IF NOT EXISTS product_events (
    id VARCHAR(255) PRIMARY KEY,
    product_id VARCHAR(255) REFERENCES products(id),
    event_type VARCHAR(100) NOT NULL,
    user_id VARCHAR(255) REFERENCES users(id),
    data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_analytics_events_timestamp ON analytics_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_session_id ON analytics_events(session_id);

CREATE INDEX IF NOT EXISTS idx_order_analytics_timestamp ON order_analytics(timestamp);
CREATE INDEX IF NOT EXISTS idx_order_analytics_order_id ON order_analytics(order_id);
CREATE INDEX IF NOT EXISTS idx_order_analytics_event_type ON order_analytics(event_type);

CREATE INDEX IF NOT EXISTS idx_payment_analytics_timestamp ON payment_analytics(timestamp);
CREATE INDEX IF NOT EXISTS idx_payment_analytics_payment_id ON payment_analytics(payment_id);
CREATE INDEX IF NOT EXISTS idx_payment_analytics_method ON payment_analytics(method);
CREATE INDEX IF NOT EXISTS idx_payment_analytics_status ON payment_analytics(status);

CREATE INDEX IF NOT EXISTS idx_performance_logs_timestamp ON performance_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_performance_logs_endpoint ON performance_logs(endpoint);
CREATE INDEX IF NOT EXISTS idx_performance_logs_response_time ON performance_logs(response_time);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_start_time ON user_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_user_sessions_is_active ON user_sessions(is_active);

CREATE INDEX IF NOT EXISTS idx_conversion_funnels_date_bucket ON conversion_funnels(date_bucket);
CREATE INDEX IF NOT EXISTS idx_conversion_funnels_funnel_name ON conversion_funnels(funnel_name);

CREATE INDEX IF NOT EXISTS idx_daily_metrics_date ON daily_metrics(date);
CREATE INDEX IF NOT EXISTS idx_daily_metrics_metric_name ON daily_metrics(metric_name);

CREATE INDEX IF NOT EXISTS idx_product_events_timestamp ON product_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_product_events_product_id ON product_events(product_id);
CREATE INDEX IF NOT EXISTS idx_product_events_event_type ON product_events(event_type);

-- Vues pour les analytics fréquemment utilisés
CREATE OR REPLACE VIEW analytics_summary AS
SELECT 
    DATE(timestamp) as date,
    COUNT(DISTINCT user_id) as active_users,
    COUNT(*) as total_events,
    COUNT(DISTINCT session_id) as active_sessions
FROM analytics_events 
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(timestamp)
ORDER BY date DESC;

CREATE OR REPLACE VIEW order_analytics_summary AS
SELECT 
    DATE(timestamp) as date,
    event_type,
    COUNT(*) as count,
    AVG(amount) as avg_amount,
    SUM(amount) as total_amount
FROM order_analytics 
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(timestamp), event_type
ORDER BY date DESC, event_type;

CREATE OR REPLACE VIEW payment_analytics_summary AS
SELECT 
    DATE(timestamp) as date,
    method,
    status,
    COUNT(*) as count,
    AVG(amount) as avg_amount,
    SUM(amount) as total_amount
FROM payment_analytics 
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(timestamp), method, status
ORDER BY date DESC, method, status;

CREATE OR REPLACE VIEW performance_summary AS
SELECT 
    DATE(timestamp) as date,
    endpoint,
    AVG(response_time) as avg_response_time,
    MIN(response_time) as min_response_time,
    MAX(response_time) as max_response_time,
    COUNT(*) as request_count,
    SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) as error_count,
    (SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as error_rate
FROM performance_logs 
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(timestamp), endpoint
ORDER BY date DESC, avg_response_time DESC;

-- Fonctions pour les calculs analytics
CREATE OR REPLACE FUNCTION calculate_conversion_rate(p_step_users INTEGER, p_previous_step_users INTEGER)
RETURNS DECIMAL(5, 2) AS $$
BEGIN
    IF p_previous_step_users = 0 THEN
        RETURN 0;
    END IF;
    RETURN (p_step_users::DECIMAL / p_previous_step_users::DECIMAL) * 100;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_daily_metrics(p_date DATE, p_metric_name VARCHAR(100), p_value DECIMAL(15, 2), p_metadata JSONB DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO daily_metrics (date, metric_name, metric_value, metadata)
    VALUES (p_date, p_metric_name, p_value, p_metadata)
    ON CONFLICT (date, metric_name)
    DO UPDATE SET 
        metric_value = EXCLUDED.metric_value,
        metadata = EXCLUDED.metadata,
        created_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour les mises à jour automatiques
CREATE OR REPLACE FUNCTION update_user_session_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Mettre à jour la session existante
        UPDATE user_sessions 
        SET end_time = NEW.timestamp,
            duration = EXTRACT(EPOCH FROM (NEW.timestamp - start_time))::INTEGER,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = NEW.user_id AND is_active = TRUE;
        
        -- Si aucune session active, en créer une nouvelle
        IF NOT FOUND THEN
            INSERT INTO user_sessions (id, user_id, session_data, ip_address, user_agent)
            VALUES (
                gen_random_uuid()::TEXT,
                NEW.user_id,
                jsonb_build_object('last_event', NEW.event_type),
                NEW.ip_address,
                NEW.user_agent
            );
        END IF;
        
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_session
    AFTER INSERT ON analytics_events
    FOR EACH ROW
    EXECUTE FUNCTION update_user_session_activity();

-- Procédures pour le nettoyage des données
CREATE OR REPLACE PROCEDURE cleanup_old_analytics(days_to_keep INTEGER DEFAULT 90)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM analytics_events WHERE timestamp < CURRENT_DATE - INTERVAL '1 day' * days_to_keep;
    DELETE FROM order_analytics WHERE timestamp < CURRENT_DATE - INTERVAL '1 day' * days_to_keep;
    DELETE FROM payment_analytics WHERE timestamp < CURRENT_DATE - INTERVAL '1 day' * days_to_keep;
    DELETE FROM performance_logs WHERE timestamp < CURRENT_DATE - INTERVAL '1 day' * days_to_keep;
    DELETE FROM user_sessions WHERE end_time < CURRENT_DATE - INTERVAL '1 day' * days_to_keep;
    DELETE FROM product_events WHERE timestamp < CURRENT_DATE - INTERVAL '1 day' * days_to_keep;
    
    RAISE NOTICE 'Nettoyage des données analytics de plus de % jours terminé', days_to_keep;
END;
$$;

-- Procédure pour calculer les métriques quotidiennes
CREATE OR REPLACE PROCEDURE calculate_daily_metrics(target_date DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql AS $$
BEGIN
    -- Métriques utilisateurs
    INSERT INTO daily_metrics (date, metric_name, metric_value)
    SELECT 
        target_date,
        'active_users',
        COUNT(DISTINCT user_id)::DECIMAL
    FROM analytics_events 
    WHERE DATE(timestamp) = target_date
    ON CONFLICT (date, metric_name) DO NOTHING;
    
    -- Métriques commandes
    INSERT INTO daily_metrics (date, metric_name, metric_value)
    SELECT 
        target_date,
        'total_orders',
        COUNT(*)::DECIMAL
    FROM orders 
    WHERE DATE(created_at) = target_date
    ON CONFLICT (date, metric_name) DO NOTHING;
    
    -- Métriques paiements
    INSERT INTO daily_metrics (date, metric_name, metric_value)
    SELECT 
        target_date,
        'total_revenue',
        COALESCE(SUM(amount), 0)::DECIMAL
    FROM payments 
    WHERE DATE(paid_at) = target_date
    ON CONFLICT (date, metric_name) DO NOTHING;
    
    -- Métriques performance
    INSERT INTO daily_metrics (date, metric_name, metric_value)
    SELECT 
        target_date,
        'avg_response_time',
        AVG(response_time)::DECIMAL
    FROM performance_logs 
    WHERE DATE(timestamp) = target_date
    ON CONFLICT (date, metric_name) DO NOTHING;
    
    RAISE NOTICE 'Métriques quotidiennes calculées pour %', target_date;
END;
$$;

-- Données initiales pour les funnels de conversion
INSERT INTO conversion_funnels (funnel_name, step_name, step_order, user_count, date_bucket)
VALUES 
    ('registration', 'visit_landing_page', 1, 1000, CURRENT_DATE),
    ('registration', 'start_registration', 2, 800, CURRENT_DATE),
    ('registration', 'complete_registration', 3, 600, CURRENT_DATE),
    ('registration', 'verify_email', 4, 550, CURRENT_DATE),
    ('registration', 'first_login', 5, 500, CURRENT_DATE),
    ('order', 'view_products', 1, 400, CURRENT_DATE),
    ('order', 'add_to_cart', 2, 200, CURRENT_DATE),
    ('order', 'start_checkout', 3, 150, CURRENT_DATE),
    ('order', 'complete_payment', 4, 120, CURRENT_DATE),
    ('order', 'order_confirmed', 5, 115, CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- Créer des métriques quotidiennes pour les 30 derniers jours
DO $$
DECLARE 
    current_date DATE := CURRENT_DATE - INTERVAL '29 days';
BEGIN
    WHILE current_date <= CURRENT_DATE LOOP
        CALL calculate_daily_metrics(current_date);
        current_date := current_date + INTERVAL '1 day';
    END LOOP;
END $$;
