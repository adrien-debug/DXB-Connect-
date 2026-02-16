-- DXB Connect Database Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  apple_id VARCHAR(255) UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_users_email ON users(email);

-- Plans table
CREATE TABLE IF NOT EXISTS plans (
  id VARCHAR(50) PRIMARY KEY,
  name_en VARCHAR(255) NOT NULL,
  name_fr VARCHAR(255),
  description_en TEXT,
  description_fr TEXT,
  data_gb INT NOT NULL,
  duration_days INT NOT NULL,
  price_usd DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  coverage JSONB,
  speed VARCHAR(50),
  fair_usage_gb INT,
  supplier_plan_id VARCHAR(255),
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default plans
INSERT INTO plans (id, name_en, name_fr, description_en, description_fr, data_gb, duration_days, price_usd, coverage, speed, fair_usage_gb, active)
VALUES 
  ('plan_3d_5gb', '3 Days - 5GB', '3 Jours - 5GB', 'Perfect for short trips', 'Parfait pour les courts séjours', 5, 3, 15.00, '["Dubai", "UAE"]', '4G/5G', 5, true),
  ('plan_7d_10gb', '7 Days - 10GB', '7 Jours - 10GB', 'Ideal for business travelers', 'Idéal pour les voyageurs d''affaires', 10, 7, 29.00, '["Dubai", "UAE"]', '4G/5G', 10, true),
  ('plan_15d_20gb', '15 Days - 20GB', '15 Jours - 20GB', 'Extended stay package', 'Forfait séjour prolongé', 20, 15, 49.00, '["Dubai", "UAE"]', '4G/5G', 20, true);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(50) PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  plan_id VARCHAR(50) REFERENCES plans(id),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  promo_code VARCHAR(50),
  discount_amount DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(50) NOT NULL,
  payment_intent_id VARCHAR(255),
  stripe_checkout_session_id VARCHAR(255),
  idempotency_key VARCHAR(255) UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id VARCHAR(50) REFERENCES orders(id),
  provider VARCHAR(50) NOT NULL,
  provider_payment_id VARCHAR(255) UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3),
  status VARCHAR(50),
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payments_order_id ON payments(order_id);

-- eSIM Profiles table
CREATE TABLE IF NOT EXISTS esim_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier VARCHAR(50) NOT NULL,
  supplier_profile_id VARCHAR(255) UNIQUE NOT NULL,
  plan_id VARCHAR(50) REFERENCES plans(id),
  status VARCHAR(50) NOT NULL,
  iccid VARCHAR(50),
  smdp_address VARCHAR(255),
  activation_code VARCHAR(255),
  qr_code_data TEXT,
  reserved_at TIMESTAMPTZ,
  assigned_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_esim_profiles_status ON esim_profiles(status);
CREATE INDEX idx_esim_profiles_supplier_profile_id ON esim_profiles(supplier_profile_id);

-- Order eSIM Assignments table
CREATE TABLE IF NOT EXISTS order_esim_assignments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id VARCHAR(50) REFERENCES orders(id),
  esim_profile_id UUID REFERENCES esim_profiles(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(order_id, esim_profile_id)
);

CREATE INDEX idx_assignments_order_id ON order_esim_assignments(order_id);

-- Admin Users table
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  role VARCHAR(50) NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit Logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_user_id UUID REFERENCES admin_users(id),
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(50),
  resource_id VARCHAR(255),
  ip VARCHAR(50),
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_admin_user_id ON audit_logs(admin_user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
  id VARCHAR(50) PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  order_id VARCHAR(50) REFERENCES orders(id),
  subject VARCHAR(255) NOT NULL,
  status VARCHAR(50) DEFAULT 'open',
  priority VARCHAR(50) DEFAULT 'normal',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_tickets_status ON tickets(status);

-- Ticket Messages table
CREATE TABLE IF NOT EXISTS ticket_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id VARCHAR(50) REFERENCES tickets(id),
  sender_type VARCHAR(50) NOT NULL,
  sender_id UUID,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);

-- Promo Codes table
CREATE TABLE IF NOT EXISTS promo_codes (
  code VARCHAR(50) PRIMARY KEY,
  discount_type VARCHAR(50) NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  max_uses INT,
  used_count INT DEFAULT 0,
  expires_at TIMESTAMPTZ,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events table (for analytics)
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  event_type VARCHAR(100) NOT NULL,
  properties JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_events_user_id ON events(user_id);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_created_at ON events(created_at);
