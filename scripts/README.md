# Scripts DXB Connect

## 🎨 Synchronisation Figma

### `sync-figma-tokens.js`

Extrait les tokens de design depuis Figma et génère automatiquement :
- `Theme.generated.swift` (iOS SwiftUI)
- `tokens.generated.css` (Next.js Web)

**Usage :**

```bash
# 1. Créer un token Figma
# https://www.figma.com/developers/api#access-tokens

# 2. Ajouter à .env.local
echo "FIGMA_ACCESS_TOKEN=your_token" >> .env.local

# 3. Lancer la synchro
node scripts/sync-figma-tokens.js
```

**Sans token Figma :**

Le script fonctionne aussi sans token en utilisant les tokens hardcodés dans le fichier.

**Fichiers générés :**

- `Apps/DXBClient/Views/Theme.generated.swift`
- `Apps/DXBClient/src/styles/tokens.generated.css`

**⚠️ Important :**

- Ne pas modifier les fichiers `.generated.*` manuellement
- Toujours passer par Figma → Script → Génération
- Les fichiers générés sont à importer dans les fichiers principaux

## 🔄 Workflow Design → Code

```
Figma Design
    ↓
MCP Figma (Cursor)
    ↓
sync-figma-tokens.js
    ↓
Theme.generated.swift + tokens.generated.css
    ↓
Import dans Theme.swift + globals.css
    ↓
iOS App + Web App
```

## 📋 Checklist avant commit

- [ ] Tokens Figma à jour ?
- [ ] Script de sync lancé ?
- [ ] Fichiers `.generated.*` commités ?
- [ ] Tests iOS + Web OK ?
