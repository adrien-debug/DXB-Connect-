# ✅ Configuration Figma MCP - Terminée

## 🎉 Résumé de l'Installation

Tous les fichiers et configurations nécessaires pour l'intégration Figma MCP ont été créés avec succès.

## 📦 Fichiers Créés

### 1. Configuration MCP

| Fichier | Description | Status |
|---------|-------------|--------|
| `~/.cursor/mcp.json` | Config MCP globale (avec Figma) | ✅ Modifié |
| `.cursor/mcp.json` | Config MCP locale (projet) | ✅ Créé |

**Serveur Figma configuré** : `figma-flysim`
- URL : `https://mcp.figma.com/mcp`
- Design : `https://www.figma.com/design/nhn7vx1XRE4r4dOUXEBDkM/Flysim`

### 2. Scripts de Synchronisation

| Fichier | Description | Status |
|---------|-------------|--------|
| `scripts/sync-figma-tokens.js` | Extrait tokens Figma → Swift/CSS | ✅ Créé |
| `scripts/README.md` | Documentation scripts | ✅ Créé |
| `scripts/test-figma-setup.sh` | Test configuration | ✅ Créé |

### 3. Documentation

| Fichier | Description | Status |
|---------|-------------|--------|
| `.cursor/rules/06-figma-integration.mdc` | Règle Cursor Figma | ✅ Créé |
| `FIGMA_QUICKSTART.md` | Guide rapide | ✅ Créé |
| `README.md` | Section Design System ajoutée | ✅ Modifié |
| `.env.example` | Template variables d'env | ✅ Créé |

## 🚀 Prochaines Étapes

### Étape 1 : Activer le Serveur MCP Figma

**Option A - Via Cursor Settings** :
1. Ouvrir Cursor
2. `Cmd + ,` (Paramètres)
3. Onglet **"MCP"**
4. Chercher **"figma-flysim"**
5. Cliquer sur **"Connect"**
6. Autoriser l'accès

**Option B - Redémarrer Cursor** :
1. Quitter complètement : `Cmd + Q`
2. Relancer Cursor
3. Le serveur devrait se charger automatiquement

### Étape 2 : Tester la Connexion

Dans Cursor Chat, essayez :
```
"Récupère les variables de couleur depuis Figma"
```

Si ça fonctionne, vous verrez les variables du design Flysim.

### Étape 3 : Synchroniser les Tokens

```bash
# Lancer le script de synchronisation
node scripts/sync-figma-tokens.js
```

**Génère** :
- `Apps/DXBClient/Views/Theme.generated.swift`
- `Apps/DXBClient/src/styles/tokens.generated.css`

### Étape 4 : Intégrer les Tokens

**iOS** : Importer dans `Theme.swift`
```swift
// En haut de Theme.swift
import Theme.generated
```

**Web** : Importer dans `globals.css`
```css
/* En haut de globals.css */
@import './styles/tokens.generated.css';
```

## 🎨 Utilisation Quotidienne

### Commandes Cursor Chat

```
"Récupère les variables Figma"
"Montre les composants Button"
"Génère le code SwiftUI pour LoginCard"
"Compare les couleurs Figma vs code"
"Extrait les tokens de spacing"
```

### Workflow Design → Code

1. **Designer dans Figma** avec les tokens
2. **Extraire via MCP** : Commande Cursor
3. **Synchroniser** : `node scripts/sync-figma-tokens.js`
4. **Coder** avec les tokens générés
5. **Tester** iOS + Web

### Ajouter une Nouvelle Couleur

1. **Figma** : Variables → Ajouter couleur
2. **Script** : Éditer `scripts/sync-figma-tokens.js`
   ```javascript
   colors: {
     // ...
     newColor: '#FF5733',
   }
   ```
3. **Sync** : `node scripts/sync-figma-tokens.js`
4. **Utiliser** :
   ```swift
   .foregroundColor(AppTheme.newColor)
   ```

## 📋 Checklist Complète

### Configuration
- [x] MCP Figma ajouté à `~/.cursor/mcp.json`
- [x] Config locale `.cursor/mcp.json` créée
- [x] Script de sync créé et exécutable
- [x] Documentation complète créée
- [x] Règle Cursor Figma créée
- [x] README mis à jour

### À Faire (Vous)
- [ ] Redémarrer Cursor
- [ ] Activer serveur MCP Figma
- [ ] Tester commande Figma dans Chat
- [ ] Lancer `node scripts/sync-figma-tokens.js`
- [ ] Vérifier fichiers `.generated.*` créés
- [ ] Intégrer dans Theme.swift + globals.css

### Optionnel
- [ ] Créer token Figma API
- [ ] Ajouter à `.env.local`
- [ ] Tester fetch automatique depuis Figma

## 🔧 Tokens de Design Actuels

### Couleurs (Pulse Theme)

```swift
// iOS
AppTheme.accent       // #CDFF00 (Lime)
AppTheme.primary      // #09090B / #FAFAFA
AppTheme.gray50-900   // Zinc scale
AppTheme.success      // #16A34A / #4ADE80
AppTheme.error        // #DC2626 / #F87171
```

```css
/* Web */
var(--accent)         /* #D4F441 */
var(--bg-base)        /* #09090B */
var(--text-primary)   /* #FAFAFA */
var(--success)        /* #4ADE80 */
var(--error)          /* #F87171 */
```

### Spacing

```
xs: 4px, sm: 8px, md: 12px, base: 16px
lg: 20px, xl: 24px, xxl: 32px, xxxl: 48px
```

### Radius

```
xs: 6px, sm: 10px, md: 14px, lg: 18px
xl: 22px, xxl: 28px, full: 9999px
```

## 📚 Documentation

| Document | Contenu |
|----------|---------|
| `FIGMA_QUICKSTART.md` | Guide rapide d'utilisation |
| `.cursor/rules/06-figma-integration.mdc` | Règles complètes Figma |
| `scripts/README.md` | Documentation scripts |
| `README.md` | Vue d'ensemble projet |

## 🎯 Outils MCP Figma

Une fois connecté, vous aurez accès à :

| Outil | Description |
|-------|-------------|
| `get_design_context` | Contexte complet du design |
| `get_variable_defs` | Variables (couleurs, typo, spacing) |
| `get_code_connect_map` | Mapping composants Figma ↔ Code |
| `get_screenshot` | Captures d'écran des frames |

## ⚠️ Règles Importantes

### ✅ TOUJOURS

- Utiliser les tokens de design
- Synchroniser après modifications Figma
- Passer par Figma pour changements de design
- Documenter les nouveaux tokens

### ❌ JAMAIS

- Hardcoder couleurs/spacing/radius
- Modifier fichiers `.generated.*` manuellement
- Créer couleurs sans les ajouter à Figma
- Ignorer warnings de tokens manquants

## 🔗 Liens Utiles

- **Figma Design** : https://www.figma.com/design/nhn7vx1XRE4r4dOUXEBDkM/Flysim
- **Figma API Docs** : https://www.figma.com/developers/api
- **MCP Figma Docs** : https://developers.figma.com/docs/figma-mcp-server/
- **Créer Token Figma** : https://www.figma.com/developers/api#access-tokens

## 🎊 Conclusion

Votre intégration Figma MCP est **100% configurée** !

Il ne reste plus qu'à :
1. **Redémarrer Cursor**
2. **Activer le serveur MCP**
3. **Commencer à utiliser**

Bon développement ! 🚀
