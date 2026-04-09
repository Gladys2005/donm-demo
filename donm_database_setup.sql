-- ========================================
-- BASE DE DONNÉES DONM - POSTGRESQL
-- ========================================

-- Activer les extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ========================================
-- TYPES PERSONNALISÉS
-- ========================================

CREATE TYPE user_role AS ENUM ('client', 'vendor', 'delivery');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE kyc_level AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'CERTIFIED');
CREATE TYPE delivery_level AS ENUM ('beginner', 'intermediate', 'experienced');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'in_transit', 'delivered', 'cancelled');

-- ========================================
-- TABLES PRINCIPALES
-- ========================================

-- 1. Table des utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role user_role NOT NULL,
    status user_status DEFAULT 'active',
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    member_since TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    kyc_level kyc_level DEFAULT 'NONE',
    
    -- Champs spécifiques vendeur
    shop_name VARCHAR(100),
    shop_address TEXT,
    
    -- Champs spécifiques livreur
    delivery_level delivery_level DEFAULT 'beginner',
    current_location TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table des produits
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    category VARCHAR(50) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    images JSONB DEFAULT '[]',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table des commandes
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    pickup_address TEXT NOT NULL,
    delivery_address TEXT NOT NULL,
    distance DECIMAL(8,2) NOT NULL CHECK (distance > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    status order_status DEFAULT 'pending',
    tracking_code VARCHAR(20) UNIQUE,
    delivery_person_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Table des articles de commande
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- INDEX POUR PERFORMANCES
-- ========================================

-- Index sur les utilisateurs
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);

-- Index sur les produits
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_available ON products(is_available);
CREATE INDEX idx_products_name ON products USING gin(name gin_trgm_ops);

-- Index sur les commandes
CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_delivery_person ON orders(delivery_person_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_tracking_code ON orders(tracking_code);

-- Index sur les articles de commande
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ========================================
-- TRIGGERS POUR updated_at
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- DONNÉES DE TEST
-- ========================================

-- Utilisateurs de test
INSERT INTO users (id, name, email, phone, role, rating, kyc_level, shop_name, shop_address, delivery_level, is_available) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Jean Kouadio', 'jean.kouadio@email.com', '+2250770000000', 'client', 4.8, 'VERIFIED', NULL, NULL, NULL, NULL),
('550e8400-e29b-41d4-a716-446655440002', 'Marie Konan', 'marie.konan@email.com', '+2250770101010', 'vendor', 4.9, 'CERTIFIED', 'Boutique Marie', 'Abidjan, Cocody', NULL, NULL),
('550e8400-e29b-41d4-a716-446655440003', 'Paul Yapo', 'paul.yapo@email.com', '+2250770202020', 'delivery', 4.7, 'VERIFIED', NULL, NULL, 'experienced', TRUE);

-- Produits de test
INSERT INTO products (vendor_id, name, description, price, category, is_available, images) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'Attiéké et poisson fumé', 'Plat traditionnel ivoirien préparé avec soin', 2500.00, 'Plats chauds', TRUE, '["attieke.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Alloco et oeuf', 'Banane plantain frite servie avec oeuf', 1500.00, 'Petit-déjeuner', TRUE, '["alloco.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Garba', 'Thon frais accompagné de gari', 2000.00, 'Plats chauds', TRUE, '["garba.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Foutou', 'Viande de b\u0153uf en sauce avec riz', 3000.00, 'Plats chauds', TRUE, '["foutou.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Boulette de poisson', 'Boulettes de poisson fraîches', 1000.00, 'Accompagnements', FALSE, '["boulette.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Sauce gombo', 'Sauce traditionnelle à base de gombo', 800.00, 'Sauces', TRUE, '["gombo.jpg"]');

-- Commandes de test
INSERT INTO orders (client_id, pickup_address, delivery_address, distance, price, status, tracking_code, delivery_person_id) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Abidjan, Cocody, Boutique Marie', 'Abidjan, Yopougon, Zone 1', 5.5, 637.50, 'pending', 'TRK-1001', NULL),
('550e8400-e29b-41d4-a716-446655440001', 'Abidjan, Cocody, Boutique Marie', 'Abidjan, Plateau', 3.2, 580.00, 'confirmed', 'TRK-1002', NULL),
('550e8400-e29b-41d4-a716-446655440001', 'Abidjan, Cocody, Boutique Marie', 'Abidjan, Marcory', 7.8, 695.00, 'preparing', 'TRK-1003', NULL),
('550e8400-e29b-41d4-a716-446655440001', 'Abidjan, Cocody, Boutique Marie', 'Abidjan, Treichville', 4.1, 602.50, 'ready', 'TRK-1004', NULL),
('550e8400-e29b-41d4-a716-446655440001', 'Abidjan, Cocody, Boutique Marie', 'Abidjan, Abobo', 12.3, 807.50, 'in_transit', 'TRK-1005', '550e8400-e29b-41d4-a716-446655440003'),
('550e8400-e29b-41d4-a716-446655440001', 'Abidjan, Cocody, Boutique Marie', 'Abidjan, Bingerville', 15.7, 892.50, 'delivered', 'TRK-1006', '550e8400-e29b-41d4-a716-446655440003');

-- ========================================
-- VÉRIFICATION
-- ========================================

-- Afficher les statistiques
SELECT 
  (SELECT COUNT(*) FROM users WHERE role = 'client') as clients,
  (SELECT COUNT(*) FROM users WHERE role = 'vendor') as vendors,
  (SELECT COUNT(*) FROM users WHERE role = 'delivery') as delivery_persons,
  (SELECT COUNT(*) FROM products) as total_products,
  (SELECT COUNT(*) FROM orders) as total_orders;

-- Afficher les commandes par statut
SELECT status, COUNT(*) as count FROM orders GROUP BY status;

-- Afficher les produits par catégorie
SELECT category, COUNT(*) as count FROM products GROUP BY category;

-- Message de succès
SELECT 'Base de données DonM créée avec succès !' as message;
