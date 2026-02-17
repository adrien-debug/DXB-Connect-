# 🔌 Configuration des Ports - Règle Absolue

**Date:** 17 Février 2026
**Règle:** Tous les services utilisent des ports 4000+

---

## 📋 Attribution des Ports

### Applications

| Service | Port | URL | Status |
|---------|------|-----|--------|
| **DXB Client (Next.js)** | 4000 | http://localhost:4000 | ✅ Configuré |
| **DXB Admin** | 4001 | http://localhost:4001 | 📝 À configurer |
| **Backend API** | 4002 | http://localhost:4002 | 📝 À configurer |
| **Storybook** | 4003 | http://localhost:4003 | 📝 Réservé |
| **Tests E2E** | 4004 | http://localhost:4004 | 📝 Réservé |

### Bases de données (locales)

| Service | Port | Status |
|---------|------|--------|
| PostgreSQL | 5432 | Standard |
| Redis | 6379 | Standard |

---

## 🎯 Règle Absolue

```bash
# RÈGLE: Tous les serveurs web utilisent 4000+
# - 4000: DXB Client (Next.js)
# - 4001: DXB Admin
# - 4002: Backend API
# - 4003+: Services additionnels
```

---

## 🚀 Configuration

### DXB Client (Next.js)

**Fichier:** `Apps/DXBClient/package.json`

```json
{
  "scripts": {
    "dev": "next dev -p 4000",
    "start": "next start -p 4000"
  }
}
```

**Commandes:**
```bash
cd Apps/DXBClient
npm run dev     # → http://localhost:4000
npm run start   # → http://localhost:4000
```

### Capacitor Config

**Fichier:** `Apps/DXBClient/capacitor.config.ts`

```typescript
server: {
  url: 'http://localhost:4000',  // Dev local
  cleartext: true
}
```

---

## 🔧 Commandes Utiles

### Vérifier les ports utilisés

```bash
# Voir tous les ports 4000+
lsof -i :4000-4010

# Port spécifique
lsof -i :4000

# Tuer un port
lsof -ti:4000 | xargs kill -9
```

### Démarrer tous les services

```bash
# 1. DXB Client
cd Apps/DXBClient && npm run dev &

# 2. DXB Admin (quand configuré)
# cd Apps/DXBAdmin && npm run dev &

# 3. Backend API (quand configuré)
# cd Backend && npm start &
```

---

## 📝 Checklist Migration

### DXB Client ✅
- [x] package.json modifié (port 4000)
- [x] Scripts dev/start mis à jour
- [ ] capacitor.config.ts à mettre à jour
- [ ] .env.local à vérifier
- [ ] Documentation mise à jour

### DXB Admin ⏳
- [ ] package.json à modifier (port 4001)
- [ ] Scripts à mettre à jour
- [ ] Variables d'environnement

### Backend API ⏳
- [ ] Configuration port 4002
- [ ] CORS à mettre à jour
- [ ] Variables d'environnement

---

## 🐛 Troubleshooting

### Port déjà utilisé

```bash
# Erreur: EADDRINUSE: address already in use :::4000

# Solution:
lsof -ti:4000 | xargs kill -9
npm run dev
```

### Vérifier qu'un service tourne

```bash
curl http://localhost:4000
# → Doit retourner du HTML
```

### Logs en temps réel

```bash
# Next.js
tail -f .next/trace

# Ou voir le terminal
# Terminal ID visible dans les logs
```

---

## 🎯 Avantages de cette Configuration

### ✅ Clarté
- Ports prévisibles et organisés
- Facile à mémoriser (4000, 4001, 4002...)
- Pas de conflit avec services système

### ✅ Développement
- Tous les services peuvent tourner en parallèle
- Facile de switcher entre apps
- URLs claires dans le code

### ✅ Documentation
- Ports documentés centralement
- Facile pour nouveaux développeurs
- Moins d'erreurs de configuration

---

## 📄 Fichiers Modifiés

```
Apps/DXBClient/
└── package.json           ✅ Port 4000 configuré

À modifier:
├── capacitor.config.ts    ⏳ Mettre url: localhost:4000
└── .env.local            ⏳ Vérifier NEXT_PUBLIC_API_URL
```

---

**🎉 Configuration des ports terminée !**

**Prochaine étape:** Démarrer sur le nouveau port 4000
