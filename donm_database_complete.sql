-- =====================================================
-- BASE DE DONNÉES DONM - POSTGRESQL COMPLÈTE
-- Version: 1.0
-- Auteur: Cascade AI
-- Date: 08/04/2026
-- =====================================================

-- Configuration initiale
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- =====================================================
-- EXTENSIONS POSTGRESQL
-- =====================================================

-- Extension pour les UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extension pour la recherche de texte (trigrammes)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Extension pour les fonctions cryptographiques
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- TYPES PERSONNALISÉS
-- =====================================================

-- Rôles utilisateurs
CREATE TYPE user_role AS ENUM ('client', 'vendor', 'delivery');

-- Statuts utilisateurs
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');

-- Niveaux KYC
CREATE TYPE kyc_level AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'CERTIFIED', 'REJECTED');

-- Niveaux de livraison
CREATE TYPE delivery_level AS ENUM ('beginner', 'intermediate', 'experienced', 'expert');

-- Statuts des commandes
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'in_transit', 'delivered', 'cancelled', 'refunded');

-- Méthodes de paiement
CREATE TYPE payment_method AS ENUM ('cash', 'mobile_money', 'card', 'wallet');

-- Statuts des paiements
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

-- Types de notifications
CREATE TYPE notification_type AS ENUM ('order_created', 'order_confirmed', 'order_ready', 'order_delivered', 'payment_received', 'delivery_assigned', 'system');

-- =====================================================
-- TABLES PRINCIPALES
-- =====================================================

-- Table des utilisateurs
CREATE TABLE users (
    -- Identifiants
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Informations personnelles
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    avatar_url VARCHAR(255),
    date_of_birth DATE,
    
    -- Rôle et statut
    role user_role NOT NULL CHECK (role IN ('client', 'vendor', 'delivery')),
    status user_status DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    kyc_level kyc_level DEFAULT 'NONE' CHECK (kyc_level IN ('NONE', 'PENDING', 'VERIFIED', 'CERTIFIED', 'REJECTED')),
    
    -- Évaluations
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_ratings INTEGER DEFAULT 0,
    total_deliveries INTEGER DEFAULT 0,
    
    -- Localisation
    current_location TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    address TEXT,
    
    -- Champs spécifiques vendeur
    shop_name VARCHAR(100),
    shop_address TEXT,
    shop_description TEXT,
    shop_logo_url VARCHAR(255),
    business_registration_number VARCHAR(50),
    
    -- Champs spécifiques livreur
    delivery_level delivery_level DEFAULT 'beginner' CHECK (delivery_level IN ('beginner', 'intermediate', 'experienced', 'expert')),
    vehicle_type VARCHAR(50), -- 'moto', 'voiture', 'vélo'
    vehicle_plate VARCHAR(20),
    is_available BOOLEAN DEFAULT TRUE,
    max_delivery_distance DECIMAL(8,2) DEFAULT 20.0, -- km
    
    -- Préférences
    language VARCHAR(10) DEFAULT 'fr',
    timezone VARCHAR(50) DEFAULT 'Africa/Abidjan',
    notification_enabled BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    member_since TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Table des produits
CREATE TABLE products (
    -- Identifiants
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Informations produit
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE GENERATED ALWAYS AS (lower(regexp_replace(name, '[^a-zA-Z0-9]', '-', 'g'))) STORED,
    description TEXT,
    short_description VARCHAR(255),
    
    -- Prix et stock
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    compare_price DECIMAL(10,2), -- Prix barré pour promotions
    cost DECIMAL(10,2), -- Prix de revient pour vendeur
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    track_inventory BOOLEAN DEFAULT TRUE,
    allow_backorder BOOLEAN DEFAULT FALSE,
    
    -- Catégorie et attributs
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(50),
    weight DECIMAL(8,2), -- kg
    dimensions JSONB, -- {"length": 10, "width": 5, "height": 3, "unit": "cm"}
    
    -- Médias
    images JSONB DEFAULT '[]', -- ["image1.jpg", "image2.jpg"]
    featured_image VARCHAR(255),
    
    -- Statut et visibilité
    is_available BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'draft')),
    
    -- SEO
    meta_title VARCHAR(70),
    meta_description VARCHAR(160),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Table des commandes
CREATE TABLE orders (
    -- Identifiants
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) UNIQUE GENERATED ALWAYS AS ('ORD-' || LPAD(EXTRACT(EPOCH FROM created_at)::BIGINT::TEXT, 10, '0')) STORED,
    
    -- Client et vendeur
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    vendor_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Pour commandes de produits
    
    -- Adresses
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10,8),
    pickup_longitude DECIMAL(11,8),
    delivery_address TEXT NOT NULL,
    delivery_latitude DECIMAL(10,8),
    delivery_longitude DECIMAL(11,8),
    
    -- Distance et prix
    distance DECIMAL(8,2) NOT NULL CHECK (distance > 0), -- km
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0), -- FCFA
    delivery_fee DECIMAL(10,2) DEFAULT 500 CHECK (delivery_fee >= 0), -- FCFA
    service_fee DECIMAL(10,2) DEFAULT 0 CHECK (service_fee >= 0), -- FCFA
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0), -- FCFA
    
    -- Suivi
    tracking_code VARCHAR(20) UNIQUE,
    status order_status DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'in_transit', 'delivered', 'cancelled', 'refunded')),
    
    -- Livreur
    delivery_person_id UUID REFERENCES users(id) ON DELETE SET NULL,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    
    -- Instructions
    pickup_instructions TEXT,
    delivery_instructions TEXT,
    special_notes TEXT,
    
    -- Timestamps
    confirmed_at TIMESTAMP WITH TIME ZONE,
    preparing_at TIMESTAMP WITH TIME ZONE,
    ready_at TIMESTAMP WITH TIME ZONE,
    picked_up_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des articles de commande
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Détails article
    name VARCHAR(100) NOT NULL, -- Copie du nom au moment de la commande
    description TEXT, -- Copie de la description
    price DECIMAL(10,2) NOT NULL CHECK (price > 0), -- Prix au moment de la commande
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total DECIMAL(10,2) GENERATED ALWAYS AS (price * quantity) STORED,
    
    -- Statut
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'cancelled')),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des paiements
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Détails paiement
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    method payment_method NOT NULL CHECK (method IN ('cash', 'mobile_money', 'card', 'wallet')),
    status payment_status DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
    
    -- Références externes
    transaction_id VARCHAR(100) UNIQUE,
    gateway_response JSONB,
    
    -- Timestamps
    paid_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Contenu
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type NOT NULL,
    
    -- Métadonnées
    data JSONB, -- Données additionnelles selon le type
    
    -- Statut
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Table des sessions utilisateur (pour authentification)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Session
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    
    -- Appareil
    device_type VARCHAR(50), -- 'mobile', 'web', 'desktop'
    device_id VARCHAR(100),
    user_agent TEXT,
    ip_address INET,
    
    -- Timestamps
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des évaluations
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Évaluation
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    
    -- Type d'évaluation
    review_type VARCHAR(20) NOT NULL CHECK (review_type IN ('delivery', 'product', 'vendor')),
    
    -- Statut
    status VARCHAR(20) DEFAULT 'published' CHECK (status IN ('published', 'hidden', 'flagged')),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEX POUR PERFORMANCES
-- =====================================================

-- Index sur les utilisateurs
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_kyc_level ON users(kyc_level);
CREATE INDEX idx_users_location ON users USING gist(point(longitude, latitude));
CREATE INDEX idx_users_available_delivery ON users(role, is_available, status) WHERE role = 'delivery' AND is_available = TRUE AND status = 'active';

-- Index sur les produits
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_available ON products(is_available);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_name ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock_quantity) WHERE track_inventory = TRUE;

-- Index sur les commandes
CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_orders_vendor ON orders(vendor_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_delivery_person ON orders(delivery_person_id);
CREATE INDEX idx_orders_tracking_code ON orders(tracking_code);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_delivery_location ON orders USING gist(point(delivery_longitude, delivery_latitude));
CREATE INDEX idx_orders_pickup_location ON orders USING gist(point(pickup_longitude, pickup_latitude));

-- Index sur les articles de commande
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_status ON order_items(status);

-- Index sur les paiements
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX idx_payments_method ON payments(method);

-- Index sur les notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Index sur les sessions
CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_sessions_refresh_token ON user_sessions(refresh_token);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);

-- Index sur les évaluations
CREATE INDEX idx_reviews_order ON reviews(order_id);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);
CREATE INDEX idx_reviews_reviewed ON reviews(reviewed_user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_type ON reviews(review_type);

-- =====================================================
-- TRIGGERS ET FONCTIONS
-- =====================================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at sur toutes les tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour générer le numéro de commande
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := 'ORD-' || LPAD(EXTRACT(EPOCH FROM NEW.created_at)::BIGINT::TEXT, 10, '0');
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER generate_order_number_trigger BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- Fonction pour générer le code de suivi
CREATE OR REPLACE FUNCTION generate_tracking_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tracking_code IS NULL THEN
        NEW.tracking_code := 'TRK-' || LPAD(floor(random() * 100000)::TEXT, 5, '0');
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER generate_tracking_code_trigger BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION generate_tracking_code();

-- =====================================================
-- VUES UTILES
-- =====================================================

-- Vue pour les statistiques des commandes
CREATE VIEW order_statistics AS
SELECT 
    status,
    COUNT(*) as count,
    AVG(total_amount) as avg_amount,
    SUM(total_amount) as total_revenue,
    AVG(distance) as avg_distance,
    DATE_TRUNC('day', created_at) as date
FROM orders 
WHERE deleted_at IS NULL
GROUP BY status, DATE_TRUNC('day', created_at);

-- Vue pour les livreurs disponibles
CREATE VIEW available_delivery_persons AS
SELECT 
    id,
    full_name,
    phone,
    rating,
    delivery_level,
    current_location,
    latitude,
    longitude,
    max_delivery_distance,
    vehicle_type
FROM users 
WHERE role = 'delivery' 
  AND status = 'active' 
  AND is_available = TRUE
  AND deleted_at IS NULL;

-- Vue pour les produits populaires
CREATE VIEW popular_products AS
SELECT 
    p.*,
    COUNT(oi.id) as order_count,
    AVG(r.rating) as avg_rating
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN reviews r ON p.id = r.reviewed_user_id AND r.review_type = 'product'
WHERE p.deleted_at IS NULL AND p.is_available = TRUE
GROUP BY p.id
ORDER BY order_count DESC, avg_rating DESC;

-- Vue pour les revenus par vendeur
CREATE VIEW vendor_revenue AS
SELECT 
    u.id as vendor_id,
    u.full_name as vendor_name,
    u.shop_name,
    COUNT(o.id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    DATE_TRUNC('month', o.created_at) as month
FROM users u
LEFT JOIN orders o ON u.id = o.vendor_id
WHERE u.role = 'vendor' AND u.deleted_at IS NULL
GROUP BY u.id, u.full_name, u.shop_name, DATE_TRUNC('month', o.created_at);

-- =====================================================
-- CONTRAINTES ADDITIONNELLES
-- =====================================================

-- Contrainte pour éviter les auto-évaluations
ALTER TABLE reviews ADD CONSTRAINT no_self_review 
CHECK (reviewer_id != reviewed_user_id);

-- Contrainte pour éviter les doublons d'évaluation par commande
ALTER TABLE reviews ADD CONSTRAINT unique_review_per_order 
UNIQUE (order_id, reviewer_id, review_type);

-- =====================================================
-- DONNÉES DE TEST COMPLÈTES
-- =====================================================

-- Utilisateurs de test
INSERT INTO users (id, username, email, phone, password_hash, first_name, last_name, role, rating, kyc_level, shop_name, shop_address, delivery_level, is_available, current_location, latitude, longitude, vehicle_type) VALUES
-- Client
('550e8400-e29b-41d4-a716-446655440001', 'jeankouadio', 'jean.kouadio@email.com', '+2250770000000', '$2b$12$hashedpassword', 'Jean', 'Kouadio', 'client', 4.8, 'VERIFIED', NULL, NULL, NULL, NULL, 'Abidjan, Cocody', 5.3600, -4.0083, NULL),
-- Vendeur
('550e8400-e29b-41d4-a716-446655440002', 'marie_konan', 'marie.konan@email.com', '+2250770101010', '$2b$12$hashedpassword', 'Marie', 'Konan', 'vendor', 4.9, 'CERTIFIED', 'Boutique Marie', 'Abidjan, Cocody, Zone 4', NULL, NULL, 'Abidjan, Cocody', 5.3600, -4.0083, NULL),
-- Livreur 1
('550e8400-e29b-41d4-a716-446655440003', 'paul_yapo', 'paul.yapo@email.com', '+2250770202020', '$2b$12$hashedpassword', 'Paul', 'Yapo', 'delivery', 4.7, 'VERIFIED', NULL, NULL, 'experienced', TRUE, 'Abidjan, Plateau', 5.3572, -4.0099, 'moto'),
-- Livreur 2
('550e8400-e29b-41d4-a716-446655440004', 'antoine_soro', 'antoine.soro@email.com', '+2250770303030', '$2b$12$hashedpassword', 'Antoine', 'Soro', 'delivery', 4.5, 'VERIFIED', NULL, NULL, 'intermediate', TRUE, 'Abidjan, Yopougon', 5.3133, -4.0833, 'voiture'),
-- Livreur 3
('550e8400-e29b-41d4-a716-446655440005', 'fatima_traore', 'fatima.traore@email.com', '+2250770404040', '$2b$12$hashedpassword', 'Fatima', 'Traoré', 'delivery', 4.9, 'CERTIFIED', NULL, NULL, 'expert', FALSE, 'Abidjan, Treichville', 5.2956, -4.0178, 'vélo');

-- Produits de test
INSERT INTO products (vendor_id, name, description, short_description, price, category, subcategory, stock_quantity, is_available, is_featured, images) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'Attiéké et poisson fumé', 'Plat traditionnel ivoirien préparé avec soin, accompagné de poisson fumé grillé et sauce tomate fraîche', 'Attiéké poisson fumé', 2500.00, 'Plats chauds', 'Traditionnels', 50, TRUE, TRUE, '["attieke_poisson.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Alloco et oeuf', 'Banane plantain frite servie avec oeuf au plat et sauce pimentée', 'Alloco oeuf', 1500.00, 'Petit-déjeuner', 'Classiques', 30, TRUE, FALSE, '["alloco_oeuf.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Garba', 'Thon frais accompagné de gari et légumes', 'Garba thon frais', 2000.00, 'Plats chauds', 'Traditionnels', 25, TRUE, TRUE, '["garba_ton.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Foutou banane', 'Pâte de banane plantain servie avec sauce aubergine', 'Foutu banane', 3000.00, 'Plats chauds', 'Traditionnels', 20, TRUE, FALSE, '["foutu_banane.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Boulette de poisson', 'Boulettes de poisson fraîches frites', 'Boulettes poisson', 1000.00, 'Accompagnements', 'Fritures', 40, TRUE, FALSE, '["boulette_poisson.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Sauce gombo', 'Sauce traditionnelle à base de gombo frais', 'Sauce gombo', 800.00, 'Sauces', 'Traditionnelles', 35, TRUE, FALSE, '["sauce_gombo.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Riz sauce arachide', 'Riz blanc accompagné de sauce arachide et viande', 'Riz arachide', 2200.00, 'Plats chauds', 'Traditionnels', 28, TRUE, TRUE, '["riz_arachide.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Jus de bissap', 'Jus frais de fleur de bissap sucré', 'Jus bissap', 500.00, 'Boissons', 'Fraîches', 100, TRUE, FALSE, '["jus_bissap.jpg"]');

-- Commandes de test
INSERT INTO orders (client_id, vendor_id, pickup_address, pickup_latitude, pickup_longitude, delivery_address, delivery_latitude, delivery_longitude, distance, base_price, delivery_fee, total_amount, status, delivery_person_id, pickup_instructions, delivery_instructions) VALUES
-- Commande en attente
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Yopougon, Zone 1', 5.3133, -4.0833, 5.5, 137.50, 500.00, 637.50, 'pending', NULL, 'Préparez bien l''alloco', 'Sonnez à la porte'),
-- Commande confirmée
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Plateau, Rue 12', 5.3572, -4.0099, 3.2, 80.00, 500.00, 580.00, 'confirmed', NULL, 'Ajoutez du piment', 'Appelez avant livraison'),
-- Commande en préparation
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Marcory, Carrefour', 5.3056, -4.0144, 7.8, 195.00, 500.00, 695.00, 'preparing', NULL, 'Sans oignons', 'Livrez à la réception'),
-- Commande prête
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Treichville, Marché', 5.2956, -4.0178, 4.1, 102.50, 500.00, 602.50, 'ready', NULL, 'Bien chaud s''il vous plaît', 'Demandez le gardien'),
-- Commande en livraison
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Abobo, Sagbé', 5.3289, -4.0583, 12.3, 307.50, 500.00, 807.50, 'in_transit', '550e8400-e29b-41d4-a716-446655440003', 'Double portion', 'Appeler 10min avant arrivée'),
-- Commande livrée
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Bingerville', 5.3456, -4.0234, 15.7, 392.50, 500.00, 892.50, 'delivered', '550e8400-e29b-41d4-a716-446655440004', 'Extra piment', 'Livraison confirmée'),
-- Commande annulée
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Abidjan, Cocody, Zone 4, Boutique Marie', 5.3600, -4.0083, 'Abidjan, Anyama', 5.3890, -4.0678, 8.9, 222.50, 500.00, 722.50, 'cancelled', NULL, 'Commande annulée par client', NULL);

-- Articles de commande de test
INSERT INTO order_items (order_id, product_id, name, description, price, quantity) VALUES
-- Commande 1 (pending) - Alloco et oeuf
((SELECT id FROM orders WHERE status = 'pending' LIMIT 1), (SELECT id FROM products WHERE name = 'Alloco et oeuf'), 'Alloco et oeuf', 'Banane plantain frite servie avec oeuf au plat', 1500.00, 1),
-- Commande 2 (confirmed) - Attiéké et poisson
((SELECT id FROM orders WHERE status = 'confirmed' LIMIT 1), (SELECT id FROM products WHERE name = 'Attiéké et poisson fumé'), 'Attiéké et poisson fumé', 'Plat traditionnel ivoirien', 2500.00, 1),
-- Commande 3 (preparing) - Garba + Jus bissap
((SELECT id FROM orders WHERE status = 'preparing' LIMIT 1), (SELECT id FROM products WHERE name = 'Garba'), 'Garba', 'Thon frais avec gari', 2000.00, 1),
((SELECT id FROM orders WHERE status = 'preparing' LIMIT 1), (SELECT id FROM products WHERE name = 'Jus de bissap'), 'Jus de bissap', 'Jus frais de bissap', 500.00, 1),
-- Commande 4 (ready) - Foutou banane
((SELECT id FROM orders WHERE status = 'ready' LIMIT 1), (SELECT id FROM products WHERE name = 'Foutou banane'), 'Foutou banane', 'Pâte de banane plantain', 3000.00, 1),
-- Commande 5 (in_transit) - Riz arachide + Boulette poisson
((SELECT id FROM orders WHERE status = 'in_transit' LIMIT 1), (SELECT id FROM products WHERE name = 'Riz sauce arachide'), 'Riz sauce arachide', 'Riz avec sauce arachide', 2200.00, 1),
((SELECT id FROM orders WHERE status = 'in_transit' LIMIT 1), (SELECT id FROM products WHERE name = 'Boulette de poisson'), 'Boulette de poisson', 'Boulettes de poisson', 1000.00, 1),
-- Commande 6 (delivered) - Sauce gombo
((SELECT id FROM orders WHERE status = 'delivered' LIMIT 1), (SELECT id FROM products WHERE name = 'Sauce gombo'), 'Sauce gombo', 'Sauce traditionnelle', 800.00, 1);

-- Paiements de test
INSERT INTO payments (order_id, amount, method, status, transaction_id) VALUES
-- Commande livrée - payée
((SELECT id FROM orders WHERE status = 'delivered' LIMIT 1), 892.50, 'mobile_money', 'paid', 'MTN-123456'),
-- Commande en livraison - payée
((SELECT id FROM orders WHERE status = 'in_transit' LIMIT 1), 807.50, 'cash', 'pending', NULL),
-- Commande prête - payée
((SELECT id FROM orders WHERE status = 'ready' LIMIT 1), 602.50, 'card', 'paid', 'CARD-789012');

-- Notifications de test
INSERT INTO notifications (user_id, title, message, type, data) VALUES
-- Notification client
('550e8400-e29b-41d4-a716-446655440001', 'Commande confirmée', 'Votre commande #ORD-1234567890 a été confirmée par le vendeur', 'order_confirmed', '{"order_id": "uuid-order-1"}'),
-- Notification vendeur
('550e8400-e29b-41d4-a716-446655440002', 'Nouvelle commande', 'Vous avez reçu une nouvelle commande de Jean Kouadio', 'order_created', '{"order_id": "uuid-order-1", "client_name": "Jean Kouadio"}'),
-- Notification livreur
('550e8400-e29b-41d4-a716-446655440003', 'Nouvelle livraison disponible', 'Une livraison est disponible près de votre position', 'delivery_assigned', '{"order_id": "uuid-order-2", "distance": "3.2km"}');

-- Évaluations de test
INSERT INTO reviews (order_id, reviewer_id, reviewed_user_id, rating, comment, review_type) VALUES
-- Évaluation du livreur
((SELECT id FROM orders WHERE status = 'delivered' LIMIT 1), '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 5, 'Livraison rapide et professionnelle !', 'delivery'),
-- Évaluation du vendeur
((SELECT id FROM orders WHERE status = 'delivered' LIMIT 1), '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 4, 'Bonne nourriture, un peu cher', 'vendor');

-- =====================================================
-- VÉRIFICATION FINALE
-- =====================================================

-- Statistiques finales
SELECT 
    'Base de données DonM créée avec succès !' as message,
    (SELECT COUNT(*) FROM users WHERE role = 'client') as clients,
    (SELECT COUNT(*) FROM users WHERE role = 'vendor') as vendors,
    (SELECT COUNT(*) FROM users WHERE role = 'delivery') as delivery_persons,
    (SELECT COUNT(*) FROM products) as total_products,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM payments) as total_payments,
    (SELECT COUNT(*) FROM notifications) as total_notifications,
    (SELECT COUNT(*) FROM reviews) as total_reviews;

-- Résumé par statut de commande
SELECT 
    status,
    COUNT(*) as count,
    ROUND(AVG(total_amount), 2) as avg_amount
FROM orders 
GROUP BY status 
ORDER BY count DESC;

-- Produits par catégorie
SELECT 
    category,
    COUNT(*) as count,
    AVG(price) as avg_price
FROM products 
WHERE is_available = TRUE
GROUP BY category 
ORDER BY count DESC;

-- Évaluations moyennes
SELECT 
    role,
    COUNT(*) as count,
    ROUND(AVG(rating), 2) as avg_rating
FROM users 
WHERE rating > 0
GROUP BY role 
ORDER BY avg_rating DESC;

-- Message de fin
SELECT '=== BASE DE DONNÉES DONM PRÊTE ===' as status,
       'Toutes les tables, index, triggers et données de test ont été créés' as details;
