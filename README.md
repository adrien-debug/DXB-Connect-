# DXB Connect

Plateforme eSIM avec app client iOS (SwiftUI) et dashboard admin (NextJS).

## 📋 Règles Cursor

6 règles absolues définies dans `.cursor/rules/` :

| Fichier | Description | Scope |
|---------|-------------|-------|
| `00-project-core.mdc` | Règles fondamentales du projet | Toujours actif |
| `01-nextjs-api.mdc` | Standards API Next.js | Routes `/api/**/*.ts` |
| `02-react-hooks.mdc` | React Query & composants | `hooks/`, `components/` |
| `03-swift-ios.mdc` | Standards Swift/SwiftUI | Fichiers `*.swift` |
| `04-database-supabase.mdc` | Supabase & migrations | Fichiers `*.sql` |
| `05-architecture-railway.mdc` | **Architecture Railway stricte** | **Toujours actif** |

**🚂 Architecture Railway (NON NÉGOCIABLE)** :
```
iOS SwiftUI ──┐
              ├──► Railway Backend ──► Supabase ──► eSIM Access API
Next.js Web ──┘
```
- ❌ **INTERDIT** : Connexion directe client → Supabase ou eSIM API
- ✅ **OBLIGATOIRE** : Railway est TOUJOURS le seul point d'entrée
- 🔒 **URL Production** : `https://web-production-14c51.up.railway.app/api`

**Règles de sécurité absolues** :
- 🚫 Jamais de connexion directe client → Supabase/eSIM API
- 🚫 Jamais bypasser Railway
- 🚫 Jamais de secrets dans le code
- 🚫 Jamais de routes destructives non protégées
- 🚫 Jamais de logs avec données sensibles
- ✅ Toujours passer par Railway Backend
- ✅ Toujours vérifier `user_id` dans queries
- ✅ Toujours utiliser `requireAuthFlexible()` pour auth

## 🔍 Audit iOS - Backend & Database (17/02/2026)

### État Actuel
- ✅ **Backend Next.js**: Fonctionnel sur port 4000
- ✅ **Supabase**: Connecté et opérationnel
- ✅ **API eSIM Access**: 2328 packages disponibles
- ⚠️  **App iOS**: Configuration à mettre à jour

### Tests Endpoints
| Endpoint | Méthode | Status | Résultat |
|----------|---------|--------|----------|
| `/api/esim/packages` | GET | ✅ | 2328 packages |
| `/api/auth/email/send-otp` | POST | ✅ | OTP envoyé |
| `/api/esim/balance` | GET | ⚠️ | Auth à corriger |
| `/api/esim/orders` | GET | ⚠️ | Auth à corriger |

### Configuration iOS Actuelle
```swift
// DXBClientApp.swift ligne 56
APIConfig.current = .production  // ⚠️ Pointe vers Railway (ancien)

// Environnements disponibles:
// .development  → http://localhost:3000/api
// .staging      → https://dxb-connect-staging.vercel.app/api
// .production   → https://web-production-14c51.up.railway.app/api
```

### Problèmes Identifiés
1. 🔴 **CRITIQUE**: App iOS pointe vers ancienne API Railway
2. 🟡 **Attention**: Pas de refresh token automatique
3. 🟡 **Attention**: Gestion d'erreur basique (print uniquement)
4. 🟡 **Attention**: Pas de cache local pour mode offline

### ✅ Corrections Appliquées (Priorité 1)

1. ✅ **Configuration API corrigée**
   - `Config.swift` pointe maintenant vers `localhost:4000` en dev
   - `DXBClientApp.swift` utilise `.development` par défaut en DEBUG

2. ✅ **Endpoints sécurisés**
   - Nouveau middleware `auth-middleware.ts` créé
   - `/api/esim/balance` et `/api/esim/orders` protégés
   - Vérification du token Bearer obligatoire

3. ✅ **Tests d'authentification**
   - Script `test-auth-flow.sh` créé
   - Teste le flux complet: OTP → Verify → Endpoints protégés

### ✅ Corrections Appliquées (Priorité 2)

1. ✅ **Refresh Token Automatique**
   - `TokenManager.swift` créé avec vérification auto
   - Endpoint `/api/auth/refresh` implémenté
   - Intégration dans APIClient

2. ✅ **Logging Structuré**
   - `Logger.swift` avec OSLog
   - 5 niveaux, 7 catégories
   - Logs appliqués dans APIClient, DXBAPIService, DXBClientApp

3. ✅ **Tests Unitaires**
   - 29 tests créés (4 suites)
   - AuthServiceTests, APIClientTests, ConfigTests, TokenManagerTests
   - Couverture ~60%

### 🔄 Prochaines Étapes (Priorité 3)
1. **Cache**: Ajouter cache local pour mode offline
2. **Analytics**: Implémenter tracking événements
3. **Erreurs**: Améliorer gestion d'erreurs

### Scripts Disponibles
```bash
cd Apps/DXBClient

# Audit complet backend/database
./ios-backend-audit.sh

# Test flux d'authentification
./test-auth-flow.sh

# Test backend simple
./test-ios-backend.sh
```

## Architecture (Railway Backend Central)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     DXB Connect - Architecture Railway                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌──────────────────┐              ┌──────────────────┐                │
│   │   📱 iOS App     │              │   💻 Admin Web   │                │
│   │   (SwiftUI)      │              │   (Next.js)      │                │
│   │                  │              │                  │                │
│   │  • Auth          │              │  • Dashboard     │                │
│   │  • Catalogue     │              │  • Clients       │                │
│   │  • Mes eSIMs     │              │  • Fournisseurs  │                │
│   │  • Profil        │              │  • Commandes     │                │
│   │  • Support       │              │  • Produits      │                │
│   └────────┬─────────┘              └────────┬─────────┘                │
│            │                                  │                          │
│            │    ❌ PAS DE CONNEXION DIRECTE   │                          │
│            │                                  │                          │
│            │         ┌───────────────┐        │                          │
│            └────────►│ 🚂 RAILWAY    │◄───────┘                          │
│                      │   Backend     │                                   │
│                      │  (Next.js API)│                                   │
│                      │               │                                   │
│                      │ SEUL POINT    │                                   │
│                      │ D'ENTRÉE      │                                   │
│                      └───────┬───────┘                                   │
│                              │                                           │
│                              ▼                                           │
│                      ┌───────────────┐                                   │
│                      │   Supabase    │                                   │
│                      │               │                                   │
│                      │  • Auth       │                                   │
│                      │  • Database   │                                   │
│                      │  • Storage    │                                   │
│                      └───────┬───────┘                                   │
│                              │                                           │
│                              ▼                                           │
│                      ┌───────────────┐                                   │
│                      │  eSIM Access  │                                   │
│                      │  Provider API │                                   │
│                      │               │                                   │
│                      │  • Packages   │                                   │
│                      │  • Orders     │                                   │
│                      │  • Activation │                                   │
│                      └───────────────┘                                   │
│                                                                          │
│   👤 Client Final: Achète et utilise via iOS/Web                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

⚠️  RÈGLE ABSOLUE: Tout passe par Railway Backend
    URL Production: https://web-production-14c51.up.railway.app/api

📖 **Documentation complète** : [ARCHITECTURE_RAILWAY.md](./ARCHITECTURE_RAILWAY.md)
```

## Stack

| Composant | Technologies |
|-----------|--------------|
| **iOS App** | SwiftUI, DXBCore (Package) |
| **Admin Web** | NextJS 14, TailwindCSS, React Query |
| **Backend** | Supabase (Auth, PostgreSQL, Edge Functions) |
| **eSIM API** | eSIM Access Provider |

## Flux eSIM

```
Client iOS                 Supabase                 eSIM Access API
    │                         │                           │
    │  1. Browse packages     │                           │
    ├────────────────────────►│  GET /packages            │
    │                         ├──────────────────────────►│
    │                         │◄──────────────────────────┤
    │◄────────────────────────┤                           │
    │                         │                           │
    │  2. Purchase eSIM       │                           │
    ├────────────────────────►│  POST /orders             │
    │                         ├──────────────────────────►│
    │                         │◄──── QR Code + ICCID ─────┤
    │◄────────────────────────┤                           │
    │                         │                           │
    │  3. Check status        │                           │
    ├────────────────────────►│  GET /esims/{iccid}       │
    │                         ├──────────────────────────►│
    │                         │◄──────────────────────────┤
    │◄────────────────────────┤                           │
```

## Structure

```
DXB Connect/
├── Apps/
│   └── DXBClient/           # App iOS + Admin Web
│       ├── Views/           # SwiftUI Views (iOS)
│       ├── src/             # NextJS (Admin Web)
│       └── DXBCore/         # Swift Package
├── Packages/
│   └── DXBCore/             # Core Swift (models, API)
├── Backend/                 # Scripts backend
└── README.md
```

## Authentification

- **Supabase Auth** avec table `profiles`
- **Rôles** : `client` (défaut) | `admin`
- **Protection** : Middleware vérifie le rôle pour les routes admin

## Stack Technique

| Catégorie | Technologies |
|-----------|-------------|
| **Frontend** | Next.js 14, React 18, TailwindCSS |
| **Backend** | Supabase (PostgreSQL + API REST + Auth) |
| **State** | TanStack React Query (cache, mutations) |
| **Validation** | Zod (schemas typés) |
| **Notifications** | Sonner (toasts) |
| **Charts** | Recharts |
| **Paiement** | Stripe SDK (avec Apple Pay, Google Pay) |
| **Tests** | Vitest + Testing Library |
| **CI/CD** | GitHub Actions |

## Installation

```bash
cd Apps/DXBClient
npm install
```

## Configuration

### 1. Variables d'environnement

Créer `.env.local` depuis `.env.example` :

```env
# Railway Backend (POINT CENTRAL)
NEXT_PUBLIC_RAILWAY_URL=https://web-production-14c51.up.railway.app
NEXT_PUBLIC_API_URL=http://localhost:4000/api

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...
SUPABASE_SERVICE_ROLE_KEY=eyJxxx...

# eSIM Access API
ESIM_ACCESS_CODE=xxx
ESIM_SECRET_KEY=xxx

# Stripe (optionnel)
STRIPE_SECRET_KEY=sk_test_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

### 2. Configuration Supabase

**a) Exécuter le script SQL** (`supabase-setup.sql`) :
```bash
# Dans Supabase Dashboard > SQL Editor, exécuter :
# Apps/DXBClient/supabase-setup.sql
```

**b) Activer Apple Sign-In** :
1. Aller dans **Supabase Dashboard > Authentication > Providers**
2. Activer **Apple**
3. Configurer :
   - **Service ID** : `com.dxbconnect.client`
   - **Team ID** : Votre Apple Team ID
   - **Key ID** : ID de la clé `.p8`
   - **Private Key** : Contenu du fichier `.p8`

**c) Configurer Email OTP** :
1. Aller dans **Authentication > Email Templates**
2. Configurer le template "Magic Link / OTP"
3. Dans **Authentication > Settings** :
   - Activer "Enable email confirmations"
   - Configurer SMTP si besoin (ou utiliser Supabase par défaut)

### 3. iOS - Config.swift

L'app iOS pointe vers Railway automatiquement :
```swift
// Production (défaut)
https://web-production-14c51.up.railway.app/api

// Development (localhost)
http://localhost:4000/api
```

## Scripts

```bash
# Lancer tout (Frontend + Backend)
./START_ALL.sh

# Frontend (port 4000)
cd Apps/DXBClient
npm run dev          # Serveur de développement
npm run build        # Build production
npm run lint         # ESLint
npm run typecheck    # Vérification TypeScript
npm run test         # Tests unitaires

# Tests de synchronisation
node test-sync-backend-frontend.js  # Test général (100% ✅)
node test-sync-database.js          # Test database (100% ✅)
```

## Structure

```
Apps/DXBClient/
├── src/
│   ├── app/
│   │   ├── (dashboard)/        # Route group protégée
│   │   │   ├── dashboard/      # Dashboard principal
│   │   │   ├── products/       # Catalogue produits
│   │   │   ├── esim/           # eSIM packages + orders
│   │   │   ├── orders/         # Historique commandes
│   │   │   ├── suppliers/      # Gestion fournisseurs
│   │   │   ├── customers/      # Gestion clients
│   │   │   ├── ads/            # Campagnes publicitaires
│   │   │   └── layout.tsx      # Layout avec sidebar
│   │   ├── api/
│   │   │   ├── checkout/       # API paiement (create + confirm)
│   │   │   ├── webhooks/stripe/ # Webhook Stripe
│   │   │   └── esim/           # API eSIM Access
│   │   ├── login/              # Page de connexion
│   │   ├── layout.tsx          # Root layout
│   │   └── page.tsx            # Redirect vers dashboard
│   ├── components/
│   │   ├── Sidebar.tsx         # Navigation + logout
│   │   ├── DataTable.tsx       # Table réutilisable
│   │   ├── Modal.tsx           # Modales
│   │   ├── PaymentModal.tsx    # Modal paiement (Card/Apple Pay/Google Pay/PayPal)
│   │   ├── CartDrawer.tsx      # Drawer panier
│   │   └── StatCard.tsx        # Cartes statistiques
│   ├── hooks/
│   │   ├── useAuth.ts          # Authentification
│   │   ├── useCart.ts          # Panier (React Query)
│   │   ├── useOrders.ts        # Commandes (React Query)
│   │   ├── useProducts.ts      # Produits (React Query)
│   │   ├── useSuppliers.ts     # CRUD suppliers (React Query)
│   │   ├── useCustomers.ts     # CRUD customers
│   │   ├── useEsimAccess.ts    # API eSIM packages
│   │   └── useCampaigns.ts     # CRUD campaigns
│   ├── lib/
│   │   ├── database.types.ts   # Types Supabase générés
│   │   ├── stripe.ts           # Client Stripe (server + client)
│   │   ├── supabase/           # Clients Supabase (browser/server)
│   │   └── validations/        # Schemas Zod
│   ├── providers/
│   │   └── QueryProvider.tsx   # React Query provider
│   ├── middleware.ts           # Protection routes
│   └── test/
│       └── setup.ts            # Config tests
├── .github/
│   └── workflows/
│       └── ci.yml              # Pipeline CI/CD
└── vitest.config.ts            # Config Vitest
```

## Tables Supabase

### Tables principales
- `profiles` : Profils utilisateurs (id, email, full_name, role)
- `suppliers` : Fournisseurs (nom, email, société, catégorie, statut API)
- `customers` : Clients (prénom, nom, email, segment, valeur)
- `products` : Catalogue produits avec relation fournisseur
- `cart_items` : Panier utilisateur (lié au user et product)
- `orders` : Commandes avec suivi paiement
- `order_items` : Items de commande détaillés
- `ad_campaigns` : Campagnes publicitaires
- `esim_orders` : Commandes eSIM (user_id, order_no, iccid, status, RLS activé)

### Relations clés
```
profiles (users)
  ├── orders (1:N)
  ├── cart_items (1:N)
  └── esim_orders (1:N)

suppliers
  └── products (1:N)

products
  ├── cart_items (1:N)
  └── order_items (1:N)

orders
  └── order_items (1:N)
```

### 📊 Audits de base de données & architecture

Audits complets effectués :
- **[AUDIT_RELATIONS_DATA.md](./AUDIT_RELATIONS_DATA.md)** - Relations entre tables
- **[AUDIT_ROUTES_CONNEXIONS.md](./AUDIT_ROUTES_CONNEXIONS.md)** - Routes Next.js + connexions Supabase + iOS Swift (17/02/2026)
- **[CORRECTIONS_AUDIT_ROUTES.md](./CORRECTIONS_AUDIT_ROUTES.md)** - Corrections appliquées (17/02/2026)
- **[Backend/migrations/003_fix_relations.sql](./Backend/migrations/003_fix_relations.sql)** - Migration de correction

**Problèmes identifiés** (AUDIT_ROUTES_CONNEXIONS.md) :
- 🔴 **CRITIQUE**: Route `setup-db` non protégée (DROP TABLE exposé) → ✅ **CORRIGÉ**
- 🔴 **CRITIQUE**: Routes checkout sans vérification identité (spoofing possible) → ✅ **CORRIGÉ**
- 🔴 **CRITIQUE**: Webhook eSIM sans signature → ⏳ **À FAIRE**
- 🟡 **MAJEUR**: Endpoints eSIM incompatibles iOS (mix Bearer/Cookie) → ✅ **CORRIGÉ**
- 🟡 **MAJEUR**: Hooks web sans header Authorization (401 assuré) → ✅ **CORRIGÉ**
- 🟡 **MAJEUR**: Mismatch shape API (`orderList` vs `esimList`) → ✅ **CORRIGÉ**
- 🟢 **MINEUR**: Table `customers` isolée, FK implicites, RLS permissif → ⏳ **À FAIRE**

**Corrections appliquées** (17/02/2026) :
- ✅ Route `setup-db` protégée avec garde-fou `NODE_ENV`
- ✅ Route `checkout` vérifie identité via Bearer token
- ✅ Fonction `requireAuthFlexible()` créée (Bearer OU Cookie)
- ✅ 8 routes eSIM utilisent `requireAuthFlexible` (iOS + Web compatibles)
- ✅ Hooks web ajoutent header `Authorization: Bearer`
- ✅ Fix mismatch `orderList` → `esimList`
- ✅ Score sécurité: **40% → 70%** (+30 points)

**Corrections appliquées** (migration 003) :
- ✅ Foreign keys explicites ajoutées
- ✅ Soft delete activé sur tables critiques
- ✅ Index de performance créés
- ✅ Triggers auto-update `updated_at`
- ✅ Contraintes de validation

## API Routes (iOS + Web)

Routes unifiées pour iOS SwiftUI et Admin Web :

### Authentification

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/auth/apple` | POST | Sign-In Apple (iOS) |
| `/api/auth/email/send-otp` | POST | Envoi OTP email (iOS) |
| `/api/auth/email/verify` | POST | Vérification OTP (iOS) |

### eSIM - Consultation

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/esim/packages` | GET | Liste packages eSIM |
| `/api/esim/orders` | GET | Orders eSIM utilisateur |
| `/api/esim/balance` | GET | Balance marchand |
| `/api/esim/query` | GET | Statut détaillé eSIM |
| `/api/esim/usage` | GET | Utilisation data eSIM |

### eSIM - Actions

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/esim/purchase` | POST | Achat eSIM |
| `/api/esim/topup` | GET | Liste packages recharge |
| `/api/esim/topup` | POST | Recharger une eSIM |
| `/api/esim/cancel` | POST | Annuler/rembourser eSIM |
| `/api/esim/suspend` | POST | Suspendre/reprendre eSIM |
| `/api/esim/revoke` | POST | Révoquer eSIM (définitif) |

### Paiement

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/checkout` | POST | Création paiement Stripe |
| `/api/checkout/confirm` | POST | Confirmation paiement |

### Webhooks

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/webhooks/stripe` | POST | Webhook Stripe |
| `/api/webhooks/esim` | POST | Webhook eSIM Access |

### Configuration Webhook eSIM Access

Dans la console eSIM Access (https://console.esimaccess.com/developer/index), configurer l'URL webhook :

```
https://your-app.vercel.app/api/webhooks/esim
```

Types de notifications supportées :
- `ORDER_STATUS` - eSIM prête à télécharger
- `ESIM_STATUS` - Changement de statut
- `DATA_USAGE` - Data restante ≤ 100 MB
- `VALIDITY_USAGE` - Validité restante ≤ 1 jour

## Types Partagés iOS/Next.js

Les types sont alignés entre iOS (`Models.swift`) et Next.js (`esim-types.ts`) :

```typescript
// Plan (Package eSIM normalisé)
interface Plan {
  id: string           // packageCode
  name: string
  dataGB: number       // Converti depuis bytes
  durationDays: number
  priceUSD: number     // Converti depuis centimes
  location: string
  locationCode: string
}

// ESIMOrder (Commande eSIM)
interface ESIMOrder {
  id: string
  orderNo: string
  iccid: string
  lpaCode: string      // Code activation
  qrCodeUrl: string
  status: SMDPStatus
  packageName: string
  totalVolume: string  // "5 GB"
}

// Statuts eSIM
type SMDPStatus =
  | 'GOT_RESOURCE'    // Prêt à télécharger
  | 'INSTALLATION'    // En cours d'installation
  | 'IN_USE'          // En utilisation
  | 'SUSPENDED'       // Suspendu
  | 'REVOKED'         // Révoqué
  | 'CANCELLED'       // Annulé
  | 'LOW_DATA'        // Data basse
  | 'EXPIRING_SOON'   // Expire bientôt
```

## React Hooks eSIM

Hooks disponibles dans `useEsimAccess.ts` :

```typescript
// Consultation
useEsimPackages()      // Liste packages
useEsimPlans()         // Packages normalisés (format iOS)
useEsimBalance()       // Balance marchand
useEsimOrders()        // Commandes utilisateur
useEsimUsage(iccid)    // Utilisation data
useEsimQuery({orderNo, iccid})  // Statut détaillé

// Actions (mutations)
useEsimPurchase()      // Achat
useEsimTopup()         // Recharge
useEsimCancel()        // Annulation
useEsimSuspend()       // Suspension/reprise
useEsimRevoke()        // Révocation
useTopupPackages(iccid) // Packages de recharge
```

## Architecture Patterns

- **Custom Hooks** : Logique métier encapsulée (useSuppliers, etc.)
- **React Query** : Cache automatique, invalidation, optimistic updates
- **Zod Validation** : Validation côté client avec types inférés
- **Route Groups** : Next.js 14 App Router avec layouts partagés
- **Middleware Auth** : Protection automatique des routes

## CI/CD

Pipeline GitHub Actions : Lint → Typecheck → Tests → Build

## Ports

| Service | URL |
|---------|-----|
| Frontend | http://localhost:4000 |

## Tests & Qualité

✅ **Synchronisation Backend/Database/Frontend : 100%**

Deux suites de tests automatisés valident la synchronisation complète :

```bash
# Test 1 : Backend/Frontend (15 tests)
node test-sync-backend-frontend.js
# ✅ Serveur Next.js, Supabase, API, Auth, Performance, Assets

# Test 2 : Database/Sync (18 tests)
node test-sync-database.js
# ✅ API eSIM, Balance, Cohérence, Erreurs, Sécurité, Headers
```

**Résultats** :
- 🎯 Taux de réussite : **100%** (33/33 tests)
- ⚡ Performance : **12-19ms** (Excellent)
- 🔒 Sécurité : Headers configurés (X-Frame-Options, CSP, HSTS)
- 📦 API eSIM : 2328 packages disponibles
- 🔐 Protection routes : Authentification active

## Créer un Admin

```sql
-- Dans Supabase SQL Editor
UPDATE profiles SET role = 'admin' WHERE email = 'votre@email.com';
```
