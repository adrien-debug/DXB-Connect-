# 🎨 Figma MCP - Guide Rapide

## ✅ Configuration Terminée

La connexion Figma MCP est configurée et prête à l'emploi.

## 🚀 Utilisation Immédiate

### 1. Activer le Serveur MCP Figma

**Dans Cursor** :
1. Ouvrir les paramètres : `Cmd + ,`
2. Aller dans l'onglet **"MCP"**
3. Chercher **"figma-flysim"**
4. Cliquer sur **"Connect"**
5. Autoriser l'accès quand demandé

**Alternative** : Redémarrer Cursor (`Cmd + Q` puis relancer)

### 2. Commandes Disponibles (via Cursor Chat)

Une fois le serveur MCP activé, utilisez ces commandes :

```
"Récupère les variables de couleur depuis Figma"
"Montre-moi les composants Button dans Figma"
"Génère le code SwiftUI pour ce composant Figma"
"Compare les couleurs Figma vs Theme.swift"
"Extrait les tokens de spacing depuis Figma"
```

### 3. Synchroniser les Tokens de Design

**Commande** :
```bash
node scripts/sync-figma-tokens.js
```

**Génère** :
- `Apps/DXBClient/Views/Theme.generated.swift` (iOS)
- `Apps/DXBClient/src/styles/tokens.generated.css` (Web)

**Avec token Figma (optionnel)** :
```bash
# 1. Créer un token : https://www.figma.com/developers/api#access-tokens
# 2. Ajouter à .env.local
echo "FIGMA_ACCESS_TOKEN=your_token_here" >> .env.local

# 3. Relancer
node scripts/sync-figma-tokens.js
```

## 📋 Workflow Complet

### Ajouter une Nouvelle Couleur

1. **Dans Figma** : Ajouter la couleur dans Variables
2. **Mettre à jour** `scripts/sync-figma-tokens.js` :
   ```javascript
   colors: {
     // ...
     newColor: '#FF5733',
   }
   ```
3. **Synchroniser** : `node scripts/sync-figma-tokens.js`
4. **Utiliser** :
   ```swift
   // iOS
   .foregroundColor(AppTheme.newColor)
   ```
   ```css
   /* Web */
   color: var(--new-color);
   ```

### Créer un Nouveau Composant

1. **Designer dans Figma** avec les tokens existants
2. **Extraire via MCP** :
   ```
   "Génère le code SwiftUI pour le composant LoginCard"
   ```
3. **Adapter** le code généré avec vos tokens
4. **Tester** sur iOS + Web

## 🎯 Outils MCP Figma

| Outil | Description |
|-------|-------------|
| `get_design_context` | Contexte complet du design |
| `get_variable_defs` | Variables (couleurs, typo, spacing) |
| `get_code_connect_map` | Mapping composants Figma ↔ Code |
| `get_screenshot` | Captures d'écran des frames |

## 📁 Fichiers Créés

```
DXB Connect/
├── .cursor/
│   └── mcp.json                          # Config MCP locale (projet)
├── ~/.cursor/
│   └── mcp.json                          # Config MCP globale (avec Figma)
├── scripts/
│   ├── sync-figma-tokens.js              # Script de synchronisation
│   └── README.md                         # Doc scripts
├── .env.example                          # Template variables d'env
├── Apps/DXBClient/
│   ├── Views/
│   │   ├── Theme.swift                   # Theme actuel (manuel)
│   │   └── Theme.generated.swift         # ⚠️ À créer (auto-généré)
│   └── src/
│       ├── app/globals.css               # CSS actuel (manuel)
│       └── styles/
│           └── tokens.generated.css      # ⚠️ À créer (auto-généré)
└── FIGMA_QUICKSTART.md                   # Ce guide
```

## ⚠️ Règles Importantes

### ✅ OBLIGATOIRE

- Toujours utiliser les tokens de design
- Synchroniser après modifications Figma
- Ne JAMAIS modifier les fichiers `.generated.*` manuellement
- Passer par Figma pour tout changement de design

### ❌ INTERDIT

- Hardcoder des couleurs/spacing/radius
- Modifier `Theme.generated.swift` ou `tokens.generated.css`
- Créer de nouvelles couleurs sans les ajouter à Figma
- Ignorer les warnings de tokens manquants

## 🔧 Troubleshooting

### Le serveur MCP ne s'affiche pas

1. Vérifier `~/.cursor/mcp.json` contient `figma-flysim`
2. Redémarrer Cursor complètement
3. Vérifier les logs : `View > Developer > Toggle Developer Tools`

### Le script de sync échoue

```bash
# Vérifier Node.js
node --version  # Doit être >= 18

# Vérifier le script
cat scripts/sync-figma-tokens.js

# Lancer en mode debug
node --inspect scripts/sync-figma-tokens.js
```

### Les tokens ne sont pas à jour

1. Vérifier que les fichiers `.generated.*` existent
2. Relancer le script : `node scripts/sync-figma-tokens.js`
3. Vérifier les imports dans `Theme.swift` et `globals.css`

## 📚 Documentation Complète

- **Règle Cursor** : `.cursor/rules/06-figma-integration.mdc`
- **README Principal** : `README.md` (section Design System)
- **Scripts** : `scripts/README.md`
- **Figma Design** : https://www.figma.com/design/nhn7vx1XRE4r4dOUXEBDkM/Flysim

## 🎉 Prochaines Étapes

1. **Activer MCP Figma** dans Cursor
2. **Tester** une commande : "Récupère les variables Figma"
3. **Synchroniser** : `node scripts/sync-figma-tokens.js`
4. **Coder** en utilisant les tokens

Vous êtes prêt ! 🚀
