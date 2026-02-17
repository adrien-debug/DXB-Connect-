# DXB Connect - SwiftUI Native App

Application iOS native avec **design blanc tech minimaliste**.

## 🎨 Design System - White Tech

### Principes

- ✅ **Blanc pur** - Fond blanc immaculé
- ✅ **Pas de dégradés** - Couleurs solides uniquement
- ✅ **Typographie bold** - Texte fort et lisible
- ✅ **Bordures fines** - 1.5px précis
- ✅ **Ombres subtiles** - Légères et discrètes
- ✅ **Espacements généreux** - Respiration visuelle
- ✅ **Noir/Gris** - Palette monochrome

### Palette

```swift
Primary: #000000 (Pure Black)
Gray 50:  #FAFAFA
Gray 100: #F4F4F5 (Zinc-100)
Gray 200: #E4E4E7 (Zinc-200)
Gray 400: #A1A1AA (Zinc-400)
Gray 700: #3F3F46 (Zinc-700)
Background: #FFFFFF (Pure White)
```

### Composants

```swift
.techCard()           // Carte blanche avec bordure
.scaleOnPress()       // Animation press
.slideIn(delay: 0.1)  // Animation entrée
```

## 📱 Architecture

```
DXBClientApp.swift          → Coordinator + Navigation
Views/
├── Theme.swift             → Design blanc tech
├── DashboardView.swift     → Dashboard + Quick Actions
├── PlanListView.swift      → Liste plans + filtres
├── PlanDetailView.swift    → Détail plan + achat
├── MyESIMsView.swift       → Mes eSIMs
├── ESIMDetailView.swift    → Détail eSIM + QR
├── ProfileView.swift       → Profil utilisateur
├── AuthView.swift          → Auth (Apple + Email)
└── SupportView.swift       → FAQ + Contact

DXBCore/                    → Package Swift
├── APIClient.swift
├── AuthService.swift
├── DXBAPIService.swift
└── Models.swift
```

## 🚀 Lancement

### Via Script

```bash
cd Apps/DXBClient
./launch.sh
```

### Via Xcode

```bash
open Apps/DXBClient/DXBConnect.xcodeproj
# Cmd + R
```

## ✅ Améliorations v2.0

### Design unifié
- ✅ AuthView - Design White Tech complet
- ✅ PlanDetailView - Refonte avec cards tech
- ✅ ESIMDetailView - Cards + QR + Toast copie
- ✅ ProfileView - Monochrome cohérent
- ✅ MyESIMsView - Header unifié
- ✅ SupportView - FAQ accordéon + contact

### Navigation & UX
- ✅ Flow authentification activé (Apple + Email OTP)
- ✅ Splash screen au chargement
- ✅ Quick Actions fonctionnelles (BUY, SCAN, REWARDS, SUPPORT)
- ✅ Sheets modales cohérentes
- ✅ Toast de confirmation (copie ICCID, etc.)

### Composants
- ✅ OTPDigitBox - Input code 6 digits
- ✅ FeatureTechCard - Grid features
- ✅ InfoMiniCard - Stats compactes
- ✅ TechInfoRow - Lignes copyables
- ✅ FAQCardTech - Accordéon FAQ
- ✅ ContactOptionCard - Options contact

## 🎯 Features

- ✅ Design blanc tech unifié sur toutes les vues
- ✅ Authentification Apple Sign In + Email OTP
- ✅ Navigation fluide sans double menu
- ✅ Animations spring natives
- ✅ Quick Actions fonctionnelles
- ✅ Toast notifications
- ✅ Typographie précise (tracking, weights)
- ✅ Monochrome élégant

## 📱 Testé sur

- ✅ iPhone 17 Pro (iOS 26.2)
- Simulateur Xcode
- Aucune erreur de lint

## 🔧 Debug

### Logs en temps réel

```bash
log show --predicate 'processImagePath contains "DXBConnect"' \
  --last 5m --style compact
```

### Relancer

```bash
cd Apps/DXBClient
./launch.sh
```

## 🎨 Design Tokens

| Token | Valeur | Usage |
|-------|--------|-------|
| Corner Radius | 14-18px | Cards, boutons |
| Border Width | 1.5px | Contours |
| Shadow Opacity | 0.02-0.03 | Élévation subtile |
| Tracking Labels | 1-1.8 | Titres uppercase |
| Font Weight | Bold/Semibold | Texte principal |

## 📄 License

Propriétaire - DXB Connect © 2026
