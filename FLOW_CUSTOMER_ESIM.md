# Flow Customer eSIM - App iOS

## 📱 Parcours Client Complet

### 1️⃣ Découverte & Sélection

**Vue** : `PlanListView` (Explore - Tab 1)

```
┌─────────────────────────────────────┐
│  EXPLORE                            │
│  20 eSIMs disponibles               │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🇦🇪 United Arab Emirates     │ │
│  │ 100 MB • #536623              │ │
│  │ [AVAILABLE]                   │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🇦🇪 United Arab Emirates     │ │
│  │ 2 GB • #658149                │ │
│  │ [AVAILABLE]                   │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Actions** :
- User browse les plans disponibles
- Filtre par data (All, 100MB, 1GB, 2GB)
- Clique sur un plan → `PlanDetailView`

**API** : `GET /api/esim/stock`
- Retourne les eSIMs disponibles à la vente
- Filtrées : `smdpStatus=RELEASED` + non attribuées

---

### 2️⃣ Détails du Plan

**Vue** : `PlanDetailView`

```
┌─────────────────────────────────────┐
│  ← PLAN DETAILS                     │
│                                     │
│      🇦🇪                            │
│                                     │
│  United Arab Emirates               │
│  Dubai Starter                      │
│                                     │
│  ┌───────────────────────────────┐ │
│  │        $9.99                  │ │
│  │    ONE-TIME PAYMENT           │ │
│  └───────────────────────────────┘ │
│                                     │
│  📡 DATA      📅 DURATION           │
│  5 GB         7 days                │
│                                     │
│  ⚡ SPEED     🌍 COVERAGE           │
│  4G/LTE       UAE                   │
│                                     │
│  INCLUDED                           │
│  ✓ Instant activation               │
│  ✓ 24/7 support                     │
│  ✓ No roaming fees                  │
│  ✓ Keep your number                 │
│                                     │
│  ─────────────────────────────────  │
│  TOTAL          [BUY NOW →]         │
│  $9.99                              │
└─────────────────────────────────────┘
```

**Actions** :
- User voit les détails du plan
- User clique "BUY NOW" → `PaymentSheetView`

---

### 3️⃣ Paiement

**Vue** : `PaymentSheetView` (Modal)

```
┌─────────────────────────────────────┐
│  ━━                                 │
│  CHECKOUT                           │
│  United Arab Emirates               │  ✕
│                                     │
│  ORDER SUMMARY                      │
│  ┌───────────────────────────────┐ │
│  │ Dubai Starter        $9.99    │ │
│  │ 5 GB • 7 days                 │ │
│  │ ─────────────────────────────  │ │
│  │ Total               $9.99     │ │
│  └───────────────────────────────┘ │
│                                     │
│  PAYMENT METHOD                     │
│  ┌───────────────────────────────┐ │
│  │    🍎 Apple Pay               │ │
│  └───────────────────────────────┘ │
│                                     │
│           or                        │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 💳 Pay with Card              │ │
│  └───────────────────────────────┘ │
│                                     │
│  🔒 Secured by Stripe              │
└─────────────────────────────────────┘
```

**Actions** :
1. User choisit méthode de paiement (Apple Pay ou Card)
2. **Apple Pay** :
   - Présente la sheet Apple Pay native
   - User authentifie (Face ID / Touch ID)
   - Récupère `paymentToken` + `paymentNetwork`
3. **Card** :
   - Pour l'instant : appel direct à `purchasePlan`
   - TODO : Intégrer Stripe SDK pour saisie carte

**API** : `POST /api/esim/purchase`
```json
{
  "planId": "UAE_5GB_7D",
  "paymentMethod": "apple_pay",
  "paymentToken": "base64_token...",
  "paymentNetwork": "visa"
}
```

**Backend Flow** :
```
1. Railway Backend reçoit la requête
2. Crée l'eSIM dans esim_orders avec status = 'PENDING_PAYMENT'
3. Appelle Stripe pour traiter le paiement
4. Si succès immédiat → status = 'RELEASED'
5. Si async → Webhook Stripe confirmera plus tard
6. Retourne l'eSIM au client
```

---

### 4️⃣ Confirmation de Paiement

**Vue** : `PaymentSuccessView` (Fullscreen)

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│           ⭕⭕⭕                      │
│            ⭕⭕                       │
│             ⭕                        │
│            ✓                        │
│                                     │
│  Payment Successful!                │
│  Your eSIM is being activated       │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Dubai Starter        5 GB     │ │
│  │ United Arab Emirates  7 days  │ │
│  │ ─────────────────────────────  │ │
│  │ Total Paid          $9.99     │ │
│  └───────────────────────────────┘ │
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   VIEW MY eSIMs →             │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Actions** :
- Animation de succès (checkmark + pulse)
- User clique "VIEW MY eSIMs" → Redirigé vers `MyESIMsView` (Tab 2)
- `coordinator.loadESIMs()` est appelé pour rafraîchir la liste

---

### 5️⃣ Mes eSIMs

**Vue** : `MyESIMsView` (Tab 2)

```
┌─────────────────────────────────────┐
│  MY eSIMs                           │
│  All | Active | Expired             │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📶 Dubai Starter              │ │
│  │ 5 GB • Expires 2024-12-31     │ │
│  │ [ACTIVE]                      │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📶 UAE Premium                │ │
│  │ 10 GB • Expires 2024-11-15    │ │
│  │ [IN USE]                      │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Actions** :
- User voit UNIQUEMENT ses eSIMs achetées
- Filtre par statut (All, Active, Expired)
- Clique sur une eSIM → `ESIMDetailView`

**API** : `GET /api/esim/orders`
- Retourne UNIQUEMENT les eSIMs de l'utilisateur
- Filtrées par `user_id` dans Supabase
- Si nouveau user → retourne liste vide (PAS tout le stock!)

---

### 6️⃣ Détails de l'eSIM

**Vue** : `ESIMDetailView`

#### 🔴 CAS 1 : Paiement en cours (PENDING_PAYMENT, PROCESSING)

```
┌─────────────────────────────────────┐
│  ← ESIM DETAILS                     │
│                                     │
│  [PENDING PAYMENT]                  │
│                                     │
│  ┌───────────────────────────────┐ │
│  │                               │ │
│  │         🕐                    │ │
│  │  Payment Processing           │ │
│  │                               │ │
│  │  Your QR code will appear     │ │
│  │  once payment is confirmed    │ │
│  │                               │ │
│  │  This usually takes a few     │ │
│  │  seconds                      │ │
│  └───────────────────────────────┘ │
│                                     │
│  PACKAGE                            │
│  ┌───────────────────────────────┐ │
│  │ 📶 Dubai Starter              │ │
│  │ 5 GB                          │ │
│  │ EXPIRES: 2024-12-31           │ │
│  │ ORDER: #123456                │ │
│  └───────────────────────────────┘ │
│                                     │
│  TECHNICAL INFO                     │
│  ┌───────────────────────────────┐ │
│  │ ICCID: 890123...      [📋]    │ │
│  │ LPA Code: LPA:1$...   [📋]    │ │
│  │ Order No: ORD123...   [📋]    │ │
│  └───────────────────────────────┘ │
│                                     │
│  ⚠️ QR Code et instructions        │
│     cachés jusqu'à confirmation     │
└─────────────────────────────────────┘
```

**Règle** :
```swift
private var isPaymentConfirmed: Bool {
    let confirmedStatuses = ["RELEASED", "IN_USE", "SUSPENDED", "EXPIRED"]
    return confirmedStatuses.contains(order.status.uppercased())
}
```

---

#### ✅ CAS 2 : Paiement confirmé (RELEASED, IN_USE, SUSPENDED, EXPIRED)

```
┌─────────────────────────────────────┐
│  ← ESIM DETAILS                     │
│                                     │
│  [ACTIVE]                           │
│                                     │
│  ┌───────────────────────────────┐ │
│  │                               │ │
│  │     ▓▓▓▓▓▓▓▓▓▓▓▓▓             │ │
│  │     ▓▓ QR CODE ▓▓             │ │
│  │     ▓▓▓▓▓▓▓▓▓▓▓▓▓             │ │
│  │                               │ │
│  │  Scan to install eSIM         │ │
│  └───────────────────────────────┘ │
│                                     │
│  PACKAGE                            │
│  ┌───────────────────────────────┐ │
│  │ 📶 Dubai Starter              │ │
│  │ 5 GB                          │ │
│  │ EXPIRES: 2024-12-31           │ │
│  │ ORDER: #123456                │ │
│  └───────────────────────────────┘ │
│                                     │
│  TECHNICAL INFO                     │
│  ┌───────────────────────────────┐ │
│  │ ICCID: 890123...      [📋]    │ │
│  │ LPA Code: LPA:1$...   [📋]    │ │
│  │ Order No: ORD123...   [📋]    │ │
│  └───────────────────────────────┘ │
│                                     │
│  INSTALLATION                       │
│  ┌───────────────────────────────┐ │
│  │ ① Go to Settings → Cellular   │ │
│  │ ② Tap 'Add eSIM'              │ │
│  │ ③ Scan the QR code above      │ │
│  │ ④ Follow instructions         │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Actions** :
- User voit le QR Code (chargé depuis `order.qrCodeUrl`)
- User peut copier ICCID, LPA Code, Order No
- User suit les instructions d'installation
- User scanne le QR Code avec son téléphone

---

## 🔄 Flow Backend Complet

### Étape 1 : Achat Initial

```
iOS App
  └─► POST /api/esim/purchase
      └─► Railway Backend
          ├─► 1. Vérifier auth (Bearer token)
          ├─► 2. Valider plan existe
          ├─► 3. Créer payment Stripe
          ├─► 4. Si succès immédiat:
          │       └─► Appeler eSIM Access API
          │           └─► Récupérer QR Code + ICCID
          ├─► 5. Enregistrer dans Supabase:
          │       INSERT INTO esim_orders (
          │         user_id,
          │         order_no,
          │         iccid,
          │         status = 'RELEASED', -- si paiement immédiat
          │         qr_code_url,
          │         lpa_code,
          │         ...
          │       )
          └─► 6. Retourner eSIM au client
```

### Étape 2 : Webhook Stripe (si paiement async)

```
Stripe
  └─► POST /api/webhooks/stripe
      └─► Railway Backend
          ├─► 1. Vérifier signature Stripe
          ├─► 2. Si event = payment_intent.succeeded:
          │       └─► UPDATE esim_orders
          │           SET status = 'RELEASED'
          │           WHERE order_no = ?
          └─► 3. (Optionnel) Notifier client via push
```

### Étape 3 : Consultation

```
iOS App
  └─► GET /api/esim/orders
      └─► Railway Backend
          ├─► 1. Vérifier auth (Bearer token)
          ├─► 2. Query Supabase:
          │       SELECT * FROM esim_orders
          │       WHERE user_id = ?
          ├─► 3. Si 0 résultat:
          │       └─► Retourner { esimList: [], ... }
          └─► 4. Sinon:
                  └─► Filtrer eSIMs de l'API par ICCIDs
                      └─► Retourner liste eSIMs user
```

---

## 🔒 Règles de Sécurité

### 1. Affichage QR Code

```swift
// ✅ RÈGLE ABSOLUE
private var isPaymentConfirmed: Bool {
    let confirmedStatuses = ["RELEASED", "IN_USE", "SUSPENDED", "EXPIRED"]
    return confirmedStatuses.contains(order.status.uppercased())
}

// ❌ INTERDIT : Afficher QR Code avant confirmation paiement
// ✅ OBLIGATOIRE : Vérifier status avant affichage
```

### 2. Filtrage Backend

```typescript
// ✅ RÈGLE ABSOLUE : Filtrer par user_id
const { data: userOrders } = await supabase
  .from('esim_orders')
  .select('order_no, iccid')
  .eq('user_id', user.id)  // ← CRITIQUE

// ❌ INTERDIT : Retourner tout le stock si pas de commandes
if (!userOrders || userOrders.length === 0) {
  return NextResponse.json({
    success: true,
    obj: { esimList: [], orderList: [], pager: { total: 0 } }
  })
}
```

### 3. ID Unique

```swift
// ✅ RÈGLE ABSOLUE : Utiliser ICCID comme ID unique
id: esim.iccid ?? esim.orderNo ?? UUID().uuidString

// ❌ INTERDIT : orderNo peut être dupliqué
id: esim.orderNo ?? esim.esimTranNo ?? UUID().uuidString
```

---

## 📊 Statuts eSIM

| Statut | Description | QR Code Visible | Installation Possible |
|--------|-------------|-----------------|----------------------|
| `PENDING` | Commande créée, paiement en attente | ❌ | ❌ |
| `PENDING_PAYMENT` | Paiement en cours de traitement | ❌ | ❌ |
| `PROCESSING` | eSIM en cours de provisioning | ❌ | ❌ |
| `RELEASED` | eSIM prête à installer | ✅ | ✅ |
| `IN_USE` | eSIM installée et active | ✅ | ✅ (déjà installée) |
| `SUSPENDED` | eSIM suspendue temporairement | ✅ | ✅ (peut réactiver) |
| `EXPIRED` | eSIM expirée | ✅ | ❌ (pour référence) |
| `REVOKED` | eSIM révoquée (définitif) | ❌ | ❌ |
| `CANCELLED` | Commande annulée | ❌ | ❌ |

---

## 🧪 Tests

### Test 1 : Nouveau User

```bash
# 1. Créer un nouveau compte
# 2. Vérifier Dashboard : 0 eSIMs
# 3. Vérifier My eSIMs : 0 eSIMs
# 4. Vérifier Explore : 20+ eSIMs disponibles
```

### Test 2 : Achat eSIM

```bash
# 1. Sélectionner un plan dans Explore
# 2. Cliquer "BUY NOW"
# 3. Payer avec Apple Pay
# 4. Vérifier PaymentSuccessView s'affiche
# 5. Cliquer "VIEW MY eSIMs"
# 6. Vérifier l'eSIM apparaît dans My eSIMs
```

### Test 3 : QR Code Conditionnel

```bash
# 1. Acheter une eSIM
# 2. Si status = PENDING_PAYMENT :
#    → Vérifier écran "Payment Processing" s'affiche
#    → Vérifier QR Code est caché
#    → Vérifier instructions sont cachées
# 3. Une fois status = RELEASED :
#    → Vérifier QR Code s'affiche
#    → Vérifier instructions s'affichent
```

---

## 🚀 Déploiement

### Commit History

```bash
# Fix 1 : Backend - Filtrage par user_id
git log --oneline | grep "fix(orders)"
# 4c24bf9 fix(orders): secure filtering for esims, return empty for new users

# Fix 2 : iOS - ID unique avec ICCID
git log --oneline | grep "fix(ios)"
# 00a615b fix(ios): use ICCID as unique ID instead of orderNo

# Fix 3 : iOS - QR Code conditionnel
git log --oneline | grep "feat(ios)"
# 3bc3a16 feat(ios): hide QR code and installation guide until payment confirmed
```

### Tag Clean1

```bash
# Configuration validée et sauvegardée
git tag Clean1
git push origin Clean1
```

---

## 📝 Checklist Finale

- [x] Backend filtre par `user_id` (retourne 0 pour nouveau user)
- [x] iOS utilise ICCID comme ID unique (pas de doublons SwiftUI)
- [x] QR Code caché si `status != RELEASED/IN_USE/SUSPENDED/EXPIRED`
- [x] Instructions d'installation cachées si paiement non confirmé
- [x] Écran "Payment Processing" affiché pendant attente
- [x] Architecture Railway respectée (100%)
- [x] Documentation complète du flow
- [x] Tag Clean1 créé pour rollback

---

**Date** : 2026-02-18
**Version** : 1.0.0
**Status** : ✅ Validé en production
