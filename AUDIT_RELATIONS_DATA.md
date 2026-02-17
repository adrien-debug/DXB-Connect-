# Audit des Relations de Données - DXB Connect

**Date**: 17 février 2026
**Version**: 1.0

## 📋 Sommaire

1. [Vue d'ensemble](#vue-densemble)
2. [Schéma de base de données](#schéma-de-base-de-données)
3. [Relations par table](#relations-par-table)
4. [Mapping Pages ↔ Tables](#mapping-pages--tables)
5. [Problèmes identifiés](#problèmes-identifiés)
6. [Recommandations](#recommandations)

---

## 🎯 Vue d'ensemble

### Architecture actuelle
- **Frontend**: Next.js 14 (App Router)
- **Base de données**: Supabase (PostgreSQL)
- **ORM**: Supabase Client
- **Types**: TypeScript généré depuis Supabase

### Tables principales
```
Système e-commerce:
├── products (produits)
├── suppliers (fournisseurs)
├── customers (clients)
├── orders (commandes)
├── order_items (articles de commande)
├── cart_items (panier)
└── profiles (profils utilisateurs)

Système eSIM:
├── esim_orders (commandes eSIM)
└── [API externe: eSIM Access]

Système marketing:
└── ad_campaigns (campagnes publicitaires)

Système DLD (immobilier - non utilisé):
├── dld_transactions
├── dld_listings
├── dld_opportunities
├── dld_market_baselines
├── dld_market_regimes
├── dld_mortgages
├── dld_rental_index
├── dld_developers_pipeline
├── dld_daily_briefs
└── dld_alerts
```

---

## 🗄️ Schéma de base de données

### Relations clés

#### 1. **products** → **suppliers**
```sql
products.supplier_id → suppliers.id (FK)
```
- **Type**: Many-to-One
- **Cascade**: Non défini
- **Usage**: Chaque produit peut avoir un fournisseur

#### 2. **cart_items** → **products**
```sql
cart_items.product_id → products.id (FK)
```
- **Type**: Many-to-One
- **Cascade**: Non défini
- **Usage**: Articles dans le panier

#### 3. **order_items** → **orders**
```sql
order_items.order_id → orders.id (FK)
```
- **Type**: Many-to-One
- **Cascade**: Non défini
- **Usage**: Détails des articles commandés

#### 4. **order_items** → **products**
```sql
order_items.product_id → products.id (FK)
```
- **Type**: Many-to-One
- **Cascade**: Non défini
- **Usage**: Référence au produit commandé

#### 5. **orders** → **profiles** (implicite)
```sql
orders.user_id → profiles.id
```
- **Type**: Many-to-One
- **Cascade**: Non défini dans le schéma
- **Usage**: Commandes par utilisateur

#### 6. **esim_orders** → **profiles** (implicite)
```sql
esim_orders.user_id → profiles.id
```
- **Type**: Many-to-One
- **Cascade**: Non défini
- **Usage**: Commandes eSIM par utilisateur

---

## 📊 Relations par table

### Table: `products`

**Colonnes clés**:
- `id` (PK)
- `supplier_id` (FK → suppliers)
- `name`, `sku`, `price`, `stock`

**Relations**:
- **Sortantes**:
  - → `suppliers` (Many-to-One)
- **Entrantes**:
  - ← `cart_items` (One-to-Many)
  - ← `order_items` (One-to-Many)

**Pages utilisant cette table**:
- `/products` - Liste et gestion des produits
- `/orders` - Affichage des produits commandés

---

### Table: `suppliers`

**Colonnes clés**:
- `id` (PK)
- `name`, `email`, `api_status`, `api_key`

**Relations**:
- **Sortantes**: Aucune
- **Entrantes**:
  - ← `products` (One-to-Many)

**Pages utilisant cette table**:
- `/suppliers` - Gestion des fournisseurs
- `/products` - Affichage du fournisseur par produit

---

### Table: `customers`

**Colonnes clés**:
- `id` (PK)
- `first_name`, `last_name`, `email`, `lifetime_value`

**Relations**:
- **Sortantes**: Aucune
- **Entrantes**: Aucune (table isolée)

**Pages utilisant cette table**:
- `/customers` - Gestion des clients

**⚠️ PROBLÈME**: Table `customers` non reliée aux `orders` ou `profiles`

---

### Table: `orders`

**Colonnes clés**:
- `id` (PK)
- `user_id` (FK implicite → profiles)
- `order_number`, `total`, `status`, `payment_status`

**Relations**:
- **Sortantes**:
  - → `profiles` (Many-to-One, implicite)
- **Entrantes**:
  - ← `order_items` (One-to-Many)

**Pages utilisant cette table**:
- `/orders` - Liste des commandes utilisateur

---

### Table: `order_items`

**Colonnes clés**:
- `id` (PK)
- `order_id` (FK → orders)
- `product_id` (FK → products)
- `quantity`, `unit_price`, `total_price`

**Relations**:
- **Sortantes**:
  - → `orders` (Many-to-One)
  - → `products` (Many-to-One)
- **Entrantes**: Aucune

**Pages utilisant cette table**:
- `/orders` - Détails des articles par commande

---

### Table: `cart_items`

**Colonnes clés**:
- `id` (PK)
- `user_id` (FK implicite → profiles)
- `product_id` (FK → products)
- `quantity`

**Relations**:
- **Sortantes**:
  - → `profiles` (Many-to-One, implicite)
  - → `products` (Many-to-One)
- **Entrantes**: Aucune

**Pages utilisant cette table**:
- Composant `CartDrawer` (panier global)

---

### Table: `ad_campaigns`

**Colonnes clés**:
- `id` (PK)
- `name`, `platform`, `budget`, `spent`, `clicks`, `conversions`

**Relations**:
- **Sortantes**: Aucune
- **Entrantes**: Aucune (table isolée)

**Pages utilisant cette table**:
- `/ads` - Gestion des campagnes publicitaires
- `/dashboard` - Statistiques des campagnes

---

### Table: `esim_orders`

**Colonnes clés**:
- `id` (PK)
- `user_id` (FK implicite → profiles)
- `order_no`, `package_code`, `iccid`, `qr_code_url`

**Relations**:
- **Sortantes**:
  - → `profiles` (Many-to-One, implicite)
- **Entrantes**: Aucune

**Pages utilisant cette table**:
- `/esim/orders` - Liste des eSIMs achetées

---

### Table: `profiles`

**Colonnes clés**:
- `id` (PK, lié à auth.users)
- `email`, `full_name`, `role`

**Relations**:
- **Sortantes**: Aucune
- **Entrantes**:
  - ← `orders` (One-to-Many, implicite)
  - ← `cart_items` (One-to-Many, implicite)
  - ← `esim_orders` (One-to-Many, implicite)

**Pages utilisant cette table**:
- Système d'authentification global

---

## 🗺️ Mapping Pages ↔ Tables

### Page: `/dashboard`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `suppliers` | SELECT COUNT | `id` |
| `customers` | SELECT COUNT | `id` |
| `ad_campaigns` | SELECT * | `budget`, `spent`, `conversions`, `platform`, `clicks` |

**Relations exploitées**: Aucune (agrégations simples)

---

### Page: `/customers`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `customers` | SELECT, INSERT, UPDATE, DELETE | Toutes |

**Relations exploitées**: Aucune

**⚠️ PROBLÈME**: Pas de lien avec les commandes réelles

---

### Page: `/suppliers`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `suppliers` | SELECT, INSERT, UPDATE, DELETE | Toutes |

**Relations exploitées**: Aucune directe

**Note**: Les produits liés ne sont pas affichés

---

### Page: `/products`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `products` | SELECT, INSERT, UPDATE, DELETE | Toutes |
| `suppliers` | SELECT (JOIN) | `name`, `api_status` |

**Relations exploitées**:
```typescript
.from('products')
.select('*, supplier:suppliers(*)')
```

**✅ CORRECT**: Utilise la relation FK `products.supplier_id`

---

### Page: `/ads`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `ad_campaigns` | SELECT, INSERT, UPDATE, DELETE | Toutes |

**Relations exploitées**: Aucune

---

### Page: `/orders`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `orders` | SELECT | Toutes |
| `order_items` | SELECT (nested) | `product_name`, `quantity`, `unit_price` |

**Relations exploitées**:
```typescript
// Via hook useOrders
.from('orders')
.select('*, items:order_items(*)')
.eq('user_id', user.id)
```

**✅ CORRECT**: Utilise la relation FK `order_items.order_id`

---

### Page: `/esim`

**Tables utilisées**:
| Table | Opération | Source |
|-------|-----------|--------|
| N/A | SELECT | API externe (eSIM Access) |

**Relations exploitées**: Aucune (données externes)

---

### Page: `/esim/orders`

**Tables utilisées**:
| Table | Opération | Colonnes |
|-------|-----------|----------|
| `esim_orders` | SELECT | Toutes |

**Relations exploitées**:
```typescript
.from('esim_orders')
.select('*')
.eq('user_id', user.id)
```

**✅ CORRECT**: Filtre par utilisateur

---

## 🚨 Problèmes identifiés

### 1. **Table `customers` isolée**

**Problème**: La table `customers` n'a aucune relation avec `orders` ou `profiles`.

**Impact**:
- Impossible de lier un client à ses commandes
- Duplication potentielle des données client
- Incohérence entre `customers` et `profiles`

**Solution recommandée**:
```sql
-- Option A: Lier customers à profiles
ALTER TABLE customers ADD COLUMN profile_id UUID REFERENCES profiles(id);

-- Option B: Fusionner avec profiles
-- Migrer les données de customers vers profiles
```

---

### 2. **Relations implicites non contraintes**

**Problème**: Les FK `user_id` dans `orders`, `cart_items`, `esim_orders` ne sont pas définies explicitement.

**Impact**:
- Pas de contrainte d'intégrité référentielle
- Risque de données orphelines
- Pas de cascade DELETE

**Solution recommandée**:
```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_user
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE cart_items
ADD CONSTRAINT fk_cart_items_user
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE esim_orders
ADD CONSTRAINT fk_esim_orders_user
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
```

---

### 3. **Tables DLD non utilisées**

**Problème**: 10+ tables DLD (immobilier) présentes mais jamais utilisées dans l'app.

**Impact**:
- Pollution du schéma
- Confusion pour les développeurs
- Types TypeScript inutiles générés

**Solution recommandée**:
```sql
-- Supprimer les tables DLD si non utilisées
DROP TABLE IF EXISTS dld_transactions CASCADE;
DROP TABLE IF EXISTS dld_listings CASCADE;
-- ... etc
```

---

### 4. **Pas de relation `products` ↔ `orders`**

**Problème**: `order_items.product_id` peut devenir NULL si le produit est supprimé.

**Impact**:
- Perte d'historique produit
- Impossible de reconstruire les commandes passées

**Solution recommandée**:
```sql
-- Ne pas permettre la suppression de produits avec des commandes
ALTER TABLE order_items
ALTER COLUMN product_id SET NOT NULL;

-- Ou utiliser ON DELETE RESTRICT
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
```

---

### 5. **Pas de table `users` visible**

**Problème**: Les `user_id` référencent `auth.users` (Supabase Auth) mais pas de table `users` publique.

**Impact**:
- Impossible de faire des JOINs directs
- Dépendance forte à Supabase Auth

**Solution actuelle**: Table `profiles` sert de proxy (✅ correct)

---

### 6. **Pas de soft delete**

**Problème**: Aucune table n'utilise de soft delete (`deleted_at`).

**Impact**:
- Suppression définitive des données
- Impossible de récupérer des données supprimées par erreur

**Solution recommandée**:
```sql
-- Ajouter deleted_at aux tables critiques
ALTER TABLE products ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE customers ADD COLUMN deleted_at TIMESTAMPTZ;
```

---

## 📈 Recommandations

### Priorité HAUTE

1. **Définir les FK manquantes**
   ```sql
   ALTER TABLE orders ADD CONSTRAINT fk_orders_user ...
   ALTER TABLE cart_items ADD CONSTRAINT fk_cart_items_user ...
   ALTER TABLE esim_orders ADD CONSTRAINT fk_esim_orders_user ...
   ```

2. **Résoudre le problème `customers`**
   - Soit lier à `profiles`
   - Soit supprimer la table et utiliser `profiles`

3. **Protéger l'historique des commandes**
   ```sql
   ALTER TABLE order_items
   ADD CONSTRAINT fk_order_items_product
   FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
   ```

### Priorité MOYENNE

4. **Nettoyer les tables DLD**
   - Supprimer si non utilisées
   - Ou documenter leur usage futur

5. **Ajouter des index**
   ```sql
   CREATE INDEX idx_orders_user_id ON orders(user_id);
   CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
   CREATE INDEX idx_esim_orders_user_id ON esim_orders(user_id);
   CREATE INDEX idx_order_items_order_id ON order_items(order_id);
   ```

6. **Implémenter soft delete**
   - Ajouter `deleted_at` aux tables critiques
   - Créer des vues pour filtrer automatiquement

### Priorité BASSE

7. **Ajouter des timestamps manquants**
   ```sql
   -- Certaines tables n'ont pas updated_at
   ALTER TABLE ad_campaigns ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
   ```

8. **Documenter les relations dans le code**
   ```typescript
   // Ajouter des commentaires JSDoc
   /**
    * @relation products.supplier_id → suppliers.id
    */
   ```

---

## 📝 Diagramme des relations

```
┌─────────────┐
│  profiles   │
│  (users)    │
└──────┬──────┘
       │
       ├─────────────────────────┐
       │                         │
       ▼                         ▼
┌─────────────┐          ┌──────────────┐
│   orders    │          │  cart_items  │
└──────┬──────┘          └──────┬───────┘
       │                        │
       │                        │
       ▼                        ▼
┌─────────────┐          ┌─────────────┐
│ order_items │          │  products   │
└──────┬──────┘          └──────┬──────┘
       │                        │
       └────────────┬───────────┘
                    │
                    ▼
             ┌─────────────┐
             │  suppliers  │
             └─────────────┘

┌─────────────┐
│  profiles   │
└──────┬──────┘
       │
       ▼
┌──────────────┐
│ esim_orders  │
└──────────────┘

┌──────────────┐
│ ad_campaigns │  (isolée)
└──────────────┘

┌──────────────┐
│  customers   │  (isolée - PROBLÈME)
└──────────────┘
```

---

## 🎯 Conclusion

### Points forts
- ✅ Relations `products` ↔ `suppliers` bien définies
- ✅ Relations `orders` ↔ `order_items` fonctionnelles
- ✅ Séparation claire e-commerce / eSIM

### Points faibles
- ❌ Table `customers` non reliée
- ❌ FK implicites non contraintes
- ❌ Tables DLD inutilisées
- ❌ Pas de soft delete
- ❌ Pas de protection historique commandes

### Score global: **6/10**

**Recommandation**: Appliquer les correctifs de priorité HAUTE avant mise en production.

---

**Document généré le**: 17 février 2026
**Auteur**: Audit automatique DXB Connect
**Version**: 1.0
