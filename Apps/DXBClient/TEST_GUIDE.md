# Guide de Test - App iOS DXB Connect

## 🎯 Objectif

Ce guide vous permet de tester manuellement l'application iOS et sa connexion au backend.

## 📋 Prérequis

- Xcode 15+ installé
- Node.js 18+ installé
- Compte développeur Apple (pour Sign in with Apple)
- Simulateur iOS 17+ ou device physique

## 🚀 Démarrage Rapide

### 1. Démarrer le Backend

```bash
cd Apps/DXBClient
npm install
npm run dev
```

Le serveur démarre sur `http://localhost:4000`

### 2. Configurer l'App iOS

Ouvrir `DXBClientApp.swift` et modifier la ligne 56:

```swift
// Pour développement local
APIConfig.current = .development  // http://localhost:3000/api

// OU modifier Config.swift pour pointer vers le bon port
case .development:
    return URL(string: "http://localhost:4000/api")!
```

### 3. Lancer l'App iOS

```bash
# Via Xcode
open Apps/DXBClient/DXBClient.xcodeproj

# OU via ligne de commande
cd Apps/DXBClient
xcodebuild -scheme DXBClient \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug
```

## 🧪 Tests Manuels

### Test 1: Authentification Email + OTP

**Objectif**: Vérifier le flux d'authentification par email

1. Lancer l'app
2. Cliquer sur "Sign in with Email"
3. Entrer un email: `test@dxbconnect.com`
4. Vérifier que l'OTP est envoyé (check logs backend)
5. Entrer le code OTP reçu
6. Vérifier la connexion réussie

**Résultat attendu**:
- ✅ Email envoyé avec succès
- ✅ Code OTP reçu par email
- ✅ Connexion réussie
- ✅ Redirection vers le dashboard

**Logs à vérifier**:
```bash
# Terminal backend
[auth/email/send-otp] OTP sent successfully

# Console iOS (Xcode)
[API] POST /api/auth/email/send-otp -> 200
[API] POST /api/auth/email/verify -> 200
```

---

### Test 2: Chargement des Plans eSIM

**Objectif**: Vérifier que les plans se chargent correctement

1. Aller sur l'onglet "Explore" (globe)
2. Attendre le chargement
3. Vérifier l'affichage des plans

**Résultat attendu**:
- ✅ Liste des plans affichée
- ✅ Prix en USD
- ✅ Données en GB
- ✅ Durée en jours
- ✅ Drapeaux des pays

**Logs à vérifier**:
```bash
# Console iOS
[API] GET /api/esim/packages -> 200
Loading plans: 2328 items
```

---

### Test 3: Affichage Mes eSIMs

**Objectif**: Vérifier que les eSIMs de l'utilisateur s'affichent

1. Aller sur l'onglet "eSIMs" (carte SIM)
2. Attendre le chargement
3. Vérifier l'affichage des commandes

**Résultat attendu**:
- ✅ Liste des eSIMs affichée
- ✅ Statut correct (Active/Expired)
- ✅ QR Code visible
- ✅ Détails du package

**Logs à vérifier**:
```bash
# Console iOS
[API] GET /api/esim/orders -> 200
Loading eSIMs: X items
```

---

### Test 4: Détails d'un Plan

**Objectif**: Vérifier l'affichage des détails d'un plan

1. Dans l'onglet "Explore"
2. Cliquer sur un plan
3. Vérifier les informations affichées

**Résultat attendu**:
- ✅ Nom du plan
- ✅ Prix
- ✅ Données
- ✅ Durée
- ✅ Opérateurs réseau
- ✅ Bouton "Add to Cart"

---

### Test 5: Profil Utilisateur

**Objectif**: Vérifier l'affichage et la modification du profil

1. Aller sur l'onglet "Profile"
2. Vérifier les informations affichées
3. Modifier le nom
4. Sauvegarder
5. Redémarrer l'app
6. Vérifier que le nom est conservé

**Résultat attendu**:
- ✅ Informations utilisateur affichées
- ✅ Statistiques correctes (total eSIMs, pays visités, etc.)
- ✅ Modification sauvegardée
- ✅ Persistance après redémarrage

---

### Test 6: Mode Offline

**Objectif**: Vérifier le comportement sans connexion

1. Charger les plans (avec connexion)
2. Activer le mode avion
3. Naviguer dans l'app
4. Vérifier les messages d'erreur

**Résultat attendu**:
- ⚠️ Actuellement: Erreur réseau
- 🎯 Futur: Cache local avec données précédentes

---

### Test 7: Déconnexion

**Objectif**: Vérifier le flux de déconnexion

1. Dans le profil, cliquer sur "Sign Out"
2. Confirmer la déconnexion
3. Vérifier le retour à l'écran d'auth

**Résultat attendu**:
- ✅ Confirmation demandée
- ✅ Tokens supprimés du Keychain
- ✅ Retour à l'écran d'authentification
- ✅ Données utilisateur effacées

---

## 🔍 Tests Automatisés

### Test Backend (API)

```bash
cd Apps/DXBClient
./ios-backend-audit.sh
```

**Vérifie**:
- Connexion backend Next.js
- Endpoints API
- Connexion Supabase
- API eSIM Access

### Test iOS (Unit Tests)

```bash
cd Apps/DXBClient
swift test
```

**Vérifie**:
- AuthService
- APIClient
- Models

---

## 🐛 Debugging

### Voir les Logs iOS

```bash
# Tous les logs de l'app
log stream --predicate 'subsystem == "com.dxbconnect.app"'

# Uniquement les erreurs
log stream --predicate 'subsystem == "com.dxbconnect.app" AND eventType == "error"'

# Logs API
log stream --predicate 'subsystem == "com.dxbconnect.app" AND category == "API"'
```

### Voir les Logs Backend

```bash
# Dans le terminal où tourne npm run dev
# Les logs s'affichent automatiquement
```

### Inspecter le Keychain

```bash
# Via Xcode
# Window > Devices and Simulators > Select device > View Device Logs
```

### Inspecter les Requêtes Réseau

1. Installer Charles Proxy
2. Configurer le proxy sur le simulateur
3. Voir toutes les requêtes HTTP

---

## 📊 Checklist de Test Complet

### Authentification
- [ ] Email + OTP (envoi)
- [ ] Email + OTP (vérification)
- [ ] Sign in with Apple
- [ ] Déconnexion
- [ ] Reconnexion automatique

### Navigation
- [ ] Onglet Home (Dashboard)
- [ ] Onglet Explore (Plans)
- [ ] Onglet eSIMs
- [ ] Onglet Profile
- [ ] Retour arrière
- [ ] Swipe gestures

### Données
- [ ] Chargement plans
- [ ] Chargement eSIMs
- [ ] Détails plan
- [ ] Détails eSIM
- [ ] Recherche plans
- [ ] Filtres

### Profil
- [ ] Affichage infos
- [ ] Modification nom
- [ ] Modification email
- [ ] Modification téléphone
- [ ] Changement langue
- [ ] Changement thème (Light/Dark)
- [ ] Notifications toggle

### Erreurs
- [ ] Pas de connexion internet
- [ ] Token expiré
- [ ] Erreur serveur (500)
- [ ] Endpoint introuvable (404)
- [ ] Données invalides

### Performance
- [ ] Temps de chargement < 2s
- [ ] Scroll fluide
- [ ] Animations smooth
- [ ] Pas de memory leaks
- [ ] Pas de crashs

---

## 🎯 Scénarios de Test Complets

### Scénario 1: Premier Utilisateur

1. Installer l'app
2. Lancer l'app
3. Voir l'écran d'onboarding (si implémenté)
4. Créer un compte (Email + OTP)
5. Explorer les plans
6. Ajouter un plan au panier
7. Acheter un eSIM
8. Activer l'eSIM
9. Voir les détails de l'eSIM

**Durée estimée**: 5-10 minutes

---

### Scénario 2: Utilisateur Récurrent

1. Lancer l'app
2. Connexion automatique
3. Voir le dashboard avec stats
4. Consulter mes eSIMs
5. Voir les détails d'un eSIM actif
6. Recharger un eSIM
7. Contacter le support

**Durée estimée**: 3-5 minutes

---

### Scénario 3: Voyage Multi-Pays

1. Connexion
2. Rechercher "Europe"
3. Comparer les plans multi-pays
4. Acheter un plan Europe
5. Activer avant le départ
6. Utiliser pendant le voyage
7. Vérifier la consommation
8. Recharger si nécessaire

**Durée estimée**: 10-15 minutes

---

## 📝 Rapport de Bug

Si vous trouvez un bug, créer un rapport avec:

```markdown
## Bug: [Titre court]

**Priorité**: Critique / Haute / Moyenne / Basse

**Description**:
[Description détaillée du bug]

**Étapes pour reproduire**:
1.
2.
3.

**Résultat attendu**:
[Ce qui devrait se passer]

**Résultat obtenu**:
[Ce qui se passe réellement]

**Environnement**:
- iOS: [version]
- Device: [iPhone 15 / Simulator]
- Backend: [localhost / production]
- Version app: [1.0.0]

**Logs**:
```
[Copier les logs pertinents]
```

**Screenshots**:
[Si applicable]
```

---

## 🔗 Ressources

- **Documentation API**: `Apps/DXBClient/src/app/api/`
- **Modèles iOS**: `Apps/DXBClient/DXBCore/Sources/DXBCore/Models.swift`
- **Configuration**: `Apps/DXBClient/DXBCore/Sources/DXBCore/Config.swift`
- **Audit complet**: `AUDIT_IOS_FIXES.md`

---

## 📞 Support

Pour toute question:
1. Consulter `AUDIT_IOS_SUMMARY.md`
2. Exécuter `./ios-backend-audit.sh`
3. Vérifier les logs dans Console.app
4. Créer un ticket avec tous les détails

---

**Dernière mise à jour**: 17/02/2026
**Version**: 1.0.0
