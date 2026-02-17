# Architecture Railway - DXB Connect

## 🚂 Règle Absolue

**TOUT passe par Railway Backend. Aucune exception.**

```
┌─────────────────────────────────────────────────┐
│         Architecture DXB Connect                 │
├─────────────────────────────────────────────────┤
│                                                  │
│  📱 iOS SwiftUI          💻 Next.js Admin       │
│       │                         │                │
│       │                         │                │
│       └──────────┬──────────────┘                │
│                  │                               │
│                  ▼                               │
│         🚂 Railway Backend                       │
│         (Next.js API)                            │
│         Port: 4000                               │
│         URL: web-production-14c51.up.railway.app │
│                  │                               │
│                  ├──► 📊 Supabase               │
│                  │     (Database + Auth)         │
│                  │                               │
│                  └──► 📡 eSIM Access API         │
│                        (Provider externe)        │
│                                                  │
│  👤 Client Final                                 │
│  └─► Achète et utilise via iOS/Web              │
│                                                  │
└─────────────────────────────────────────────────┘
```

## ❌ Strictement Interdit

1. **Connexion directe iOS → Supabase**
2. **Connexion directe iOS → eSIM Access API**
3. **Connexion directe Next.js → Supabase** (sauf via Railway)
4. **Connexion directe Next.js → eSIM Access API** (sauf via Railway)
5. **Bypasser Railway** pour quelque raison que ce soit

## ✅ Configuration Obligatoire

### iOS SwiftUI - Config.swift

```swift
// Production (NE JAMAIS CHANGER)
case .production:
    return URL(string: "https://web-production-14c51.up.railway.app/api")!

// Development (Railway local)
case .development:
    return URL(string: "http://localhost:4000/api")!
```

### Next.js Admin - Variables d'environnement

```env
# Railway Backend (SEUL point d'entrée)
NEXT_PUBLIC_RAILWAY_URL=https://web-production-14c51.up.railway.app

# Development
NEXT_PUBLIC_API_URL=http://localhost:4000/api

# Supabase (côté serveur Railway uniquement)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxx

# eSIM Access (côté serveur Railway uniquement)
ESIM_ACCESS_CODE=xxx
ESIM_SECRET_KEY=xxx
```

### Railway Backend - Connexions

```typescript
// Railway → Supabase
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Railway → eSIM Access API
const esimAPI = new ESIMAccessClient({
  accessCode: process.env.ESIM_ACCESS_CODE,
  secretKey: process.env.ESIM_SECRET_KEY,
});
```

## 🔄 Flux de Données

### Exemple: Achat eSIM

```
1. Client (iOS/Web)
   └─► POST https://web-production-14c51.up.railway.app/api/esim/purchase
       Headers: { Authorization: Bearer <token> }
       Body: { packageCode: "xxx", quantity: 1 }

2. Railway Backend
   ├─► Vérifie token avec Supabase
   ├─► Valide données (Zod)
   ├─► Appelle eSIM Access API
   ├─► Enregistre commande dans Supabase
   └─► Retourne résultat au client

3. Client reçoit
   └─► { orderNo, iccid, qrCodeUrl, lpaCode }
```

### Exemple: Liste Packages

```
1. Client (iOS/Web)
   └─► GET https://web-production-14c51.up.railway.app/api/esim/packages

2. Railway Backend
   ├─► Check cache (optionnel)
   ├─► Appelle eSIM Access API
   ├─► Transforme données (format iOS/Web)
   └─► Retourne packages au client

3. Client reçoit
   └─► [{ id, name, dataGB, priceUSD, ... }]
```

## 🔐 Sécurité

### Headers Requis (Client → Railway)

```typescript
headers: {
  'Authorization': `Bearer ${supabaseToken}`,
  'Content-Type': 'application/json',
  'X-Client-Platform': 'iOS' | 'Web',
  'X-Client-Version': '1.0.0',
}
```

### Validation Railway

```typescript
export async function POST(request: Request) {
  // 1. Auth (via Supabase)
  const { user, error } = await requireAuthFlexible(request);
  if (error) return NextResponse.json({ error }, { status: 401 });

  // 2. Validation
  const validated = schema.parse(await request.json());

  // 3. Vérification ownership
  const { data } = await supabase
    .from('table')
    .select()
    .eq('user_id', user.id)  // ✅ CRITIQUE
    .single();

  // 4. Logique métier
  const result = await esimAPI.call(validated);

  // 5. Enregistrement
  await supabase.from('esim_orders').insert({
    user_id: user.id,
    ...result,
  });

  return NextResponse.json({ data: result });
}
```

## 📋 Endpoints Railway

Tous les endpoints passent par Railway :

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/auth/apple` | POST | Auth Apple (iOS) |
| `/api/auth/email/send-otp` | POST | Envoi OTP |
| `/api/auth/email/verify` | POST | Vérification OTP |
| `/api/esim/packages` | GET | Liste packages |
| `/api/esim/orders` | GET | Commandes user |
| `/api/esim/purchase` | POST | Achat eSIM |
| `/api/esim/balance` | GET | Balance marchand |
| `/api/esim/query` | GET | Statut eSIM |
| `/api/esim/usage` | GET | Utilisation data |
| `/api/esim/topup` | POST | Recharge eSIM |
| `/api/esim/cancel` | POST | Annulation |
| `/api/esim/suspend` | POST | Suspension |
| `/api/esim/revoke` | POST | Révocation |
| `/api/checkout` | POST | Paiement Stripe |
| `/api/webhooks/stripe` | POST | Webhook Stripe |
| `/api/webhooks/esim` | POST | Webhook eSIM |

**Base URL Production** : `https://web-production-14c51.up.railway.app`

## 🎯 Rôles Clairs

| Composant | Rôle | Communique avec |
|-----------|------|-----------------|
| **iOS App** | Interface mobile client | Railway UNIQUEMENT |
| **Next.js Web** | Dashboard admin | Railway UNIQUEMENT |
| **Railway Backend** | API centrale | Supabase + eSIM API |
| **Supabase** | Database + Auth | Railway UNIQUEMENT |
| **eSIM Access API** | Provider eSIM | Railway UNIQUEMENT |
| **Client Final** | Utilisateur | iOS/Web Apps |

## ⚠️ Pourquoi Cette Architecture ?

### Avantages

1. **Sécurité** : Secrets jamais exposés côté client
2. **Contrôle** : Toute logique métier centralisée
3. **Monitoring** : Un seul point à surveiller
4. **Flexibilité** : Changer provider sans modifier clients
5. **Validation** : Données validées avant traitement
6. **Audit** : Logs centralisés sur Railway
7. **RLS** : Row Level Security Supabase respectée

### Risques si on bypasse

1. ❌ **Secrets exposés** : Clés API dans le code client
2. ❌ **Sécurité compromise** : Pas de validation serveur
3. ❌ **Spoofing** : Client peut modifier user_id
4. ❌ **Maintenance** : Logique dupliquée iOS/Web
5. ❌ **Audit impossible** : Actions non tracées
6. ❌ **RLS contourné** : Accès non autorisés

## 🚨 Si Quelqu'un Propose de Changer

**Question** : "Et si on connectait directement iOS à Supabase pour optimiser ?"

**Réponse** : **NON. Architecture Railway non négociable.**

Raisons :
- Expose les secrets Supabase côté client
- Contourne la validation serveur
- Rend l'audit impossible
- Compromet la sécurité RLS
- Duplique la logique métier

## 📝 Checklist Développement

Avant toute modification :

- [ ] La modification respecte l'architecture Railway ?
- [ ] Aucune connexion directe client → Supabase ?
- [ ] Aucune connexion directe client → eSIM API ?
- [ ] Toutes les requêtes passent par Railway ?
- [ ] Les secrets restent côté Railway ?
- [ ] Les logs ne contiennent pas de données sensibles ?

## 🔧 Développement Local

### Démarrer Railway en local

```bash
cd Apps/DXBClient
npm run dev  # Port 4000
```

### Tester iOS avec Railway local

```swift
// DXBClientApp.swift
#if DEBUG
APIConfig.current = .development  // localhost:4000
#endif
```

### Tester Next.js avec Railway local

```env
NEXT_PUBLIC_API_URL=http://localhost:4000/api
```

## 📊 Monitoring

### Logs Railway

```bash
# Voir logs Railway
railway logs

# Suivre en temps réel
railway logs --follow
```

### Métriques importantes

- Nombre de requêtes par endpoint
- Temps de réponse moyen
- Taux d'erreur
- Utilisation CPU/RAM
- Connexions Supabase actives

## 🎯 Conclusion

**Railway Backend est le cœur de DXB Connect.**

Toute modification qui contourne Railway est **strictement interdite**.

Cette architecture garantit :
- ✅ Sécurité maximale
- ✅ Contrôle total
- ✅ Maintenance simplifiée
- ✅ Audit complet
- ✅ Évolutivité

**Ne jamais dévier de cette architecture.**
