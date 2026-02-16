# DXB Connect - Plateforme de Gestion

Plateforme de gestion centralisée pour gérer vos fournisseurs, clients et campagnes publicitaires.

## Fonctionnalités

- **Dashboard** : Vue d'ensemble avec statistiques et graphiques
- **Fournisseurs** : CRUD complet pour gérer vos suppliers
- **Clients** : Gestion de la base clients avec segmentation
- **Publicités** : Suivi des campagnes AdWords, Facebook, etc.

## Stack

- **Frontend** : Next.js 14, React 18, TailwindCSS
- **Backend** : Supabase (PostgreSQL + API REST)
- **Charts** : Recharts
- **Icons** : Lucide React

## Installation

```bash
cd Apps/DXBClient
npm install
```

## Configuration

Fichier `.env.local` :

```
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
```

## Lancer le projet

```bash
cd Apps/DXBClient
npm run dev -- -p 3001
```

Ouvrir http://localhost:3001

## Structure

```
Apps/DXBClient/
├── src/
│   ├── app/
│   │   ├── dashboard/     # Dashboard principal
│   │   ├── suppliers/     # Gestion fournisseurs
│   │   ├── customers/     # Gestion clients
│   │   ├── ads/           # Campagnes publicitaires
│   │   ├── layout.tsx     # Layout avec sidebar
│   │   └── page.tsx       # Redirect vers dashboard
│   ├── components/
│   │   ├── Sidebar.tsx    # Navigation
│   │   ├── DataTable.tsx  # Table réutilisable
│   │   ├── Modal.tsx      # Modales
│   │   └── StatCard.tsx   # Cartes statistiques
│   └── lib/
│       └── supabase.ts    # Client Supabase + Types
```

## Tables Supabase

- `suppliers` : Fournisseurs (nom, email, société, catégorie, etc.)
- `customers` : Clients (prénom, nom, email, segment, valeur, etc.)
- `ad_campaigns` : Campagnes publicitaires (plateforme, budget, métriques, etc.)
