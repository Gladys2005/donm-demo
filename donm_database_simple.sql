-- =====================================================
-- BASE DE DONNÉES DONM - POSTGRESQL SIMPLE
-- Version: 1.2 (Sans colonnes générées ni triggers)
-- =====================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Types
CREATE TYPE user_role AS ENUM ('client', 'vendor', 'delivery');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE kyc_level AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'CERTIFIED', 'REJECTED');
CREATE TYPE delivery_level AS ENUM ('beginner', 'intermediate', 'experienced', 'expert');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'in_transit', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_method AS ENUM ('cash', 'mobile_money', 'card', 'wallet');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE notification_type AS ENUM ('order_created', 'order_confirmed', 'order_ready', 'order_delivered', 'payment_received', 'delivery_assigned', 'system');

-- Table users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101),
    avatar_url VARCHAR(255),
    date_of_birth DATE,
    role user_role NOT NULL,
    status user_status DEFAULT 'active',
    kyc_level kyc_level DEFAULT 'NONE',
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_ratings INTEGER DEFAULT 0,
    total_deliveries INTEGER DEFAULT 0,
    current_location TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    address TEXT,
    shop_name VARCHAR(100),
    shop_address TEXT,
    shop_description TEXT,
    shop_logo_url VARCHAR(255),
    business_registration_number VARCHAR(50),
    delivery_level delivery_level DEFAULT 'beginner',
    vehicle_type VARCHAR(50),
    vehicle_plate VARCHAR(20),
    is_available BOOLEAN DEFAULT TRUE,
    max_delivery_distance DECIMAL(8,2) DEFAULT 20.0,
    language VARCHAR(10) DEFAULT 'fr',
    timezone VARCHAR(50) DEFAULT 'Africa/Abidjan',
    notification_enabled BOOLEAN DEFAULT TRUE,
    member_since TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Table products
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    description TEXT,
    short_description VARCHAR(255),
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    compare_price DECIMAL(10,2),
    cost DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    track_inventory BOOLEAN DEFAULT TRUE,
    allow_backorder BOOLEAN DEFAULT FALSE,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(50),
    weight DECIMAL(8,2),
    dimensions JSONB,
    images JSONB DEFAULT '[]',
    featured_image VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'draft')),
    meta_title VARCHAR(70),
    meta_description VARCHAR(160),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Table orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) UNIQUE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    vendor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10,8),
    pickup_longitude DECIMAL(11,8),
    delivery_address TEXT NOT NULL,
    delivery_latitude DECIMAL(10,8),
    delivery_longitude DECIMAL(11,8),
    distance DECIMAL(8,2) NOT NULL CHECK (distance > 0),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0),
    delivery_fee DECIMAL(10,2) DEFAULT 500 CHECK (delivery_fee >= 0),
    service_fee DECIMAL(10,2) DEFAULT 0 CHECK (service_fee >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
    tracking_code VARCHAR(20) UNIQUE,
    status order_status DEFAULT 'pending',
    delivery_person_id UUID REFERENCES users(id) ON DELETE SET NULL,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    pickup_instructions TEXT,
    delivery_instructions TEXT,
    special_notes TEXT,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    preparing_at TIMESTAMP WITH TIME ZONE,
    ready_at TIMESTAMP WITH TIME ZONE,
    picked_up_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table order_items
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total DECIMAL(10,2) DEFAULT 0 CHECK (total >= 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tables restantes (payments, notifications, user_sessions, reviews)
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    method payment_method NOT NULL,
    status payment_status DEFAULT 'pending',
    transaction_id VARCHAR(100) UNIQUE,
    gateway_response JSONB,
    paid_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    device_type VARCHAR(50),
    device_id VARCHAR(100),
    user_agent TEXT,
    ip_address INET,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_type VARCHAR(20) NOT NULL CHECK (review_type IN ('delivery', 'product', 'vendor')),
    status VARCHAR(20) DEFAULT 'published' CHECK (status IN ('published', 'hidden', 'flagged')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT no_self_review CHECK (reviewer_id != reviewed_user_id),
    CONSTRAINT unique_review_per_order UNIQUE (order_id, reviewer_id, review_type)
);

-- Index essentiels
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_client ON orders(client_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);

-- Données de test simplifiées
INSERT INTO users (id, username, email, phone, password_hash, first_name, last_name, role, rating, kyc_level, shop_name, shop_address, delivery_level, is_available, current_location, latitude, longitude, vehicle_type) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'jeankouadio', 'jean.kouadio@email.com', '+2250770000000', '$2b$12$hashedpassword', 'Jean', 'Kouadio', 'client', 4.8, 'VERIFIED', NULL, NULL, NULL, NULL, 'Abidjan, Cocody', 5.3600, -4.0083, NULL),
('550e8400-e29b-41d4-a716-446655440002', 'marie_konan', 'marie.konan@email.com', '+2250770101010', '$2b$12$hashedpassword', 'Marie', 'Konan', 'vendor', 4.9, 'CERTIFIED', 'Boutique Marie', 'Abidjan, Cocody, Zone 4', NULL, NULL, 'Abidjan, Cocody', 5.3600, -4.0083, NULL),
('550e8400-e29b-41d4-a716-446655440003', 'paul_yapo', 'paul.yapo@email.com', '+2250770202020', '$2b$12$hashedpassword', 'Paul', 'Yapo', 'delivery', 4.7, 'VERIFIED', NULL, NULL, 'experienced', TRUE, 'Abidjan, Plateau', 5.3572, -4.0099, 'moto');

INSERT INTO products (vendor_id, name, description, short_description, price, category, subcategory, stock_quantity, is_available, is_featured, images) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'Attiéké et poisson fumé', 'Plat traditionnel ivoirien', 'Attiéké poisson fumé', 2500.00, 'Plats chauds', 'Traditionnels', 50, TRUE, TRUE, '["attieke.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Alloco et oeuf', 'Banane plantain frite avec oeuf', 'Alloco oeuf', 1500.00, 'Petit-déjeuner', 'Classiques', 30, TRUE, FALSE, '["alloco.jpg"]'),
('550e8400-e29b-41d4-a716-446655440002', 'Garba', 'Thon frais avec gari', 'Garba thon frais', 2000.00, 'Plats chauds', 'Traditionnels', 25, TRUE, TRUE, '["garba.jpg"]');

-- Mise à jour manuelle des champs calculés
UPDATE users SET full_name = first_name || ' ' || last_name;
UPDATE products SET slug = lower(regexp_replace(name, '[^a-zA-Z0-9]', '-', 'g'));

SELECT 'Base de données DonM créée avec succès !' as message;
