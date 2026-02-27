# DXB Connect - Admin Dashboard

Dashboard d'administration Next.js 14 + Railway Backend API.

## Démarrage

```bash
cd Apps/DXBClient
npm install
npm run dev          # Dev server (port 4000)
npm run build        # Production build
npm run typecheck    # TypeScript check
```

## Structure

```
src/
├── app/
│   ├── (dashboard)/        # Pages admin (auth protected)
│   │   ├── layout.tsx      # Layout avec sidebar
│   │   ├── dashboard/
│   │   ├── esim/
│   │   ├── orders/
│   │   ├── customers/
│   │   ├── perks/
│   │   ├── subscriptions/
│   │   └── rewards/
│   ├── api/                # API routes (Railway backend)
│   ├── login/              # Auth pages
│   └── (marketing)/        # Public pages
├── components/             # React components
├── hooks/                  # React Query hooks
└── lib/                    # Supabase, Stripe, validation
```

## Design System

### Palette
```css
--primary: #7C3AED (Violet-600)
--primary-light: #A78BFA (Violet-400)
--primary-dark: #5B21B6 (Violet-700)
--accent: #8B5CF6 (Violet-500)
--bg-base: #F3F4FA (Lavender gray)
```

### Composants principaux
- **Sidebar** : Navigation responsive avec collapse + menu mobile
- **StatCard** : Cartes statistiques avec icônes
- **DataTable** : Tableau avec recherche, filtres, pagination
- **Modal** : Modale responsive avec animations

## Technologies

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Supabase (via Railway)
- React Query
- Recharts
- Stripe
- Lucide Icons
