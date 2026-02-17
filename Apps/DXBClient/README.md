# DXB Connect - Client App

Application mobile et web pour DXB Connect.

## 🚀 Démarrage rapide

### Web (Next.js)
```bash
cd Apps/DXBClient
npm run dev
# → http://localhost:3001
```

### iOS Native (SwiftUI)
```bash
cd Apps/DXBClient
./launch.sh
# ou
open DXBConnect.xcodeproj
```

### iOS Capacitor (Next.js wrappé)
```bash
cd Apps/DXBClient
npm run build
npx cap sync ios
npx cap open ios
```

## 🎨 Design System

### Corrections récentes (2026-02-17)

#### ✅ Bugs corrigés

1. **Responsive Mobile**
   - Sidebar avec menu burger fonctionnel
   - Header mobile avec logo et menu
   - Grilles adaptatives (products, esim, stats)
   - Espacements optimisés pour mobile

2. **Composants UI**
   - `StatCard`: Icônes alignées, texte responsive
   - `DataTable`: Actions visibles sur mobile, pagination améliorée
   - `Modal`: Scroll fixé, backdrop correct, responsive
   - `ProductCard`: Badges non-chevauchants, texte tronqué
   - `EsimPackageCard`: Layout flexible, texte lisible

3. **Charts**
   - Marges optimisées pour mobile
   - Tailles de police réduites
   - Responsive containers

4. **Login**
   - Padding responsive
   - Logo adaptatif
   - Inputs focus states cohérents

### Palette de couleurs

```css
--primary: #7C3AED (Violet-600)
--primary-light: #A78BFA (Violet-400)
--primary-dark: #5B21B6 (Violet-700)
--accent: #8B5CF6 (Violet-500)
--bg-base: #F3F4FA (Lavender gray)
```

### Composants

- **Sidebar**: Navigation avec collapse + menu mobile
- **StatCard**: Cartes statistiques avec icônes colorées
- **DataTable**: Tableau avec recherche, filtres, pagination
- **Modal**: Modale responsive avec animations
- **ProductCard**: Carte produit avec badges status
- **EsimPackageCard**: Carte package eSIM

## 🚀 Démarrage

```bash
# Installation
npm install

# Dev
npm run dev

# Build
npm run build

# iOS (Capacitor)
npx cap sync ios
npx cap open ios
```

## 📱 Structure

```
src/
├── app/
│   ├── (dashboard)/        # Pages dashboard
│   │   ├── layout.tsx      # Layout avec sidebar + mobile menu
│   │   ├── dashboard/
│   │   ├── products/
│   │   ├── esim/
│   │   └── ...
│   ├── login/
│   └── globals.css         # Design system
├── components/
│   ├── Sidebar.tsx         # Navigation responsive
│   ├── StatCard.tsx
│   ├── DataTable.tsx
│   ├── Modal.tsx
│   └── ...
└── hooks/
    ├── useAuth.ts
    ├── useCart.ts
    └── useEsimAccess.ts
```

## 🎯 Features

- ✅ Design premium violet glassmorphism
- ✅ Responsive mobile/tablet/desktop
- ✅ Menu burger mobile
- ✅ Animations fluides
- ✅ Dark sidebar avec gradient
- ✅ Charts responsive (Recharts)
- ✅ Gestion produits/commandes
- ✅ Intégration eSIM Access API
- ✅ Panier d'achat
- ✅ Authentification Supabase

## 🔧 Technologies

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Capacitor (iOS)
- Supabase
- React Query
- Recharts
- Lucide Icons

## 📝 Notes

- Design optimisé pour iOS
- Support dark mode (sidebar)
- Animations performantes
- Accessibilité (aria-labels)
- SEO-friendly
