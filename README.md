# DXB Connect

**Not just data — benefits in every destination.**

eSIM platform with mobile app (Flutter), admin dashboard (Next.js 14), travel partner perks, membership plans (Privilege/Elite/Black), gamification (XP/Points/Raffles), and crypto payments.

## Architecture

```
Flutter App (iOS/Android) ──┐
                            ├──► Railway Backend (Next.js API) ──► Supabase ──► eSIM Access API
Next.js Admin Web ──────────┘
```

- **Railway** is the single entry point — no direct client-to-Supabase or client-to-eSIM API connections
- **Production URL**: `https://web-production-14c51.up.railway.app/api`

## Stack

| Component | Technologies |
|-----------|-------------|
| Mobile App | Flutter (iOS + Android) |
| Admin Web | Next.js 14, TailwindCSS, React Query |
| Backend | Railway (Next.js API), Supabase (Auth + PostgreSQL) |
| eSIM Provider | eSIM Access API |
| Payments | Stripe, Apple Pay, Fireblocks (USDC/USDT) |
| Partners | GetYourGuide, Tiqets, Klook, LoungeBuddy, SafetyWing |

## Features

### eSIM Core
- 120+ countries, instant QR code activation
- Real-time usage tracking, top-up, suspend/resume/cancel
- Stock management (admin), user orders filtering by `user_id`

### Membership Plans
| Plan | Discount | Price |
|------|----------|-------|
| Privilege | -15% | $9.99/mo |
| Elite | -30% | $19.99/mo |
| Black | -50% (1x/mo) | $39.99/mo |

### Travel Perks
- Partner discounts: activities, lounges, insurance, hotels, transfers
- Global + local offers based on destination
- Affiliate tracking (clicks + redemptions)

### Rewards & Gamification
- XP / Points / Tickets / Streak / Levels (Bronze → Platinum)
- Daily check-in, weekly missions, raffles
- Event pipeline: `emitEvent()` distributes rewards after actions

### Crypto Payments
- USDC/USDT (Polygon, Ethereum), ETH via Fireblocks
- Invoice creation + polling + webhook confirmation

## Project Structure

```
Apps/
├── DXBFlutter/               # Flutter mobile app (iOS + Android)
│   ├── lib/
│   │   ├── core/             # API client, services, models
│   │   ├── features/         # Auth, dashboard, etc.
│   │   └── routing/          # App router
│   ├── ios/                  # iOS runner
│   └── android/              # Android runner
│
├── DXBClient/                # Next.js Admin Web + Railway Backend
│   ├── src/
│   │   ├── app/
│   │   │   ├── (dashboard)/  # Admin pages (auth protected)
│   │   │   ├── api/          # API routes (Railway backend)
│   │   │   ├── login/        # Auth pages
│   │   │   └── (marketing)   # Public pages
│   │   ├── components/       # React components
│   │   ├── hooks/            # React Query hooks
│   │   └── lib/              # Supabase, Stripe, validation
│   └── public/               # Static assets
│
└── scripts/                  # Figma sync & migration scripts
```

## API Endpoints

### Auth
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/apple` | POST | Apple Sign-In (iOS) |
| `/api/auth/email/send-otp` | POST | Send OTP |
| `/api/auth/email/verify` | POST | Verify OTP |
| `/api/auth/login` | POST | Email/password login |
| `/api/auth/register` | POST | Register |
| `/api/auth/refresh` | POST | Refresh token |

### eSIM
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/esim/packages` | GET | List available packages |
| `/api/esim/orders` | GET | User's eSIMs (filtered by `user_id`) |
| `/api/esim/stock` | GET | Available stock (admin) |
| `/api/esim/usage` | GET | Data usage for an eSIM |
| `/api/esim/purchase` | POST | Purchase eSIM |
| `/api/esim/topup` | POST | Top-up eSIM |
| `/api/esim/cancel` | POST | Cancel eSIM |
| `/api/esim/suspend` | POST | Suspend/resume eSIM |

### Payments
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/checkout` | POST | Create Stripe payment |
| `/api/checkout/confirm` | POST | Confirm payment |
| `/api/checkout/crypto` | POST | Create crypto invoice |
| `/api/checkout/crypto/:id` | GET | Poll crypto invoice status |

### SimPass — Offers & Partners
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/offers` | GET | Partner offers (filter: country, category) |
| `/api/offers/categories` | GET | Available categories |
| `/api/offers/:id/click` | POST | Track affiliate click |
| `/api/offers/:id/redeem` | POST | Record redemption |

### SimPass — Subscriptions
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/subscriptions/create` | POST | Create subscription |
| `/api/subscriptions/me` | GET | Current subscription |
| `/api/subscriptions/cancel` | POST | Cancel subscription |
| `/api/subscriptions/change` | POST | Upgrade/downgrade |

### SimPass — Rewards
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/rewards/summary` | GET | XP, points, tickets, missions |
| `/api/rewards/checkin` | POST | Daily check-in |
| `/api/rewards/missions` | GET | Active missions |
| `/api/raffles/active` | GET | Active raffles |
| `/api/raffles/enter` | POST | Enter raffle |

### Webhooks
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/webhooks/stripe` | POST | Stripe events |
| `/api/webhooks/esim` | POST | eSIM Access events |
| `/api/webhooks/fireblocks` | POST | Crypto payment events |

## Database (Supabase)

### Core Tables
`profiles`, `esim_orders`, `orders`, `order_items`, `products`, `suppliers`, `customers`, `cart_items`

### SimPass Tables
`partner_offers`, `offer_clicks`, `offer_redemptions`, `subscriptions`, `subscription_usage`, `user_wallet`, `wallet_transactions`, `missions`, `user_mission_progress`, `raffles`, `raffle_entries`, `crypto_invoices`, `crypto_payments`, `event_logs`

### Key Rules
- `esim_orders.iccid` is UNIQUE — always use ICCID as the primary identifier
- RLS enabled on `esim_orders` — users can only see their own eSIMs
- All queries filter by `user_id` via `requireAuthFlexible()` middleware

## Setup

### 1. Install
```bash
cd Apps/DXBClient
npm install
```

### 2. Environment
Create `.env.local` from `.env.example`:
```env
NEXT_PUBLIC_RAILWAY_URL=https://web-production-14c51.up.railway.app
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
ESIM_ACCESS_CODE=xxx
ESIM_SECRET_KEY=xxx
STRIPE_SECRET_KEY=sk_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_xxx
```

### 3. Run
```bash
cd Apps/DXBClient
npm run dev          # Dev server (port 4000)
npm run build        # Production build
npm run typecheck    # TypeScript check
```

### 4. Flutter App
```bash
cd Apps/DXBFlutter
flutter pub get
flutter run         # Run on connected device/simulator
```

## Auth

- Supabase Auth with `profiles` table
- Roles: `client` (default) | `admin`
- `requireAuthFlexible()` supports Bearer token (iOS) + Cookie session (Web)
- Admin routes protected by role middleware

```sql
-- Promote to admin
UPDATE profiles SET role = 'admin' WHERE email = 'you@example.com';
```

## Deployment

- **Web/API**: Auto-deploy on push to `main` via Railway
- **Mobile**: Flutter build → App Store Connect (iOS) / Play Console (Android)
- **Database**: Supabase hosted (migrations via `scripts/migrate-simpass.js`)

## Marketing Pages

| Route | Content |
|-------|---------|
| `/` | Landing (perks, plans, rewards, testimonials) |
| `/pricing` | 3 membership plans + pay-as-you-go eSIMs |
| `/features` | Core eSIM + Travel Perks + Rewards |
| `/partners` | Travel partners + API partners |
| `/how-it-works` | 3-step guide + perks/rewards |
| `/blog` | Articles (perks, plans, rewards, crypto) |
| `/faq` | 20 questions across 5 categories |
| `/contact` | FAQ + contact form |

---

## Next Steps

1. **Stripe**: Create 6 subscription products (Privilege/Elite/Black × Monthly/Yearly)
2. **App Store Connect**: Configure 6 IAP subscriptions
3. **Fireblocks**: Configure vault + webhook
4. **Affiliates**: Register with GetYourGuide, Tiqets, Klook
5. **Domain**: Purchase `simpass.co` / `getsimpass.com`
