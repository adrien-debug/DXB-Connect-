#!/usr/bin/env node

/**
 * DXB Connect - Figma Design Tokens Sync
 *
 * Extrait les tokens de design depuis Figma et génère :
 * - Theme.swift (iOS)
 * - globals.css (Web)
 *
 * Usage: node scripts/sync-figma-tokens.js
 */

const fs = require('fs');
const path = require('path');

// Configuration
const FIGMA_FILE_KEY = 'nhn7vx1XRE4r4dOUXEBDkM';
const FIGMA_ACCESS_TOKEN = process.env.FIGMA_ACCESS_TOKEN;

if (!FIGMA_ACCESS_TOKEN) {
  console.error('❌ FIGMA_ACCESS_TOKEN manquant dans .env');
  console.log('📝 Créez un token sur https://www.figma.com/developers/api#access-tokens');
  process.exit(1);
}

// Tokens actuels (à synchroniser avec Figma)
const DESIGN_TOKENS = {
  colors: {
    // Accent (Lime/Pulse)
    accent: '#CDFF00',
    accentDark: '#B8F000',
    accentLight: '#E8FF80',
    accentSoft: '#F5FFD6',

    // Primary (Zinc)
    primary: '#09090B',
    primaryLight: '#3F3F46',
    primaryDark: '#000000',
    primarySoft: '#F4F4F5',

    // Grayscale
    gray50: '#FAFAFA',
    gray100: '#F4F4F5',
    gray200: '#E4E4E7',
    gray300: '#D4D4D8',
    gray400: '#A1A1AA',
    gray500: '#71717A',
    gray600: '#52525B',
    gray700: '#3F3F46',
    gray800: '#27272A',
    gray900: '#18181B',

    // Semantic
    success: '#16A34A',
    successLight: '#4ADE80',
    warning: '#D97706',
    warningLight: '#FBBF24',
    error: '#DC2626',
    errorLight: '#F87171',
    info: '#2563EB',
    infoLight: '#60A5FA',
  },

  spacing: {
    xs: 4,
    sm: 8,
    md: 12,
    base: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
    xxxl: 48,
  },

  radius: {
    xs: 6,
    sm: 10,
    md: 14,
    lg: 18,
    xl: 22,
    xxl: 28,
    full: 9999,
  },

  typography: {
    heroAmount: { size: 48, weight: 'bold' },
    detailAmount: { size: 40, weight: 'bold' },
    sectionTitle: { size: 22, weight: 'semibold' },
    cardAmount: { size: 18, weight: 'semibold' },
    body: { size: 15, weight: 'regular' },
    caption: { size: 13, weight: 'regular' },
    small: { size: 11, weight: 'regular' },
    navTitle: { size: 12, weight: 'bold' },
    tabLabel: { size: 14, weight: 'medium' },
    button: { size: 14, weight: 'bold' },
    label: { size: 10, weight: 'bold' },
  },
};

/**
 * Génère Theme.swift pour iOS
 */
function generateSwiftTheme() {
  const swiftColors = Object.entries(DESIGN_TOKENS.colors)
    .map(([name, hex]) => {
      const isDark = name.includes('Dark') || name.includes('900') || name === 'primary';
      const lightHex = hex.replace('#', '');
      const darkHex = isDark ? 'FAFAFA' : lightHex;

      return `    static var ${name}: Color { adaptiveColor(light: "${lightHex}", dark: "${darkHex}") }`;
    })
    .join('\n');

  const swiftSpacing = Object.entries(DESIGN_TOKENS.spacing)
    .map(([name, value]) => `        static let ${name}: CGFloat = ${value}`)
    .join('\n');

  const swiftRadius = Object.entries(DESIGN_TOKENS.radius)
    .map(([name, value]) => `        static let ${name}: CGFloat = ${value}`)
    .join('\n');

  return `// ⚠️ AUTO-GENERATED - Ne pas modifier manuellement
// Généré depuis Figma via scripts/sync-figma-tokens.js

import SwiftUI

struct AppTheme {
    // MARK: - Spacing Scale

    enum Spacing {
${swiftSpacing}
    }

    // MARK: - Corner Radius Scale

    enum Radius {
${swiftRadius}
    }

    // MARK: - Colors

${swiftColors}

    // MARK: - Helper

    private static func adaptiveColor(light: String, dark: String) -> Color {
        Color(UIColor { traitCollection in
            let useDark = traitCollection.userInterfaceStyle == .dark
            return UIColor(Color(hex: useDark ? dark : light))
        })
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
`;
}

/**
 * Génère variables CSS pour Web
 */
function generateCSSVariables() {
  const cssColors = Object.entries(DESIGN_TOKENS.colors)
    .map(([name, hex]) => {
      const cssName = name.replace(/([A-Z])/g, '-$1').toLowerCase();
      return `  --${cssName}: ${hex};`;
    })
    .join('\n');

  const cssSpacing = Object.entries(DESIGN_TOKENS.spacing)
    .map(([name, value]) => `  --spacing-${name}: ${value}px;`)
    .join('\n');

  const cssRadius = Object.entries(DESIGN_TOKENS.radius)
    .map(([name, value]) => {
      const val = value === 9999 ? '9999px' : `${value}px`;
      return `  --radius-${name}: ${val};`;
    })
    .join('\n');

  return `/* ⚠️ AUTO-GENERATED - Ne pas modifier manuellement */
/* Généré depuis Figma via scripts/sync-figma-tokens.js */

:root {
  /* Colors */
${cssColors}

  /* Spacing */
${cssSpacing}

  /* Border Radius */
${cssRadius}

  /* Ease */
  --ease-premium: cubic-bezier(.165, .84, .44, 1);
}
`;
}

/**
 * Fetch Figma file (optionnel - nécessite API)
 */
async function fetchFigmaTokens() {
  try {
    const response = await fetch(
      `https://api.figma.com/v1/files/${FIGMA_FILE_KEY}`,
      {
        headers: {
          'X-Figma-Token': FIGMA_ACCESS_TOKEN,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`Figma API error: ${response.status}`);
    }

    const data = await response.json();
    console.log('✅ Figma file fetched:', data.name);

    // TODO: Parser les variables de design depuis data.document
    // Pour l'instant, on utilise les tokens hardcodés

    return DESIGN_TOKENS;
  } catch (error) {
    console.warn('⚠️  Impossible de fetch Figma, utilisation des tokens locaux');
    console.warn(error.message);
    return DESIGN_TOKENS;
  }
}

/**
 * Main
 */
async function main() {
  console.log('🎨 Synchronisation des tokens Figma...\n');

  // Fetch tokens (ou utilise les locaux)
  const tokens = await fetchFigmaTokens();

  // Génère Theme.swift
  const swiftTheme = generateSwiftTheme();
  const swiftPath = path.join(__dirname, '../Apps/DXBClient/Views/Theme.generated.swift');
  fs.writeFileSync(swiftPath, swiftTheme);
  console.log('✅ Theme.generated.swift créé');

  // Génère CSS variables
  const cssVars = generateCSSVariables();
  const cssPath = path.join(__dirname, '../Apps/DXBClient/src/styles/tokens.generated.css');
  fs.mkdirSync(path.dirname(cssPath), { recursive: true });
  fs.writeFileSync(cssPath, cssVars);
  console.log('✅ tokens.generated.css créé');

  console.log('\n🎉 Synchronisation terminée !');
  console.log('\n📝 Prochaines étapes :');
  console.log('  1. Importer Theme.generated.swift dans Xcode');
  console.log('  2. Importer tokens.generated.css dans globals.css');
  console.log('  3. Vérifier les couleurs dans Figma → Variables');
}

main().catch(console.error);
