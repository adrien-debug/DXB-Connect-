# 🧪 Guide Complet des Tests Manuels - DXB Connect

**Version:** 1.0
**Date:** 17 Février 2026
**Pour:** Tests QA manuels de l'application DXB Connect

---

## 🎯 Objectif

Ce guide vous accompagne pas à pas pour effectuer des tests manuels complets de l'application DXB Connect.

---

## 📋 Prérequis

### 1. Environnement
```bash
# Vérifier que le serveur est lancé
curl http://localhost:3001

# Si pas lancé, démarrer:
cd Apps/DXBClient
npm run dev
```

### 2. Outils Nécessaires
- ✅ Navigateur Chrome ou Firefox (dernière version)
- ✅ DevTools (F12)
- ✅ Connexion Internet
- ✅ Compte de test Supabase

### 3. Variables d'Environnement
```bash
# Vérifier le fichier .env.local
cd Apps/DXBClient
cat .env.local

# Doit contenir:
# NEXT_PUBLIC_SUPABASE_URL=...
# NEXT_PUBLIC_SUPABASE_ANON_KEY=...
# NEXT_PUBLIC_ESIM_ACCESS_API_KEY=...
# NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=...
```

---

## 🚀 Phase 1: Tests de Base

### Test 1.1: Accès à l'Application
**Durée estimée:** 2 minutes

1. **Ouvrir le navigateur**
   ```
   URL: http://localhost:3001
   ```

2. **Observer le comportement**
   - [ ] Un loader animé apparaît (icône Sparkles)
   - [ ] Animation fluide (pas de saccades)
   - [ ] Redirection automatique vers `/dashboard`
   - [ ] Temps de redirection < 2 secondes

3. **Vérifier la console**
   - Appuyer sur `F12`
   - Aller dans l'onglet `Console`
   - [ ] Aucune erreur rouge
   - [ ] Pas de warnings critiques

**Résultat attendu:**
```
✅ Redirection vers /dashboard
✅ Puis redirection vers /login (si non connecté)
✅ Pas d'erreurs console
```

**Si ça échoue:**
- Vérifier que le serveur tourne
- Vérifier les variables d'environnement
- Regarder les erreurs console

---

### Test 1.2: Page de Login
**Durée estimée:** 5 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/login
   ```

2. **Vérifier l'affichage**
   - [ ] Formulaire de connexion visible
   - [ ] Champ "Email" présent
   - [ ] Champ "Mot de passe" présent
   - [ ] Bouton "Se connecter" présent
   - [ ] Lien vers "S'inscrire" présent
   - [ ] Design professionnel et moderne

3. **Tester les validations**

   **Test A: Email vide**
   - Laisser l'email vide
   - Cliquer sur "Se connecter"
   - [ ] Message d'erreur affiché
   - [ ] Champ email surligné en rouge

   **Test B: Email invalide**
   - Entrer: `test@invalid`
   - Cliquer sur "Se connecter"
   - [ ] Message "Email invalide"

   **Test C: Mot de passe vide**
   - Entrer un email valide
   - Laisser le mot de passe vide
   - Cliquer sur "Se connecter"
   - [ ] Message d'erreur affiché

   **Test D: Identifiants incorrects**
   - Email: `test@example.com`
   - Password: `wrongpassword`
   - Cliquer sur "Se connecter"
   - [ ] Message "Identifiants incorrects"
   - [ ] Pas de redirection

4. **Vérifier le responsive**
   - Appuyer sur `F12`
   - Cliquer sur l'icône mobile (Ctrl+Shift+M)
   - Tester: iPhone SE (375px)
   - [ ] Formulaire adapté
   - [ ] Boutons accessibles
   - [ ] Pas de débordement horizontal

**Résultat attendu:**
```
✅ Formulaire fonctionnel
✅ Validations actives
✅ Messages d'erreur clairs
✅ Responsive sur mobile
```

**Screenshot à prendre:**
- Page de login (desktop)
- Page de login (mobile)
- Message d'erreur

---

### Test 1.3: Page d'Inscription
**Durée estimée:** 5 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/register
   ```

2. **Vérifier l'affichage**
   - [ ] Formulaire d'inscription visible
   - [ ] Champ "Nom complet" présent
   - [ ] Champ "Email" présent
   - [ ] Champ "Mot de passe" présent
   - [ ] Champ "Confirmer mot de passe" présent
   - [ ] Bouton "S'inscrire" présent
   - [ ] Lien vers "Se connecter" présent

3. **Tester les validations**

   **Test A: Tous les champs vides**
   - Cliquer sur "S'inscrire"
   - [ ] Messages d'erreur sur tous les champs

   **Test B: Email invalide**
   - Entrer: `invalid-email`
   - [ ] Message "Email invalide"

   **Test C: Mot de passe trop court**
   - Entrer: `123`
   - [ ] Message "Minimum 6 caractères"

   **Test D: Mots de passe différents**
   - Password: `password123`
   - Confirm: `password456`
   - [ ] Message "Les mots de passe ne correspondent pas"

4. **Créer un compte de test**
   ```
   Nom: Test User
   Email: test-[timestamp]@example.com
   Password: TestPassword123!
   Confirm: TestPassword123!
   ```
   - Cliquer sur "S'inscrire"
   - [ ] Message de succès
   - [ ] Redirection appropriée
   - [ ] Email de confirmation envoyé (vérifier inbox)

**Résultat attendu:**
```
✅ Formulaire fonctionnel
✅ Validations actives
✅ Compte créé avec succès
✅ Email de confirmation envoyé
```

---

## 🔐 Phase 2: Tests d'Authentification

### Test 2.1: Connexion avec Compte Valide
**Durée estimée:** 3 minutes

1. **Se connecter**
   - Aller sur `/login`
   - Entrer les identifiants créés précédemment
   - Cliquer sur "Se connecter"

2. **Vérifier le comportement**
   - [ ] Loading state visible pendant la requête
   - [ ] Redirection vers `/dashboard`
   - [ ] Dashboard s'affiche correctement
   - [ ] Sidebar visible
   - [ ] Nom d'utilisateur affiché

3. **Vérifier la persistance**
   - Rafraîchir la page (F5)
   - [ ] Toujours connecté
   - [ ] Pas de redirection vers `/login`
   - [ ] Session maintenue

**Résultat attendu:**
```
✅ Connexion réussie
✅ Redirection vers dashboard
✅ Session persistante
```

---

### Test 2.2: Protection des Routes
**Durée estimée:** 5 minutes

1. **Se déconnecter** (si bouton disponible)

2. **Tester l'accès aux pages protégées**

   Essayer d'accéder directement à:
   - `/dashboard` → [ ] Redirige vers `/login`
   - `/products` → [ ] Redirige vers `/login`
   - `/esim` → [ ] Redirige vers `/login`
   - `/orders` → [ ] Redirige vers `/login`
   - `/suppliers` → [ ] Redirige vers `/login`
   - `/customers` → [ ] Redirige vers `/login`
   - `/ads` → [ ] Redirige vers `/login`

3. **Se reconnecter**

4. **Tester l'accès aux pages protégées (connecté)**

   Accéder à:
   - `/dashboard` → [ ] Affiche le dashboard
   - `/products` → [ ] Affiche la liste des produits
   - `/esim` → [ ] Affiche les plans eSIM
   - `/orders` → [ ] Affiche les commandes
   - `/suppliers` → [ ] Affiche les fournisseurs
   - `/customers` → [ ] Affiche les clients
   - `/ads` → [ ] Affiche les publicités

**Résultat attendu:**
```
✅ Routes protégées inaccessibles sans authentification
✅ Routes accessibles après connexion
✅ Redirections fonctionnelles
```

---

## 📊 Phase 3: Tests du Dashboard

### Test 3.1: Affichage du Dashboard
**Durée estimée:** 5 minutes

1. **Accéder au dashboard**
   ```
   URL: http://localhost:3001/dashboard
   ```

2. **Vérifier les éléments**
   - [ ] Sidebar visible à gauche
   - [ ] Logo/Titre de l'application
   - [ ] Menu de navigation
   - [ ] Cartes de statistiques (StatCards)
   - [ ] Graphiques/Charts (si présents)
   - [ ] Données chargées

3. **Vérifier les StatCards**

   Pour chaque carte:
   - [ ] Icône visible
   - [ ] Titre clair
   - [ ] Valeur affichée
   - [ ] Couleur/Gradient présent
   - [ ] Animation au hover

4. **Tester les interactions**
   - Hover sur les cartes
   - [ ] Effet visuel (scale, shadow)
   - Cliquer sur les cartes (si cliquables)
   - [ ] Navigation appropriée

**Résultat attendu:**
```
✅ Dashboard complet
✅ Statistiques affichées
✅ Design moderne et professionnel
✅ Interactions fluides
```

**Screenshot à prendre:**
- Dashboard complet (desktop)
- Dashboard (mobile)

---

### Test 3.2: Sidebar Navigation
**Durée estimée:** 5 minutes

1. **Vérifier les éléments de la sidebar**
   - [ ] Logo/Titre
   - [ ] Menu items:
     - [ ] Dashboard
     - [ ] Produits
     - [ ] eSIM
     - [ ] Commandes
     - [ ] Fournisseurs
     - [ ] Clients
     - [ ] Publicités
   - [ ] Icônes pour chaque item
   - [ ] Bouton de déconnexion (si présent)

2. **Tester la navigation**

   Cliquer sur chaque menu item:
   - Dashboard → [ ] Affiche `/dashboard`
   - Produits → [ ] Affiche `/products`
   - eSIM → [ ] Affiche `/esim`
   - Commandes → [ ] Affiche `/orders`
   - Fournisseurs → [ ] Affiche `/suppliers`
   - Clients → [ ] Affiche `/customers`
   - Publicités → [ ] Affiche `/ads`

3. **Vérifier le highlight**
   - [ ] Item actif surligné
   - [ ] Couleur différente
   - [ ] Indicateur visuel clair

4. **Tester le collapse (si disponible)**
   - Cliquer sur le bouton collapse
   - [ ] Sidebar se réduit
   - [ ] Icônes restent visibles
   - [ ] Texte masqué
   - Re-cliquer
   - [ ] Sidebar s'agrandit

**Résultat attendu:**
```
✅ Navigation fonctionnelle
✅ Highlight de la page active
✅ Collapse/Expand fonctionnel
```

---

## 🛍️ Phase 4: Tests des Produits

### Test 4.1: Liste des Produits
**Durée estimée:** 10 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/products
   ```

2. **Vérifier l'affichage**
   - [ ] Titre de la page
   - [ ] Bouton "Ajouter un produit"
   - [ ] Barre de recherche
   - [ ] Filtres (si présents)
   - [ ] Table des produits
   - [ ] Pagination

3. **Vérifier les colonnes de la table**
   - [ ] Nom du produit
   - [ ] Description
   - [ ] Prix
   - [ ] Stock
   - [ ] Statut
   - [ ] Actions (Éditer, Supprimer)

4. **Tester la recherche**
   - Entrer un terme de recherche
   - [ ] Résultats filtrés en temps réel
   - [ ] Debouncing actif (pas de recherche à chaque lettre)
   - Effacer la recherche
   - [ ] Tous les produits réaffichés

5. **Tester le tri**
   - Cliquer sur l'en-tête "Nom"
   - [ ] Tri ascendant
   - Re-cliquer
   - [ ] Tri descendant
   - Tester avec d'autres colonnes
   - [ ] Tri fonctionnel

6. **Tester la pagination**
   - [ ] Nombre total de produits affiché
   - [ ] Boutons Précédent/Suivant
   - [ ] Numéros de page
   - Cliquer sur "Page 2"
   - [ ] Nouveaux produits affichés
   - [ ] URL mise à jour (si applicable)

**Résultat attendu:**
```
✅ Liste affichée correctement
✅ Recherche fonctionnelle
✅ Tri fonctionnel
✅ Pagination fonctionnelle
```

---

### Test 4.2: Ajout de Produit
**Durée estimée:** 5 minutes

1. **Ouvrir le modal**
   - Cliquer sur "Ajouter un produit"
   - [ ] Modal s'ouvre avec animation
   - [ ] Overlay/Backdrop visible
   - [ ] Formulaire affiché

2. **Vérifier le formulaire**
   - [ ] Champ "Nom"
   - [ ] Champ "Description"
   - [ ] Champ "Prix"
   - [ ] Champ "Stock"
   - [ ] Champ "Catégorie"
   - [ ] Bouton "Annuler"
   - [ ] Bouton "Ajouter"

3. **Tester les validations**
   - Cliquer sur "Ajouter" sans remplir
   - [ ] Messages d'erreur affichés
   - Remplir avec des données invalides
   - [ ] Validations actives

4. **Ajouter un produit**
   ```
   Nom: Produit Test QA
   Description: Produit créé pendant les tests QA
   Prix: 99.99
   Stock: 50
   Catégorie: Test
   ```
   - Cliquer sur "Ajouter"
   - [ ] Loading state visible
   - [ ] Modal se ferme
   - [ ] Message de succès (toast)
   - [ ] Produit apparaît dans la liste

5. **Fermer le modal**
   - Rouvrir le modal
   - Cliquer sur "X" (fermer)
   - [ ] Modal se ferme
   - Rouvrir
   - Cliquer en dehors du modal
   - [ ] Modal se ferme
   - Rouvrir
   - Appuyer sur ESC
   - [ ] Modal se ferme

**Résultat attendu:**
```
✅ Modal fonctionnel
✅ Validations actives
✅ Produit ajouté avec succès
✅ Fermeture du modal fonctionnelle
```

---

### Test 4.3: Édition de Produit
**Durée estimée:** 5 minutes

1. **Ouvrir l'édition**
   - Trouver le produit créé précédemment
   - Cliquer sur "Éditer"
   - [ ] Modal s'ouvre
   - [ ] Données pré-remplies

2. **Modifier les données**
   ```
   Nom: Produit Test QA (Modifié)
   Prix: 149.99
   ```
   - Cliquer sur "Sauvegarder"
   - [ ] Loading state
   - [ ] Modal se ferme
   - [ ] Message de succès
   - [ ] Modifications visibles dans la liste

**Résultat attendu:**
```
✅ Édition fonctionnelle
✅ Données mises à jour
✅ Affichage mis à jour
```

---

### Test 4.4: Suppression de Produit
**Durée estimée:** 3 minutes

1. **Supprimer le produit**
   - Trouver le produit test
   - Cliquer sur "Supprimer"
   - [ ] Modal de confirmation (si présent)
   - Confirmer la suppression
   - [ ] Loading state
   - [ ] Message de succès
   - [ ] Produit retiré de la liste

**Résultat attendu:**
```
✅ Suppression fonctionnelle
✅ Confirmation demandée
✅ Produit supprimé
```

---

## 📱 Phase 5: Tests eSIM

### Test 5.1: Liste des Plans eSIM
**Durée estimée:** 10 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/esim
   ```

2. **Vérifier l'affichage**
   - [ ] Liste des plans disponibles
   - [ ] Cartes de produits
   - [ ] Filtres par pays/région
   - [ ] Barre de recherche

3. **Vérifier chaque carte de plan**
   - [ ] Nom du pays/région
   - [ ] Drapeau ou icône
   - [ ] Durée de validité
   - [ ] Quantité de données
   - [ ] Prix
   - [ ] Bouton "Ajouter au panier"

4. **Tester les filtres**
   - Filtrer par région (Europe, Asie, etc.)
   - [ ] Plans filtrés correctement
   - Filtrer par prix
   - [ ] Tri par prix fonctionnel

5. **Tester la recherche**
   - Rechercher "France"
   - [ ] Plans pour la France affichés
   - Rechercher "Global"
   - [ ] Plans globaux affichés

**Résultat attendu:**
```
✅ Plans eSIM affichés
✅ Filtres fonctionnels
✅ Recherche fonctionnelle
✅ Design attractif
```

**Screenshot à prendre:**
- Liste des plans eSIM
- Carte de plan détaillée

---

### Test 5.2: Panier (CartDrawer)
**Durée estimée:** 10 minutes

1. **Ajouter au panier**
   - Choisir un plan eSIM
   - Cliquer sur "Ajouter au panier"
   - [ ] Animation de confirmation
   - [ ] Badge du panier mis à jour
   - [ ] Message de succès

2. **Ouvrir le panier**
   - Cliquer sur l'icône panier
   - [ ] Drawer s'ouvre depuis la droite
   - [ ] Animation fluide
   - [ ] Produits affichés

3. **Vérifier le contenu**
   - [ ] Image du produit
   - [ ] Nom du produit
   - [ ] Prix unitaire
   - [ ] Quantité
   - [ ] Boutons +/-
   - [ ] Bouton supprimer
   - [ ] Sous-total
   - [ ] Total

4. **Modifier la quantité**
   - Cliquer sur "+"
   - [ ] Quantité augmente
   - [ ] Prix mis à jour
   - [ ] Total mis à jour
   - Cliquer sur "-"
   - [ ] Quantité diminue
   - [ ] Prix mis à jour

5. **Supprimer un article**
   - Cliquer sur l'icône supprimer
   - [ ] Article retiré
   - [ ] Total mis à jour
   - [ ] Animation de suppression

6. **Ajouter plusieurs articles**
   - Ajouter 2-3 plans différents
   - [ ] Tous affichés dans le panier
   - [ ] Total correct

7. **Fermer le panier**
   - Cliquer sur "X"
   - [ ] Drawer se ferme
   - Rouvrir
   - Cliquer en dehors
   - [ ] Drawer se ferme

**Résultat attendu:**
```
✅ Panier fonctionnel
✅ Ajout/Suppression fonctionnels
✅ Calculs corrects
✅ Animations fluides
```

**Screenshot à prendre:**
- CartDrawer ouvert
- Panier avec plusieurs articles

---

### Test 5.3: Paiement (PaymentModal)
**Durée estimée:** 10 minutes

1. **Ouvrir le modal de paiement**
   - Avec des articles dans le panier
   - Cliquer sur "Procéder au paiement"
   - [ ] Modal s'ouvre
   - [ ] Formulaire Stripe chargé

2. **Vérifier le formulaire**
   - [ ] Récapitulatif de la commande
   - [ ] Liste des articles
   - [ ] Total
   - [ ] Formulaire de carte bancaire (Stripe)
   - [ ] Bouton "Payer"

3. **Tester avec carte de test Stripe**
   ```
   Numéro: 4242 4242 4242 4242
   Date: 12/25
   CVC: 123
   ```
   - Entrer les informations
   - [ ] Validation en temps réel
   - Cliquer sur "Payer"
   - [ ] Loading state
   - [ ] Message de succès
   - [ ] Redirection appropriée
   - [ ] Panier vidé

4. **Tester avec carte refusée**
   ```
   Numéro: 4000 0000 0000 0002
   ```
   - [ ] Message d'erreur Stripe
   - [ ] Pas de redirection
   - [ ] Possibilité de réessayer

**Résultat attendu:**
```
✅ Intégration Stripe fonctionnelle
✅ Paiement test réussi
✅ Gestion des erreurs
✅ Redirection après paiement
```

**⚠️ IMPORTANT:** Utiliser uniquement les cartes de test Stripe!

---

## 📦 Phase 6: Tests des Commandes

### Test 6.1: Liste des Commandes
**Durée estimée:** 10 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/orders
   ```

2. **Vérifier l'affichage**
   - [ ] Liste des commandes
   - [ ] Table avec colonnes:
     - [ ] Numéro de commande
     - [ ] Date
     - [ ] Client
     - [ ] Produits
     - [ ] Montant
     - [ ] Statut
     - [ ] Actions

3. **Vérifier les statuts**
   - [ ] Badges de statut colorés:
     - [ ] En attente (jaune)
     - [ ] Confirmée (bleu)
     - [ ] Expédiée (violet)
     - [ ] Livrée (vert)
     - [ ] Annulée (rouge)

4. **Tester les filtres**
   - Filtrer par statut "En attente"
   - [ ] Seules les commandes en attente affichées
   - Filtrer par date
   - [ ] Commandes filtrées par période

5. **Tester la recherche**
   - Rechercher par numéro de commande
   - [ ] Commande trouvée
   - Rechercher par nom de client
   - [ ] Commandes du client affichées

6. **Voir les détails**
   - Cliquer sur une commande
   - [ ] Modal ou page de détails
   - [ ] Informations complètes:
     - [ ] Produits commandés
     - [ ] Adresse de livraison
     - [ ] Historique des statuts
     - [ ] Informations de paiement

**Résultat attendu:**
```
✅ Liste des commandes affichée
✅ Filtres fonctionnels
✅ Recherche fonctionnelle
✅ Détails accessibles
```

---

## 👥 Phase 7: Tests Fournisseurs et Clients

### Test 7.1: Fournisseurs
**Durée estimée:** 10 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/suppliers
   ```

2. **Tester les fonctionnalités**
   - [ ] Liste des fournisseurs
   - [ ] Ajouter un fournisseur
   - [ ] Éditer un fournisseur
   - [ ] Supprimer un fournisseur
   - [ ] Recherche
   - [ ] Pagination

3. **Ajouter un fournisseur test**
   ```
   Nom: Fournisseur Test QA
   Email: supplier-test@example.com
   Téléphone: +33 1 23 45 67 89
   Adresse: 123 Rue Test, Paris
   ```
   - [ ] Ajout réussi
   - [ ] Apparaît dans la liste

**Résultat attendu:**
```
✅ CRUD complet fonctionnel
✅ Validations actives
```

---

### Test 7.2: Clients
**Durée estimée:** 10 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/customers
   ```

2. **Tester les fonctionnalités**
   - [ ] Liste des clients
   - [ ] Détails d'un client
   - [ ] Historique des commandes
   - [ ] Recherche
   - [ ] Filtres
   - [ ] Export (si disponible)

3. **Voir les détails d'un client**
   - Cliquer sur un client
   - [ ] Informations personnelles
   - [ ] Commandes passées
   - [ ] Montant total dépensé
   - [ ] Dernière commande

**Résultat attendu:**
```
✅ Liste des clients affichée
✅ Détails accessibles
✅ Historique visible
```

---

## 📢 Phase 8: Tests des Publicités

### Test 8.1: Campagnes Publicitaires
**Durée estimée:** 10 minutes

1. **Accéder à la page**
   ```
   URL: http://localhost:3001/ads
   ```

2. **Vérifier l'affichage**
   - [ ] Liste des campagnes
   - [ ] Statistiques par campagne
   - [ ] Bouton "Créer une campagne"

3. **Créer une campagne test**
   ```
   Nom: Campagne Test QA
   Budget: 1000€
   Durée: 7 jours
   Cible: France
   ```
   - [ ] Création réussie
   - [ ] Campagne affichée

4. **Tester les actions**
   - [ ] Activer/Désactiver
   - [ ] Éditer
   - [ ] Voir les statistiques
   - [ ] Supprimer

**Résultat attendu:**
```
✅ Gestion des campagnes fonctionnelle
✅ Statistiques affichées
```

---

## 📱 Phase 9: Tests Responsive

### Test 9.1: Mobile (375px - iPhone SE)
**Durée estimée:** 15 minutes

1. **Activer le mode mobile**
   - F12 → Toggle device toolbar (Ctrl+Shift+M)
   - Sélectionner "iPhone SE"

2. **Tester toutes les pages**

   Pour chaque page:
   - [ ] Pas de débordement horizontal
   - [ ] Texte lisible
   - [ ] Boutons accessibles
   - [ ] Images adaptées
   - [ ] Formulaires utilisables

3. **Tester le menu burger**
   - [ ] Icône burger visible
   - [ ] Cliquer ouvre la sidebar
   - [ ] Sidebar en overlay
   - [ ] Fermeture fonctionnelle
   - [ ] Navigation fonctionnelle

4. **Tester les tables**
   - [ ] Scroll horizontal
   - [ ] Colonnes lisibles
   - [ ] Actions accessibles

5. **Tester les formulaires**
   - [ ] Champs empilés verticalement
   - [ ] Clavier mobile approprié
   - [ ] Validation visible

**Résultat attendu:**
```
✅ Application utilisable sur mobile
✅ Menu burger fonctionnel
✅ Pas de problèmes d'affichage
```

**Screenshot à prendre:**
- Chaque page en mode mobile
- Menu burger ouvert

---

### Test 9.2: Tablet (768px - iPad)
**Durée estimée:** 10 minutes

1. **Activer le mode tablet**
   - Sélectionner "iPad"

2. **Vérifier l'adaptation**
   - [ ] Layout adapté
   - [ ] Sidebar visible ou collapsible
   - [ ] Grille de cards (2 colonnes)
   - [ ] Tables lisibles
   - [ ] Navigation tactile

**Résultat attendu:**
```
✅ Application adaptée pour tablette
✅ Layout optimisé
```

---

### Test 9.3: Desktop Large (1920px)
**Durée estimée:** 5 minutes

1. **Tester sur grand écran**
   - Responsive → 1920x1080

2. **Vérifier**
   - [ ] Utilisation optimale de l'espace
   - [ ] Pas d'étirement excessif
   - [ ] Sidebar fixe
   - [ ] Grille de cards (3-4 colonnes)
   - [ ] Tables complètes

**Résultat attendu:**
```
✅ Application optimisée pour grand écran
✅ Bon usage de l'espace
```

---

## 🔍 Phase 10: Tests de Performance

### Test 10.1: Console et Erreurs
**Durée estimée:** 15 minutes

1. **Ouvrir DevTools**
   - F12 → Console

2. **Naviguer dans l'application**
   - Visiter toutes les pages
   - Effectuer des actions
   - Observer la console

3. **Vérifier**
   - [ ] Aucune erreur rouge
   - [ ] Pas de warnings critiques
   - [ ] Pas d'erreurs réseau
   - [ ] Pas de 404

4. **Onglet Network**
   - F12 → Network
   - [ ] Toutes les requêtes en 200
   - [ ] Pas de requêtes échouées
   - [ ] Temps de réponse acceptables

5. **Onglet Performance**
   - F12 → Performance
   - Enregistrer une session
   - [ ] Pas de longs tasks
   - [ ] FPS stable
   - [ ] Pas de memory leaks

**Résultat attendu:**
```
✅ Aucune erreur console
✅ Toutes les requêtes réussies
✅ Performance acceptable
```

---

### Test 10.2: Lighthouse Audit
**Durée estimée:** 10 minutes

1. **Lancer Lighthouse**
   - F12 → Lighthouse
   - Cocher: Performance, Accessibility, Best Practices, SEO
   - Cliquer sur "Analyze page load"

2. **Vérifier les scores**
   - [ ] Performance > 80
   - [ ] Accessibility > 90
   - [ ] Best Practices > 90
   - [ ] SEO > 80

3. **Noter les recommandations**
   - Lire les suggestions
   - Documenter les améliorations possibles

**Résultat attendu:**
```
✅ Scores Lighthouse acceptables
✅ Recommandations documentées
```

---

## 📊 Rapport de Test

### Template de Rapport

Après avoir effectué tous les tests, remplir ce template:

```markdown
# Rapport de Test Manuel - DXB Connect

**Date:** [Date]
**Testeur:** [Nom]
**Durée:** [Durée totale]

## Résumé

- Tests effectués: X/Y
- Tests réussis: X
- Tests échoués: X
- Bugs trouvés: X

## Bugs Trouvés

### Bug #1: [Titre]
- **Priorité:** 🔴 Critique / 🟠 Haute / 🟡 Moyenne / 🟢 Basse
- **Page:** /chemin
- **Description:** [Description]
- **Étapes:**
  1. ...
  2. ...
- **Attendu:** ...
- **Actuel:** ...
- **Screenshot:** [Lien]

## Améliorations Suggérées

1. ...
2. ...

## Conclusion

[Verdict final]
```

---

## 🎯 Checklist Finale

Avant de conclure les tests:

### Fonctionnalités
- [ ] Authentification complète
- [ ] Navigation fonctionnelle
- [ ] CRUD produits
- [ ] Panier et paiement
- [ ] Commandes
- [ ] Fournisseurs
- [ ] Clients
- [ ] Publicités

### Qualité
- [ ] Aucune erreur console
- [ ] Toutes les pages accessibles
- [ ] Responsive sur tous les devices
- [ ] Performance acceptable
- [ ] Lighthouse > 80

### Documentation
- [ ] Screenshots pris
- [ ] Bugs documentés
- [ ] Rapport rédigé
- [ ] Recommandations listées

---

## 📞 Support

Si vous rencontrez des problèmes pendant les tests:

1. Vérifier les logs serveur
2. Vérifier la console navigateur
3. Vérifier les variables d'environnement
4. Consulter la documentation
5. Créer une issue GitHub

---

**Bon courage pour les tests! 🚀**
