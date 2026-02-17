-- Migration: Fix Database Relations
-- Date: 2026-02-17
-- Description: Corrige les relations manquantes et problèmes d'intégrité référentielle

-- ============================================
-- 1. AJOUTER LES FOREIGN KEYS MANQUANTES
-- ============================================

-- FK: orders.user_id → profiles.id
ALTER TABLE orders
ADD CONSTRAINT IF NOT EXISTS fk_orders_user
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- FK: cart_items.user_id → profiles.id
ALTER TABLE cart_items
ADD CONSTRAINT IF NOT EXISTS fk_cart_items_user
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- FK: esim_orders.user_id → profiles.id
ALTER TABLE esim_orders
ADD CONSTRAINT IF NOT EXISTS fk_esim_orders_user
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- ============================================
-- 2. PROTÉGER L'HISTORIQUE DES COMMANDES
-- ============================================

-- Empêcher la suppression de produits avec des commandes
-- Changer ON DELETE de SET NULL à RESTRICT
ALTER TABLE order_items
DROP CONSTRAINT IF EXISTS order_items_product_id_fkey;

ALTER TABLE order_items
ADD CONSTRAINT order_items_product_id_fkey
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;

-- ============================================
-- 3. AJOUTER DES INDEX POUR PERFORMANCE
-- ============================================

-- Index sur user_id pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);

CREATE INDEX IF NOT EXISTS idx_esim_orders_user_id ON esim_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_esim_orders_status ON esim_orders(status);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_products_supplier_id ON products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);

-- ============================================
-- 4. LIER LA TABLE CUSTOMERS À PROFILES
-- ============================================

-- Ajouter colonne profile_id à customers
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL;

-- Index pour la nouvelle relation
CREATE INDEX IF NOT EXISTS idx_customers_profile_id ON customers(profile_id);

-- ============================================
-- 5. AJOUTER SOFT DELETE
-- ============================================

-- Ajouter deleted_at aux tables critiques
ALTER TABLE products ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Index pour filtrer les éléments non supprimés
CREATE INDEX IF NOT EXISTS idx_products_deleted_at ON products(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_orders_deleted_at ON orders(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_customers_deleted_at ON customers(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_suppliers_deleted_at ON suppliers(deleted_at) WHERE deleted_at IS NULL;

-- ============================================
-- 6. CRÉER DES VUES POUR SOFT DELETE
-- ============================================

-- Vue pour produits actifs (non supprimés)
CREATE OR REPLACE VIEW active_products AS
SELECT * FROM products WHERE deleted_at IS NULL;

-- Vue pour commandes actives
CREATE OR REPLACE VIEW active_orders AS
SELECT * FROM orders WHERE deleted_at IS NULL;

-- Vue pour clients actifs
CREATE OR REPLACE VIEW active_customers AS
SELECT * FROM customers WHERE deleted_at IS NULL;

-- Vue pour fournisseurs actifs
CREATE OR REPLACE VIEW active_suppliers AS
SELECT * FROM suppliers WHERE deleted_at IS NULL;

-- ============================================
-- 7. AJOUTER TIMESTAMPS MANQUANTS
-- ============================================

-- Ajouter updated_at si manquant
ALTER TABLE ad_campaigns ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE esim_orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================
-- 8. FONCTIONS UTILITAIRES
-- ============================================

-- Fonction pour soft delete
CREATE OR REPLACE FUNCTION soft_delete_product(product_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE products
  SET deleted_at = NOW()
  WHERE id = product_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour restaurer un produit supprimé
CREATE OR REPLACE FUNCTION restore_product(product_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE products
  SET deleted_at = NULL
  WHERE id = product_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. TRIGGERS POUR AUTO-UPDATE
-- ============================================

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger aux tables qui en ont besoin
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_suppliers_updated_at ON suppliers;
CREATE TRIGGER update_suppliers_updated_at
  BEFORE UPDATE ON suppliers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
CREATE TRIGGER update_customers_updated_at
  BEFORE UPDATE ON customers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_ad_campaigns_updated_at ON ad_campaigns;
CREATE TRIGGER update_ad_campaigns_updated_at
  BEFORE UPDATE ON ad_campaigns
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 10. CONTRAINTES DE VALIDATION
-- ============================================

-- Vérifier que le prix est positif
ALTER TABLE products
ADD CONSTRAINT IF NOT EXISTS check_products_price_positive
CHECK (price >= 0);

-- Vérifier que le stock est positif
ALTER TABLE products
ADD CONSTRAINT IF NOT EXISTS check_products_stock_positive
CHECK (stock >= 0);

-- Vérifier que la quantité du panier est positive
ALTER TABLE cart_items
ADD CONSTRAINT IF NOT EXISTS check_cart_items_quantity_positive
CHECK (quantity > 0);

-- Vérifier que le total de la commande est positif
ALTER TABLE orders
ADD CONSTRAINT IF NOT EXISTS check_orders_total_positive
CHECK (total >= 0);

-- ============================================
-- 11. COMMENTAIRES POUR DOCUMENTATION
-- ============================================

COMMENT ON TABLE products IS 'Catalogue des produits vendus';
COMMENT ON TABLE suppliers IS 'Fournisseurs de produits';
COMMENT ON TABLE customers IS 'Base de données clients (CRM)';
COMMENT ON TABLE orders IS 'Commandes e-commerce';
COMMENT ON TABLE order_items IS 'Détails des articles commandés';
COMMENT ON TABLE cart_items IS 'Panier d''achat des utilisateurs';
COMMENT ON TABLE esim_orders IS 'Commandes eSIM via eSIM Access API';
COMMENT ON TABLE ad_campaigns IS 'Campagnes publicitaires (Google Ads, Facebook, etc.)';
COMMENT ON TABLE profiles IS 'Profils utilisateurs liés à auth.users';

COMMENT ON COLUMN products.supplier_id IS 'FK vers suppliers.id';
COMMENT ON COLUMN order_items.product_id IS 'FK vers products.id (RESTRICT pour préserver historique)';
COMMENT ON COLUMN order_items.order_id IS 'FK vers orders.id';
COMMENT ON COLUMN cart_items.product_id IS 'FK vers products.id';
COMMENT ON COLUMN cart_items.user_id IS 'FK vers profiles.id';
COMMENT ON COLUMN orders.user_id IS 'FK vers profiles.id';
COMMENT ON COLUMN esim_orders.user_id IS 'FK vers profiles.id';
COMMENT ON COLUMN customers.profile_id IS 'FK vers profiles.id (optionnel pour lier CRM à auth)';

-- ============================================
-- 12. STATISTIQUES POUR OPTIMISATION
-- ============================================

-- Analyser les tables pour mettre à jour les statistiques
ANALYZE products;
ANALYZE suppliers;
ANALYZE customers;
ANALYZE orders;
ANALYZE order_items;
ANALYZE cart_items;
ANALYZE esim_orders;
ANALYZE ad_campaigns;
ANALYZE profiles;

-- ============================================
-- FIN DE LA MIGRATION
-- ============================================

-- Log de succès
DO $$
BEGIN
  RAISE NOTICE 'Migration 003_fix_relations.sql appliquée avec succès';
  RAISE NOTICE 'Foreign keys ajoutées: orders, cart_items, esim_orders';
  RAISE NOTICE 'Index créés pour performance';
  RAISE NOTICE 'Soft delete activé sur: products, orders, customers, suppliers';
  RAISE NOTICE 'Triggers updated_at activés';
END $$;
