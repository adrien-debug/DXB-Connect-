# 🎨 Analyse Design iOS - DXB Connect

## 📱 Dashboard View (Home Page)

### Structure Actuelle

```
┌─────────────────────────────────────────┐
│  👤 Avatar    Good morning, Adrien   🔔 │  ← Header Bar
├─────────────────────────────────────────┤
│                                         │
│         Active eSIMs                    │  ← Hero Card (Lime)
│              3                          │
│                                         │
│  [Buy eSIM]  [Scan QR]  [⋮]            │
│                                         │
├─────────────────────────────────────────┤
│  Cards                                  │  ← eSIM Cards Section
│  ┌────┐ ┌────┐ ┌────┐ ┌─┐              │
│  │ 📱 │ │ 📱 │ │ 📱 │ │+│              │
│  └────┘ └────┘ └────┘ └─┘              │
├─────────────────────────────────────────┤
│  ⭕ Data usage                          │  ← Data Usage Row
│     75 GB total    3 active             │
├─────────────────────────────────────────┤
│  Recent activity                        │  ← Activity List
│  🇦🇪 UAE eSIM        Active             │
│  🇹🇷 Turkey eSIM     In Use             │
│  🇪🇺 Europe eSIM     Active             │
└─────────────────────────────────────────┘
```

## 🎨 Design System Actuel

### Couleurs Utilisées

| Élément | Couleur | Hex | Usage |
|---------|---------|-----|-------|
| **Fond principal** | Noir profond | `#0A0A0A` | Background |
| **Accent lime** | Lime Pulse | `#CDFF00` | Hero card, boutons, accents |
| **Surface dark** | Zinc 900 | `#18181B` | Cards dark |
| **Surface light** | Zinc 200 | `#E4E4E7` | Cards light |
| **Texte primary** | Blanc | `#FFFFFF` | Titres, texte principal |
| **Texte secondary** | Zinc 500 | `#71717A` | Labels, descriptions |
| **Texte tertiary** | Zinc 400 | `#A1A1AA` | Placeholders |
| **Border** | Zinc 800 | `#27272A` | Séparateurs |

### Typography

| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| **Hero Amount** | SF Rounded | 56pt | Bold | Nombre eSIMs actives |
| **Section Title** | SF Pro | 20pt | Bold | "Cards", "Recent activity" |
| **Card Amount** | SF Rounded | 20pt | Bold | Data dans cards |
| **Body** | SF Pro | 15pt | Semibold | Noms, labels |
| **Caption** | SF Pro | 13pt | Regular | Descriptions |
| **Small** | SF Pro | 11pt | Medium | ICCID, metadata |

### Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Micro spacing |
| `sm` | 8px | Compact spacing |
| `md` | 12px | Card padding |
| `base` | 16px | Section padding |
| `lg` | 20px | Page margins |
| `xl` | 24px | Large sections |
| `xxl` | 32px | Hero spacing |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 10px | Small elements |
| `md` | 14px | Buttons |
| `lg` | 16px | Cards |
| `xl` | 20px | Hero card |
| `xxl` | 28px | Top corners white section |

## 📦 Composants Principaux

### 1. Hero Header (Lime Card)

**Fichier** : `DashboardView.swift` ligne 55-196

**Design** :
- Fond : `#CDFF00` (Lime)
- Texte : Noir
- Padding : 20px horizontal, 16px vertical
- Border radius : Aucun (edge-to-edge)

**Contenu** :
- Titre "Active eSIMs" (13pt, medium)
- Nombre (56pt, bold, rounded)
- 3 boutons action (Buy eSIM, Scan QR, Grid)

**Code actuel** :
```swift
VStack(spacing: 16) {
    Text("Active eSIMs")
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(.black.opacity(0.6))

    Text("\(coordinator.user.activeESIMs)")
        .font(.system(size: 56, weight: .bold, design: .rounded))
        .foregroundColor(.black)
}
.background(Color(hex: "CDFF00"))
```

**Amélioration suggérée** :
```swift
VStack(spacing: 16) {
    Text("Active eSIMs")
        .font(AppTheme.Typography.caption())
        .foregroundColor(AppTheme.textSecondary)

    Text("\(coordinator.user.activeESIMs)")
        .font(AppTheme.Typography.heroAmount())
        .foregroundColor(AppTheme.primary)
}
.background(AppTheme.accent)
```

### 2. eSIM Card Widget

**Fichier** : `DashboardView.swift` ligne 287-322

**Design** :
- Dimensions : 160x100pt
- Border radius : 16px
- 2 variantes : Dark (`#18181B`) et Light (`#E4E4E7`)

**Contenu** :
- Icon SIM (14pt)
- Data amount (20pt, bold, rounded)
- Package name + ICCID (11pt, medium)

**Code actuel** :
```swift
VStack(alignment: .leading, spacing: 0) {
    Image(systemName: "simcard.fill")
        .foregroundColor(isDark ? Color(hex: "CDFF00") : Color(hex: "09090B"))

    Text(data)
        .font(.system(size: 20, weight: .bold, design: .rounded))
        .foregroundColor(isDark ? .white : Color(hex: "09090B"))
}
.frame(width: 160, height: 100)
.background(
    RoundedRectangle(cornerRadius: 16)
        .fill(isDark ? Color(hex: "18181B") : Color(hex: "E4E4E7"))
)
```

**Amélioration suggérée** :
```swift
VStack(alignment: .leading, spacing: 0) {
    Image(systemName: "simcard.fill")
        .foregroundColor(isDark ? AppTheme.accent : AppTheme.primary)

    Text(data)
        .font(AppTheme.Typography.cardAmount())
        .foregroundColor(isDark ? AppTheme.textPrimary : AppTheme.primary)
}
.frame(width: 160, height: 100)
.techCard(cornerRadius: AppTheme.Radius.lg)
```

### 3. Data Usage Row

**Fichier** : `DashboardView.swift` ligne 326-366

**Design** :
- Progress circle : 44x44pt, stroke 4pt
- Couleur progress : `#CDFF00`
- Background : `#E4E4E7`

**Code actuel** :
```swift
ZStack {
    Circle()
        .stroke(Color(hex: "E4E4E7"), lineWidth: 4)
        .frame(width: 44, height: 44)

    Circle()
        .trim(from: 0, to: 0.75)
        .stroke(Color(hex: "CDFF00"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        .frame(width: 44, height: 44)
}
```

**Amélioration suggérée** :
```swift
ZStack {
    Circle()
        .stroke(AppTheme.gray200, lineWidth: 4)
        .frame(width: 44, height: 44)

    Circle()
        .trim(from: 0, to: 0.75)
        .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
        .frame(width: 44, height: 44)
}
```

### 4. Activity Row

**Fichier** : `DashboardView.swift` ligne 604-681

**Design** :
- Avatar circle : 44x44pt, fond `#F4F4F5`
- Emoji flag : 20pt
- Padding : 20px horizontal, 12px vertical

**Statuts** :
- Active : `#22C55E` (Green)
- In Use : `#22C55E` (Green)
- Expired : `#71717A` (Gray)
- Other : `#EAB308` (Yellow)

**Code actuel** :
```swift
HStack(spacing: 14) {
    Circle()
        .fill(Color(hex: "F4F4F5"))
        .frame(width: 44, height: 44)
        .overlay(Text(flagEmoji).font(.system(size: 20)))

    VStack(alignment: .leading, spacing: 3) {
        Text(order.packageName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color(hex: "09090B"))
    }
}
```

**Amélioration suggérée** :
```swift
HStack(spacing: AppTheme.Spacing.md) {
    Circle()
        .fill(AppTheme.gray100)
        .frame(width: 44, height: 44)
        .overlay(Text(flagEmoji).font(.system(size: 20)))

    VStack(alignment: .leading, spacing: 3) {
        Text(order.packageName)
            .font(AppTheme.Typography.body())
            .foregroundColor(AppTheme.textPrimary)
    }
}
```

## 🔄 Comparaison Code vs Theme.swift

### ❌ Hardcodé (À Remplacer)

| Code Actuel | Token Theme.swift |
|-------------|-------------------|
| `Color(hex: "0A0A0A")` | `AppTheme.backgroundPrimary` |
| `Color(hex: "CDFF00")` | `AppTheme.accent` |
| `Color(hex: "18181B")` | `AppTheme.gray900` |
| `Color(hex: "E4E4E7")` | `AppTheme.gray200` |
| `Color(hex: "71717A")` | `AppTheme.gray500` |
| `Color(hex: "A1A1AA")` | `AppTheme.gray400` |
| `.font(.system(size: 56, weight: .bold))` | `AppTheme.Typography.heroAmount()` |
| `.font(.system(size: 20, weight: .bold))` | `AppTheme.Typography.sectionTitle()` |
| `padding(20)` | `padding(AppTheme.Spacing.lg)` |
| `cornerRadius: 16` | `cornerRadius: AppTheme.Radius.lg` |

## 📋 Actions Recommandées

### 1. Remplacer les Couleurs Hardcodées

**Fichier** : `DashboardView.swift`

**Remplacements** :
```swift
// Ligne 14
- Color(hex: "0A0A0A")
+ AppTheme.backgroundPrimary

// Ligne 64
- Color(hex: "27272A")
+ AppTheme.gray800

// Ligne 77
- Color(hex: "71717A")
+ AppTheme.textSecondary

// Ligne 109
- Color(hex: "CDFF00")
+ AppTheme.accent

// Ligne 190
- Color(hex: "CDFF00")
+ AppTheme.accent

// Ligne 233
- Color(hex: "09090B")
+ AppTheme.textPrimary

// Ligne 270
- Color(hex: "A1A1AA")
+ AppTheme.textTertiary

// Ligne 276
- Color(hex: "F4F4F5")
+ AppTheme.gray100

// Ligne 293
- Color(hex: "CDFF00")
+ AppTheme.accent

// Ligne 320
- Color(hex: "18181B")
+ AppTheme.gray900

// Ligne 320
- Color(hex: "E4E4E7")
+ AppTheme.gray200
```

### 2. Utiliser les Typography Tokens

```swift
// Hero amount
- .font(.system(size: 56, weight: .bold, design: .rounded))
+ .font(AppTheme.Typography.heroAmount())

// Section titles
- .font(.system(size: 20, weight: .bold))
+ .font(AppTheme.Typography.sectionTitle())

// Card amounts
- .font(.system(size: 20, weight: .bold, design: .rounded))
+ .font(AppTheme.Typography.cardAmount())

// Body text
- .font(.system(size: 15, weight: .semibold))
+ .font(AppTheme.Typography.body())

// Captions
- .font(.system(size: 13, weight: .regular))
+ .font(AppTheme.Typography.caption())

// Small text
- .font(.system(size: 11, weight: .medium))
+ .font(AppTheme.Typography.small())
```

### 3. Utiliser les Spacing Tokens

```swift
// Padding horizontal
- .padding(.horizontal, 20)
+ .padding(.horizontal, AppTheme.Spacing.lg)

// Padding vertical
- .padding(.vertical, 16)
+ .padding(.vertical, AppTheme.Spacing.base)

// VStack spacing
- VStack(spacing: 14)
+ VStack(spacing: AppTheme.Spacing.md)

// HStack spacing
- HStack(spacing: 8)
+ HStack(spacing: AppTheme.Spacing.sm)
```

### 4. Utiliser les Radius Tokens

```swift
// Cards
- RoundedRectangle(cornerRadius: 16)
+ RoundedRectangle(cornerRadius: AppTheme.Radius.lg)

// Buttons
- RoundedRectangle(cornerRadius: 14)
+ RoundedRectangle(cornerRadius: AppTheme.Radius.md)

// Circles/Pills
- Capsule()
+ RoundedRectangle(cornerRadius: AppTheme.Radius.full)
```

## 🎯 Checklist Migration

- [ ] Remplacer toutes les couleurs hardcodées par tokens
- [ ] Remplacer toutes les fonts par Typography tokens
- [ ] Remplacer tous les spacing par tokens
- [ ] Remplacer tous les radius par tokens
- [ ] Tester sur iPhone (light + dark mode)
- [ ] Vérifier accessibilité (VoiceOver)
- [ ] Valider avec design Figma

## 📊 Statistiques

**Occurrences à remplacer** :
- Couleurs hardcodées : ~45
- Fonts hardcodées : ~30
- Spacing hardcodés : ~25
- Radius hardcodés : ~15

**Total** : ~115 remplacements

**Temps estimé** : 30-45 minutes

## 🔗 Prochaines Étapes

1. **Synchroniser avec Figma** : `node scripts/sync-figma-tokens.js`
2. **Appliquer les tokens** : Remplacer hardcoded values
3. **Tester** : Build + Run sur simulateur
4. **Valider** : Comparer avec design Figma
5. **Commit** : `git commit -m "refactor: migrate DashboardView to design tokens"`
