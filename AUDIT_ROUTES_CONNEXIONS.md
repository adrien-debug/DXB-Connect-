# Audit Routes Next.js + Connexions Supabase + iOS Swift

**Date**: 17 février 2026
**Périmètre**: Routes Next.js (pages + API), connexions DB (tables), config iOS/Swift

---

## 📋 Routes Next.js (App Router)

### Pages publiques
| Route | Fichier | Protection |
|-------|---------|------------|
| `/` | `src/app/page.tsx` | ❌ Public (redirect `/dashboard`) |
| `/login` | `src/app/login/page.tsx` | ❌ Public |
| `/register` | `src/app/register/page.tsx` | ❌ Public |
| `/unauthorized` | `src/app/unauthorized/page.tsx` | ❌ Public |

### Pages protégées (dashboard)
| Route | Fichier | Tables accédées | Protection |
|-------|---------|-----------------|------------|
| `/dashboard` | `src/app/(dashboard)/dashboard/page.tsx` | `suppliers`, `customers`, `ad_campaigns` | ✅ Middleware + role admin |
| `/products` | `src/app/(dashboard)/products/page.tsx` | `products`, `suppliers` (join) | ✅ Middleware + role admin |
| `/orders` | `src/app/(dashboard)/orders/page.tsx` | `orders`, `order_items` (nested) | ✅ Middleware + role admin |
| `/customers` | `src/app/(dashboard)/customers/page.tsx` | `customers` | ✅ Middleware + role admin |
| `/suppliers` | `src/app/(dashboard)/suppliers/page.tsx` | `suppliers` | ✅ Middleware + role admin |
| `/ads` | `src/app/(dashboard)/ads/page.tsx` | `ad_campaigns` | ✅ Middleware + role admin |
| `/esim` | `src/app/(dashboard)/esim/page.tsx` | **API externe** (eSIM Access) | ✅ Middleware + role admin |
| `/esim/orders` | `src/app/(dashboard)/esim/orders/page.tsx` | **API externe** (eSIM Access) | ✅ Middleware + role admin |

### API Routes - Authentification
| Endpoint | Fichier | Tables | Auth requise | Notes |
|----------|---------|--------|--------------|-------|
| `POST /api/auth/apple` | `src/app/api/auth/apple/route.ts` | `profiles` (upsert) | ❌ | Crée/update profil après Apple Sign-In |
| `POST /api/auth/email/send-otp` | `src/app/api/auth/email/send-otp/route.ts` | - | ❌ | Envoie OTP via Supabase Auth |
| `POST /api/auth/email/verify` | `src/app/api/auth/email/verify/route.ts` | `profiles` (upsert) | ❌ | Vérifie OTP + crée profil |
| `POST /api/auth/refresh` | `src/app/api/auth/refresh/route.ts` | - | ✅ Bearer | Refresh token Supabase |

### API Routes - eSIM (API externe + persistance locale)
| Endpoint | Fichier | Tables | Auth requise | Source données |
|----------|---------|--------|--------------|----------------|
| `GET /api/esim/packages` | `src/app/api/esim/packages/route.ts` | - | ✅ Cookie SSR | API eSIM Access |
| `GET /api/esim/orders` | `src/app/api/esim/orders/route.ts` | - | ✅ Bearer | API eSIM Access |
| `GET /api/esim/balance` | `src/app/api/esim/balance/route.ts` | - | ✅ Bearer | API eSIM Access |
| `GET /api/esim/query` | `src/app/api/esim/query/route.ts` | `esim_orders` (enrichissement) | ✅ Cookie SSR | API eSIM Access + DB |
| `GET /api/esim/usage` | `src/app/api/esim/usage/route.ts` | - | ✅ Cookie SSR | API eSIM Access |
| `POST /api/esim/purchase` | `src/app/api/esim/purchase/route.ts` | `esim_orders` (insert) | ✅ Cookie SSR | API eSIM Access → DB |
| `GET /api/esim/topup` | `src/app/api/esim/topup/route.ts` | - | ✅ Cookie SSR | API eSIM Access |
| `POST /api/esim/topup` | `src/app/api/esim/topup/route.ts` | `esim_orders` (insert) | ✅ Cookie SSR | API eSIM Access → DB |
| `POST /api/esim/cancel` | `src/app/api/esim/cancel/route.ts` | `esim_orders` (update status) | ✅ Cookie SSR | API eSIM Access → DB |
| `POST /api/esim/suspend` | `src/app/api/esim/suspend/route.ts` | `esim_orders` (update status) | ✅ Cookie SSR | API eSIM Access → DB |
| `POST /api/esim/revoke` | `src/app/api/esim/revoke/route.ts` | `esim_orders` (update status) | ✅ Cookie SSR | API eSIM Access → DB |

### API Routes - Checkout (présent mais non utilisé dans front)
| Endpoint | Fichier | Tables | Auth requise | Notes |
|----------|---------|--------|--------------|-------|
| `POST /api/checkout` | `src/app/api/checkout/route.ts` | `orders`, `order_items` | ❌ | **RISQUE**: prend `user_id` depuis body + service role |
| `POST /api/checkout/confirm` | `src/app/api/checkout/confirm/route.ts` | `orders`, `cart_items` | ❌ | Service role |

### API Routes - Webhooks
| Endpoint | Fichier | Tables | Auth requise | Notes |
|----------|---------|--------|--------------|-------|
| `POST /api/webhooks/stripe` | `src/app/api/webhooks/stripe/route.ts` | `orders`, `cart_items` | ❌ | Vérifie signature Stripe |
| `POST /api/webhooks/esim` | `src/app/api/webhooks/esim/route.ts` | `esim_orders` | ❌ | Service role (pas de vérif signature) |

### API Routes - Admin (très sensibles)
| Endpoint | Fichier | Tables | Auth requise | Notes |
|----------|---------|--------|--------------|-------|
| `POST /api/admin/setup-db` | `src/app/api/admin/setup-db/route.ts` | **DROP + CREATE toutes tables** | ❌ | 🔴 **CRITIQUE**: pas de garde-fou NODE_ENV |
| `POST /api/admin/sync-orders` | `src/app/api/admin/sync-orders/route.ts` | `esim_orders` | ❌ | Service role, user_id hardcodé |
| `POST /api/admin/sync-products` | `src/app/api/admin/sync-products/route.ts` | `products`, `suppliers` | ❌ | Service role, DELETE + INSERT |
| `POST /api/admin/test-purchase` | `src/app/api/admin/test-purchase/route.ts` | `esim_orders` | ❌ | Service role, user_id hardcodé |

### API Routes - Dev/Debug
| Endpoint | Fichier | Tables | Auth requise | Notes |
|----------|---------|--------|--------------|-------|
| `POST /api/dev/seed-users` | `src/app/api/dev/seed-users/route.ts` | `profiles` | ❌ | Limité à `NODE_ENV=development` ✅ |
| `GET /api/debug/auth` | `src/app/api/debug/auth/route.ts` | `profiles` (via RPC) | ✅ Cookie SSR | Debug role utilisateur |

---

## 🗄️ Tables Supabase (accès détaillé)

### Tables e-commerce
| Table | Colonnes clés | FK | Accès depuis | RLS activé |
|-------|---------------|----|--------------|--------------|
| `profiles` | `id` (PK), `email`, `role` | → `auth.users` | Auth routes, middleware RPC | ✅ (policy "ALLOW ALL") |
| `suppliers` | `id` (PK), `name`, `api_status` | - | Pages/hooks, admin sync | ✅ (policy "ALLOW ALL") |
| `customers` | `id` (PK), `email`, `lifetime_value` | ❌ **isolée** | Pages/hooks | ✅ (policy "ALLOW ALL") |
| `products` | `id` (PK), `supplier_id` (FK) | → `suppliers` | Pages/hooks, admin sync | ✅ (policy "ALLOW ALL") |
| `cart_items` | `user_id`, `product_id` (FK) | → `products` | Hooks, webhooks Stripe | ✅ (policy "ALLOW ALL") |
| `orders` | `id` (PK), `user_id`, `payment_intent_id` | → `auth.users` (implicite) | Hooks, checkout, webhooks | ✅ (policy "ALLOW ALL") |
| `order_items` | `order_id` (FK), `product_id` (FK) | → `orders`, `products` | Hooks, checkout | ✅ (policy "ALLOW ALL") |
| `ad_campaigns` | `id` (PK), `budget`, `spent`, `conversions` | - | Pages/hooks | ✅ (policy "ALLOW ALL") |

### Tables eSIM
| Table | Colonnes clés | FK | Accès depuis | RLS activé |
|-------|---------------|----|--------------|--------------|
| `esim_orders` | `id` (PK), `user_id`, `order_no`, `iccid`, `status` | → `auth.users` (implicite) | API eSIM routes, webhooks | ✅ (policy "ALLOW ALL") |

### Fonction RPC
| Fonction | Fichier définition | Usage | Sécurité |
|----------|-------------------|-------|----------|
| `get_user_role(user_id UUID)` | `src/app/api/admin/setup-db/route.ts` (L126) | Middleware protection admin | `SECURITY DEFINER` |

---

## 📱 iOS Swift (DXBCore)

### Configuration API
| Fichier | Environnement | URL | Port | Notes |
|---------|---------------|-----|------|-------|
| `DXBCore/Sources/DXBCore/Config.swift` | `.development` | `http://localhost:4000/api` | 4000 | ✅ Aligné avec Next.js |
| `DXBCore/Sources/DXBCore/Config.swift` | `.production` | `https://your-production-domain.vercel.app/api` | - | ⚠️ URL placeholder |
| `DXBClientApp.swift` (L55) | **Actif en DEBUG** | `.development` | 4000 | ✅ Correct |

### Endpoints iOS appelés
| Endpoint iOS | Route Next.js | Auth | Fichier Swift |
|--------------|---------------|------|---------------|
| `auth/apple` | `POST /api/auth/apple` | ❌ | `DXBCore/.../DXBAPIService.swift` (L33) |
| `auth/email/send-otp` | `POST /api/auth/email/send-otp` | ❌ | `DXBCore/.../DXBAPIService.swift` (L49) |
| `auth/email/verify` | `POST /api/auth/email/verify` | ❌ | `DXBCore/.../DXBAPIService.swift` (L60) |
| `esim/packages` | `GET /api/esim/packages` | ❌ (`requiresAuth: false`) | `DXBCore/.../DXBAPIService.swift` (L81) |
| `esim/orders` | `GET /api/esim/orders` | ✅ Bearer | `DXBCore/.../DXBAPIService.swift` (L111) |
| `esim/purchase` | `POST /api/esim/purchase` | ✅ Bearer | `DXBCore/.../DXBAPIService.swift` (L137) |

### Gestion tokens (iOS)
| Fichier | Fonction | Stockage | Notes |
|---------|----------|----------|-------|
| `DXBCore/.../AuthService.swift` | `saveTokens()`, `getAccessToken()` | Keychain (`com.dxbconnect.app`) | ✅ Sécurisé |
| `DXBCore/.../TokenManager.swift` | `getValidToken()` (refresh auto) | Keychain via AuthService | ⚠️ Refresh non implémenté (L41 TODO) |
| `DXBCore/.../APIClient.swift` | `setAccessToken()`, header `Authorization: Bearer` | Mémoire (actor) | ✅ Correct |

### Problème iOS détecté
- **`fetchPlans()` (L81 DXBAPIService.swift)** : `requiresAuth: false` → ne passe pas le token Bearer
- **Route Next `/api/esim/packages`** : vérifie `supabase.auth.getUser()` (cookie SSR) → **401 pour iOS**
- **Résultat**: iOS ne peut pas charger les packages eSIM actuellement.

---

## 🔗 Connexions Supabase (par couche)

### Browser client (pages/hooks → RLS)
| Fichier | Usage | Tables | Type connexion |
|---------|-------|--------|----------------|
| `src/lib/supabase/client.ts` | Singleton browser | Toutes (via hooks) | `createBrowserClient` (cookies) |
| `src/hooks/useSuppliers.ts` | CRUD suppliers | `suppliers` | Browser + RLS |
| `src/hooks/useCustomers.ts` | CRUD customers | `customers` | Browser + RLS |
| `src/hooks/useProducts.ts` | CRUD products | `products`, `suppliers` (join) | Browser + RLS |
| `src/hooks/useOrders.ts` | CRUD orders | `orders`, `order_items` (nested) | Browser + RLS |
| `src/hooks/useCart.ts` | CRUD cart | `cart_items`, `products`, `suppliers` (join) | Browser + RLS |
| `src/hooks/useCampaigns.ts` | CRUD campaigns | `ad_campaigns` | Browser + RLS |
| `src/hooks/useAuth.ts` | Auth + profile | `profiles` | Browser + RLS |

### Server client (API routes → cookies SSR)
| Fichier | Usage | Tables | Type connexion |
|---------|-------|--------|----------------|
| `src/lib/supabase/server.ts` | Factory server | Toutes (via routes) | `createServerClient` (cookies) |
| `src/app/api/esim/packages/route.ts` | Auth check | - | Server + cookies |
| `src/app/api/esim/purchase/route.ts` | Auth check + insert | `esim_orders` | Server + cookies |
| `src/app/api/esim/query/route.ts` | Auth check + enrichissement | `esim_orders` | Server + cookies |
| `src/app/api/esim/cancel/route.ts` | Auth check + update | `esim_orders` | Server + cookies |
| `src/app/api/esim/suspend/route.ts` | Auth check + update | `esim_orders` | Server + cookies |
| `src/app/api/esim/revoke/route.ts` | Auth check + update | `esim_orders` | Server + cookies |
| `src/app/api/esim/topup/route.ts` | Auth check + insert | `esim_orders` | Server + cookies |

### Service role (admin/webhooks → bypass RLS)
| Fichier | Usage | Tables | Type connexion |
|---------|-------|--------|----------------|
| `src/app/api/admin/setup-db/route.ts` | **DROP + CREATE** | **TOUTES** | `createClient(url, SERVICE_ROLE_KEY)` |
| `src/app/api/admin/sync-orders/route.ts` | Sync eSIM Access → DB | `esim_orders` | Service role |
| `src/app/api/admin/sync-products/route.ts` | Sync eSIM Access → DB | `products`, `suppliers` | Service role |
| `src/app/api/admin/test-purchase/route.ts` | Achat test | `esim_orders` | Service role |
| `src/app/api/checkout/route.ts` | Création order | `orders`, `order_items` | Service role |
| `src/app/api/checkout/confirm/route.ts` | Update order | `orders`, `cart_items` | Service role |
| `src/app/api/webhooks/stripe/route.ts` | Update order | `orders`, `cart_items` | Service role |
| `src/app/api/webhooks/esim/route.ts` | Update esim_orders | `esim_orders` | Service role |
| `src/app/api/dev/seed-users/route.ts` | Création users test | `profiles` | Service role (limité dev ✅) |

### Middleware auth (Bearer iOS)
| Fichier | Usage | Tables | Type connexion |
|---------|-------|--------|----------------|
| `src/lib/auth-middleware.ts` | `requireAuth()` vérifie Bearer | - | Server + `getUser(token)` |
| `src/app/api/esim/balance/route.ts` | Utilise `requireAuth` | - | Server + Bearer |
| `src/app/api/esim/orders/route.ts` | Utilise `requireAuth` | - | Server + Bearer |

---

## 🚨 Problèmes identifiés (priorité décroissante)

### 🔴 CRITIQUE - Sécurité

#### 1. Route `setup-db` non protégée
**Fichier**: `src/app/api/admin/setup-db/route.ts`
**Problème**: Contient `DROP TABLE ... CASCADE` + `CREATE TABLE` + policies `USING (true)` (open bar)
**Risque**: Si exposé en prod, peut **détruire toute la DB**
**Solution**:
```typescript
// Ligne 5 - Ajouter garde-fou
export async function POST() {
  if (process.env.NODE_ENV !== 'development') {
    return NextResponse.json({ error: 'Not available in production' }, { status: 403 })
  }
  // ... reste du code
}
```

#### 2. Routes checkout sans vérification identité
**Fichiers**: `src/app/api/checkout/route.ts`, `.../confirm/route.ts`
**Problème**: Prennent `user_id` depuis le body + utilisent service role → spoofing possible
**Risque**: Un attaquant peut créer des commandes pour n'importe quel user
**Solution**: Vérifier l'auth et extraire `user_id` depuis le token, pas depuis le body

#### 3. Webhook eSIM sans signature
**Fichier**: `src/app/api/webhooks/esim/route.ts`
**Problème**: Pas de vérification de signature (contrairement à Stripe)
**Risque**: N'importe qui peut envoyer des faux webhooks et modifier les statuts eSIM
**Solution**: Ajouter un secret partagé ou vérifier l'IP source

### 🟡 MAJEUR - Incohérences auth

#### 4. Endpoints eSIM: mix Bearer/Cookie incompatible iOS
**Fichiers**: `src/app/api/esim/packages/route.ts`, `.../purchase/route.ts`, `.../query/route.ts`, etc.
**Problème**:
- Routes utilisent `createClient().auth.getUser()` (cookies SSR)
- iOS envoie `Authorization: Bearer <token>` (pas de cookies)
- Résultat: **iOS reçoit 401** sur ces routes
**Solution**: Unifier avec `requireAuth()` (Bearer) ou supporter les deux (cookie OU Bearer)

#### 5. Hooks web sans header Authorization
**Fichiers**: `src/hooks/useEsimAccess.ts`, `src/hooks/useEsimOrders.ts`
**Problème**:
- `fetch('/api/esim/orders')` sans header `Authorization`
- Routes attendent Bearer (`requireAuth`)
- Résultat: **Web reçoit 401** aussi
**Solution**: Ajouter le token dans les headers fetch (via `useAuth`)

#### 6. Mismatch shape réponse API
**Fichier**: `src/hooks/useEsimAccess.ts` (L103)
**Problème**: Hook attend `obj.orderList`, route renvoie `obj.esimList`
**Impact**: Parsing échoue, liste vide côté front
**Solution**: Aligner les noms (ou adapter le hook)

### 🟢 MINEUR - Optimisations

#### 7. Table `customers` isolée
**Fichier**: `src/app/api/admin/setup-db/route.ts` (L50)
**Problème**: Pas de FK vers `profiles` ou `orders`
**Impact**: Impossible de lier un client à ses commandes
**Solution**: Ajouter `profile_id UUID REFERENCES profiles(id)` ou fusionner avec `profiles`

#### 8. FK implicites non contraintes
**Tables**: `orders.user_id`, `cart_items.user_id`, `esim_orders.user_id`
**Problème**: Pas de `FOREIGN KEY ... REFERENCES auth.users(id)` explicite
**Impact**: Pas de cascade DELETE, risque de données orphelines
**Solution**: Ajouter les contraintes FK explicites

#### 9. Policies RLS trop permissives
**Fichier**: `src/app/api/admin/setup-db/route.ts` (L16, L30, L46, etc.)
**Problème**: Toutes les policies sont `USING (true)` → accès total pour tous
**Impact**: N'importe quel utilisateur peut lire/modifier toutes les données
**Solution**: Remplacer par des policies restrictives (ex: `USING (auth.uid() = user_id)`)

---

## 📊 Mapping "Route → Tables" (synthèse)

### Pages Web (client-side, RLS requis)
```
/dashboard          → suppliers, customers, ad_campaigns
/products           → products + suppliers (join)
/orders             → orders + order_items (nested)
/customers          → customers
/suppliers          → suppliers
/ads                → ad_campaigns
/esim               → API externe (eSIM Access)
/esim/orders        → API externe (eSIM Access)
```

### API eSIM (server-side, auth Bearer/Cookie)
```
GET  /api/esim/packages   → API externe (eSIM Access)
GET  /api/esim/orders     → API externe (eSIM Access)
GET  /api/esim/balance    → API externe (eSIM Access)
POST /api/esim/purchase   → API externe → esim_orders (insert)
GET  /api/esim/query      → API externe + esim_orders (enrichissement)
GET  /api/esim/usage      → API externe (eSIM Access)
POST /api/esim/topup      → API externe → esim_orders (insert)
POST /api/esim/cancel     → API externe → esim_orders (update)
POST /api/esim/suspend    → API externe → esim_orders (update)
POST /api/esim/revoke     → API externe → esim_orders (update)
```

### API Auth (server-side, pas d'auth requise)
```
POST /api/auth/apple           → profiles (upsert)
POST /api/auth/email/send-otp  → Supabase Auth (pas de table)
POST /api/auth/email/verify    → profiles (upsert)
POST /api/auth/refresh         → Supabase Auth (pas de table)
```

### API Admin (service role, TRÈS SENSIBLE)
```
POST /api/admin/setup-db        → DROP + CREATE toutes tables (🔴 CRITIQUE)
POST /api/admin/sync-orders     → esim_orders (insert bulk)
POST /api/admin/sync-products   → products, suppliers (delete + insert)
POST /api/admin/test-purchase   → esim_orders (insert test)
```

### Webhooks (service role, vérification signature variable)
```
POST /api/webhooks/stripe  → orders, cart_items (signature ✅)
POST /api/webhooks/esim    → esim_orders (signature ❌)
```

---

## 🔍 Résultat audit terminal (`ios-backend-audit.sh`)

```bash
Tests endpoints API:
✗ GET /api/esim/packages  → 401 (attendu: 200) ← PROBLÈME
✓ GET /api/esim/balance   → 401 (attendu: 401) ← OK
✓ GET /api/esim/orders    → 401 (attendu: 401) ← OK
✓ POST /api/auth/email/send-otp → 200 ← OK

Connexion Supabase:
✓ URL accessible
✓ Tables: users, esim_orders, products
✗ Table campaigns (404) ← Normal, c'est ad_campaigns

API eSIM Access:
✗ Endpoint test 404 ← Script utilise mauvais endpoint
```

**Conclusion script**: Le backend Next.js tourne (port 4000), Supabase connecté, mais `/api/esim/packages` renvoie 401 au lieu de 200 → confirme le problème d'auth.

---

## ✅ Points positifs

### Architecture
- ✅ Séparation claire iOS (Swift) / Web (Next.js) / Backend (Supabase)
- ✅ Middleware Next.js protège les pages (redirect `/login` si non auth)
- ✅ Middleware vérifie le rôle admin via RPC `get_user_role`
- ✅ iOS utilise Keychain (sécurisé) pour les tokens
- ✅ iOS envoie `Authorization: Bearer` correctement
- ✅ Hooks web utilisent React Query (cache, invalidation)
- ✅ Types TypeScript générés depuis Supabase (`database.types.ts`)

### Sécurité partielle
- ✅ Webhook Stripe vérifie la signature
- ✅ Route `/api/dev/seed-users` limitée à `NODE_ENV=development`
- ✅ Tokens stockés dans Keychain iOS (pas en clair)
- ✅ Headers sécurité configurés (`next.config.js`)

---

## 🛠️ Recommandations (par priorité)

### Priorité 1 - Sécurité critique (à faire immédiatement)

1. **Protéger `setup-db`**
   ```typescript
   // src/app/api/admin/setup-db/route.ts ligne 134
   export async function POST() {
     if (process.env.NODE_ENV !== 'development') {
       return NextResponse.json({ error: 'Not available in production' }, { status: 403 })
     }
     // ... reste
   }
   ```

2. **Sécuriser `/api/checkout`**
   - Remplacer `body.user_id` par `user.id` extrait du token
   - Ajouter `requireAuth()` ou vérifier cookie SSR

3. **Ajouter signature webhook eSIM**
   - Ou restreindre par IP source (whitelist eSIM Access)

### Priorité 2 - Unifier auth iOS/Web

4. **Supporter Bearer ET Cookie dans routes eSIM**
   ```typescript
   // Créer helper dans src/lib/auth-middleware.ts
   export async function requireAuthFlexible(request: Request) {
     // Essayer Bearer d'abord (iOS)
     const bearer = request.headers.get('Authorization')
     if (bearer?.startsWith('Bearer ')) {
       return requireAuth(request)
     }
     // Sinon, essayer cookie SSR (Web)
     const supabase = await createClient()
     const { data: { user }, error } = await supabase.auth.getUser()
     if (error || !user) {
       return { error: NextResponse.json({ error: 'Unauthorized' }, { status: 401 }), user: null }
     }
     return { error: null, user }
   }
   ```

5. **Ajouter token dans hooks web**
   ```typescript
   // src/hooks/useEsimAccess.ts
   async function fetchPackagesRaw() {
     const { session } = await supabase.auth.getSession()
     const response = await fetch('/api/esim/packages', {
       headers: { 'Authorization': `Bearer ${session?.access_token}` }
     })
     // ...
   }
   ```

6. **Fixer mismatch shape API**
   ```typescript
   // src/hooks/useEsimAccess.ts ligne 103
   // Changer orderList → esimList
   return (data.obj?.esimList || []).map(...)
   ```

### Priorité 3 - Données & relations

7. **Ajouter FK explicites**
   ```sql
   ALTER TABLE orders ADD CONSTRAINT fk_orders_user
     FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
   ALTER TABLE cart_items ADD CONSTRAINT fk_cart_items_user
     FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
   ALTER TABLE esim_orders ADD CONSTRAINT fk_esim_orders_user
     FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
   ```

8. **Lier table `customers`**
   ```sql
   ALTER TABLE customers ADD COLUMN profile_id UUID REFERENCES profiles(id);
   ```

9. **Remplacer policies RLS permissives**
   ```sql
   -- Exemple pour esim_orders
   DROP POLICY IF EXISTS "Allow all esim_orders" ON esim_orders;
   CREATE POLICY "Users can view own esim_orders" ON esim_orders
     FOR SELECT USING (auth.uid() = user_id);
   CREATE POLICY "Users can insert own esim_orders" ON esim_orders
     FOR INSERT WITH CHECK (auth.uid() = user_id);
   ```

### Priorité 4 - iOS (fonctionnalités)

10. **Implémenter refresh token iOS**
    ```swift
    // DXBCore/.../TokenManager.swift ligne 36
    private func refreshToken() async throws -> String? {
      guard let refreshToken = try await authService.getRefreshToken() else {
        throw TokenError.noRefreshToken
      }

      let url = APIConfig.baseURL.appendingPathComponent("auth/refresh")
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONSerialization.data(withJSONObject: ["refreshToken": refreshToken])

      let (data, _) = try await URLSession.shared.data(for: request)
      let response = try JSONDecoder().decode(RefreshResponse.self, from: data)

      try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
      return response.accessToken
    }
    ```

---

## 📈 Métriques audit

| Catégorie | Score | Détails |
|-----------|-------|---------|
| **Architecture** | 85% | Séparation claire, patterns modernes |
| **Sécurité** | 40% | Routes admin exposées, RLS permissif, checkout non sécurisé |
| **Auth iOS/Web** | 50% | Mix Bearer/Cookie non géré, hooks sans token |
| **Relations DB** | 60% | FK implicites, table customers isolée |
| **Documentation** | 70% | README à jour, mais scripts partiellement obsolètes |

**Score global**: **61%** (à améliorer avant prod)

---

## 🎯 Checklist avant mise en production

- [ ] Protéger `setup-db` avec `NODE_ENV !== 'development'`
- [ ] Sécuriser `/api/checkout` (vérifier identité)
- [ ] Ajouter signature webhook eSIM
- [ ] Unifier auth Bearer/Cookie dans routes eSIM
- [ ] Ajouter token dans hooks web (`useEsimAccess`, `useEsimOrders`)
- [ ] Fixer mismatch `orderList` → `esimList`
- [ ] Ajouter FK explicites (`orders`, `cart_items`, `esim_orders`)
- [ ] Remplacer policies RLS `USING (true)` par policies restrictives
- [ ] Implémenter refresh token iOS
- [ ] Tester flux complet iOS (auth → packages → purchase)
- [ ] Tester flux complet Web (login → dashboard → esim)
- [ ] Supprimer ou documenter tables DLD (non utilisées)

---

**Audit réalisé le**: 17 février 2026
**Outils utilisés**: Lecture code source, script `ios-backend-audit.sh`, grep/glob
**Prochaine révision**: Après corrections priorité 1-2
