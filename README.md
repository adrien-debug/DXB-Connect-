# DXB Connect

Plateforme eSIM avec app client iOS (SwiftUI) et dashboard admin (NextJS).

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            DXB Connect                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌──────────────────┐              ┌──────────────────┐                │
│   │   📱 iOS App     │              │   💻 Admin Web   │                │
│   │   (SwiftUI)      │              │   (NextJS)       │                │
│   │                  │              │                  │                │
│   │  • Auth          │              │  • Dashboard     │                │
│   │  • Catalogue     │              │  • Clients       │                │
│   │  • Mes eSIMs     │              │  • Fournisseurs  │                │
│   │  • Profil        │              │  • Commandes     │                │
│   │  • Support       │              │  • Produits      │                │
│   └────────┬─────────┘              └────────┬─────────┘                │
│            │                                  │                          │
│            │         ┌───────────────┐        │                          │
│            └────────►│   Supabase    │◄───────┘                          │
│                      │               │                                   │
│                      │  • Auth       │                                   │
│                      │  • Database   │                                   │
│                      │  • Storage    │                                   │
│                      │  • Edge Func  │                                   │
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
└─────────────────────────────────────────────────────────────────────────┘
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

Fichier `.env.local` :

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx

# eSIM Access API (https://docs.esimaccess.com/)
ESIM_ACCESS_CODE=xxx
ESIM_SECRET_KEY=xxx

# API URL pour iOS (production)
NEXT_PUBLIC_API_URL=https://your-app.vercel.app

# Stripe (optionnel - mode simulation si absent)
STRIPE_SECRET_KEY=sk_live_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

## Scripts

```bash
# Lancer tout (Frontend + Backend)
./START_ALL.sh

# Frontend (port 3001)
cd Apps/DXBClient
npm run dev          # Serveur de développement
npm run build        # Build production
npm run lint         # ESLint
npm run typecheck    # Vérification TypeScript
npm run test         # Tests unitaires

# Backend (port 3000)
cd Backend
npm run dev          # Serveur API
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

- `profiles` : Profils utilisateurs (id, email, full_name, role)
- `suppliers` : Fournisseurs (nom, email, société, catégorie, statut API)
- `customers` : Clients (prénom, nom, email, segment, valeur)
- `products` : Catalogue produits avec relation fournisseur
- `cart_items` : Panier utilisateur (lié au user et product)
- `orders` : Commandes avec suivi paiement
- `order_items` : Items de commande détaillés
- `ad_campaigns` : Campagnes publicitaires
- `esim_orders` : Commandes eSIM (user_id, order_no, iccid, status, RLS activé)

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
| Frontend | http://localhost:3001 |
| Backend API | http://localhost:3000 |

## Créer un Admin

```sql
-- Dans Supabase SQL Editor
UPDATE profiles SET role = 'admin' WHERE email = 'votre@email.com';
```
