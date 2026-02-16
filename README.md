# DXB Connect

Plateforme de gestion et de connexion pour DXB avec backend Node.js, frontend Next.js, et applications natives iOS/macOS.

## 🏗️ Structure du Projet

```
DXB Connect/
├── Apps/
│   ├── DXBAdmin/          # Application admin iOS/macOS (SwiftUI)
│   └── DXBClient/         # Application web client (Next.js + React)
├── Backend/               # API REST Node.js + Express + TypeScript
│   ├── src/
│   │   ├── routes/        # Routes API (users, orders, plans)
│   │   └── index.ts       # Point d'entrée
│   ├── package.json
│   └── tsconfig.json
└── Packages/
    ├── DXBCore/           # Package Swift partagé (modèles, networking)
    ├── DXBAdminKit/       # Kit admin réutilisable
    ├── DXBAnalytics/      # Module analytics
    └── DXBDesignSystem/   # Design system
```

## 🚀 Démarrage Rapide

### Tout démarrer en une commande

```bash
./start-all.sh
```

Cela va:
- Installer toutes les dépendances (Backend + Frontend)
- Démarrer le backend sur `http://localhost:3001`
- Démarrer le frontend sur `http://localhost:3000`

### Arrêter tous les services

```bash
./stop-all.sh
```

## 📦 Installation Manuelle

### Backend (Node.js + Express)

```bash
cd Backend
npm install
cp .env.example .env
npm run dev
```

Le backend sera disponible sur `http://localhost:3001`

**Endpoints disponibles:**
- `GET /health` - Health check
- `GET /api/users` - Liste des utilisateurs
- `GET /api/orders` - Liste des commandes
- `GET /api/plans` - Liste des plans disponibles
- `POST /api/orders` - Créer une commande

### Frontend Web (Next.js)

```bash
cd Apps/DXBClient
npm install
cp .env.local.example .env.local
npm run dev
```

Le frontend sera disponible sur `http://localhost:3000`

### Application iOS/macOS (SwiftUI)

```bash
cd Apps/DXBAdmin
open DXBAdmin.xcodeproj
```

Puis appuyez sur `Cmd+R` pour compiler et lancer l'application.

**Note:** L'app iOS/macOS se connecte automatiquement au backend sur `http://localhost:3001`

## 🛠️ Technologies

- **Backend:** Node.js, Express, TypeScript
- **Frontend Web:** Next.js 14, React 18, TypeScript, Tailwind CSS
- **Apps Natives:** SwiftUI, Swift 5.9
- **Package Manager:** npm

## 📱 Applications

### DXB Client (Web)
Interface web moderne avec:
- Affichage des plans disponibles
- Design responsive
- Mode sombre automatique

### DXB Admin (iOS/macOS)
Application native avec:
- Liste des plans en temps réel
- Interface SwiftUI moderne
- Support iOS 16+ et macOS 13+

## 🔧 Scripts Disponibles

### Backend
- `npm run dev` - Démarrage en mode développement avec hot-reload
- `npm run build` - Compilation TypeScript
- `npm start` - Démarrage en production

### Frontend
- `npm run dev` - Démarrage en mode développement
- `npm run build` - Build de production
- `npm start` - Démarrage du build de production
- `npm run lint` - Vérification du code

## 📝 Logs

Les logs sont sauvegardés dans:
- `backend.log` - Logs du backend
- `frontend.log` - Logs du frontend

Pour suivre les logs en temps réel:
```bash
tail -f backend.log
tail -f frontend.log
```

## 🌐 URLs de Développement

- **Frontend Web:** http://localhost:3000
- **Backend API:** http://localhost:3001
- **Health Check:** http://localhost:3001/health
- **API Plans:** http://localhost:3001/api/plans
- **API Users:** http://localhost:3001/api/users
- **API Orders:** http://localhost:3001/api/orders

## 📄 Licence

Propriétaire
