# Règles Cursor - DXB Connect

## 📋 6 Règles Absolues

### 🔴 Toujours Actives

1. **`00-project-core.mdc`** - Règles fondamentales
   - Architecture Railway stricte
   - Sécurité absolue
   - Workflow développement

2. **`05-architecture-railway.mdc`** - Architecture Railway (NON NÉGOCIABLE)
   - iOS/Next.js → Railway UNIQUEMENT
   - Railway → Supabase + eSIM API
   - URL: `https://api-github-production-a848.up.railway.app/api`

### 🟡 Actives selon fichiers ouverts

3. **`01-nextjs-api.mdc`** - Standards API Next.js
   - Scope: `**/app/api/**/*.ts`
   - Auth unifiée `requireAuthFlexible()`
   - Validation Zod, logs sécurisés

4. **`02-react-hooks.mdc`** - React Query & Composants
   - Scope: `**/src/{hooks,components}/**/*.{ts,tsx}`
   - Pattern hooks custom
   - Gestion cache & invalidation

5. **`03-swift-ios.mdc`** - Standards Swift/SwiftUI
   - Scope: `**/*.swift`
   - DXBCore Package
   - Auth + TokenManager + OSLog

6. **`04-database-supabase.mdc`** - Supabase & Database
   - Scope: `**/migrations/**/*.sql`
   - RLS obligatoire
   - Migrations avec rollback

## 🚂 Architecture Railway (Règle #1)

```
iOS App ──┐
          ├──► Railway Backend ──► Supabase ──► eSIM Access API
Next.js ──┘
```

**❌ INTERDIT** :
- Connexion directe client → Supabase
- Connexion directe client → eSIM API
- Bypasser Railway

**✅ OBLIGATOIRE** :
- Railway est TOUJOURS le seul point d'entrée
- URL Production: `https://api-github-production-a848.up.railway.app/api`

## 📖 Documentation

- **Architecture complète** : [../ARCHITECTURE_RAILWAY.md](../ARCHITECTURE_RAILWAY.md)
- **README projet** : [../README.md](../README.md)

## 🔒 Sécurité

- Jamais de secrets dans le code
- Jamais de connexion directe aux services
- Toujours vérifier `user_id` dans queries
- Toujours utiliser `requireAuthFlexible()` pour auth
- Jamais de logs avec données sensibles

## 🎯 Activation

Les règles s'activent automatiquement dans Cursor selon :
- **Toujours actives** : `00-project-core.mdc`, `05-architecture-railway.mdc`
- **Selon fichiers** : Les autres règles s'activent quand vous ouvrez des fichiers correspondant à leur `globs`
