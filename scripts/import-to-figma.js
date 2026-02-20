#!/usr/bin/env node

const FIGMA_FILE_KEY = 'nhn7vx1XRE4r4dOUXEBDkM';
const TOKEN = process.env.FIGMA_ACCESS_TOKEN;

if (!TOKEN) {
  console.error('❌ FIGMA_ACCESS_TOKEN manquant');
  console.log('\n📋 Pour obtenir ton token :');
  console.log('   1. Va sur https://www.figma.com/developers/api#access-tokens');
  console.log('   2. Clique "Get personal access token"');
  console.log('   3. Copie le token');
  console.log('   4. Lance : FIGMA_ACCESS_TOKEN=ton_token node scripts/import-to-figma.js\n');
  process.exit(1);
}

const BASE = 'https://api.figma.com/v1';
const headers = {
  'X-Figma-Token': TOKEN,
  'Content-Type': 'application/json'
};

const COLORS = {
  'accent': { r: 0.804, g: 1, b: 0, a: 1 },
  'accent-light': { r: 0.91, g: 1, b: 0.5, a: 1 },
  'accent-soft': { r: 0.96, g: 1, b: 0.84, a: 1 },
  'gray-50': { r: 0.98, g: 0.98, b: 0.98, a: 1 },
  'gray-100': { r: 0.957, g: 0.957, b: 0.961, a: 1 },
  'gray-200': { r: 0.894, g: 0.894, b: 0.906, a: 1 },
  'gray-300': { r: 0.831, g: 0.831, b: 0.847, a: 1 },
  'gray-400': { r: 0.631, g: 0.631, b: 0.667, a: 1 },
  'gray-500': { r: 0.443, g: 0.443, b: 0.478, a: 1 },
  'gray-600': { r: 0.322, g: 0.322, b: 0.357, a: 1 },
  'gray-700': { r: 0.247, g: 0.247, b: 0.275, a: 1 },
  'gray-800': { r: 0.153, g: 0.153, b: 0.165, a: 1 },
  'gray-900': { r: 0.094, g: 0.094, b: 0.106, a: 1 },
  'success': { r: 0.086, g: 0.639, b: 0.29, a: 1 },
  'warning': { r: 0.851, g: 0.467, b: 0.024, a: 1 },
  'error': { r: 0.863, g: 0.149, b: 0.149, a: 1 },
  'info': { r: 0.145, g: 0.388, b: 0.922, a: 1 },
  'bg-primary': { r: 1, g: 1, b: 1, a: 1 },
  'bg-secondary': { r: 0.98, g: 0.98, b: 0.98, a: 1 },
  'bg-tertiary': { r: 0.957, g: 0.957, b: 0.961, a: 1 },
  'text-primary': { r: 0.035, g: 0.035, b: 0.043, a: 1 },
  'text-secondary': { r: 0.322, g: 0.322, b: 0.357, a: 1 },
  'text-tertiary': { r: 0.631, g: 0.631, b: 0.667, a: 1 },
  'border-default': { r: 0.894, g: 0.894, b: 0.906, a: 1 },
};

const DARK_COLORS = {
  'gray-50': { r: 0.094, g: 0.094, b: 0.106, a: 1 },
  'gray-100': { r: 0.153, g: 0.153, b: 0.165, a: 1 },
  'gray-200': { r: 0.247, g: 0.247, b: 0.275, a: 1 },
  'gray-300': { r: 0.322, g: 0.322, b: 0.357, a: 1 },
  'gray-400': { r: 0.443, g: 0.443, b: 0.478, a: 1 },
  'gray-500': { r: 0.631, g: 0.631, b: 0.667, a: 1 },
  'gray-600': { r: 0.831, g: 0.831, b: 0.847, a: 1 },
  'gray-700': { r: 0.894, g: 0.894, b: 0.906, a: 1 },
  'gray-800': { r: 0.957, g: 0.957, b: 0.961, a: 1 },
  'gray-900': { r: 0.98, g: 0.98, b: 0.98, a: 1 },
  'success': { r: 0.29, g: 0.871, b: 0.502, a: 1 },
  'warning': { r: 0.984, g: 0.749, b: 0.141, a: 1 },
  'error': { r: 0.973, g: 0.443, b: 0.443, a: 1 },
  'info': { r: 0.376, g: 0.647, b: 0.98, a: 1 },
  'bg-primary': { r: 0.035, g: 0.035, b: 0.043, a: 1 },
  'bg-secondary': { r: 0.094, g: 0.094, b: 0.106, a: 1 },
  'bg-tertiary': { r: 0.153, g: 0.153, b: 0.165, a: 1 },
  'text-primary': { r: 0.98, g: 0.98, b: 0.98, a: 1 },
  'text-secondary': { r: 0.631, g: 0.631, b: 0.667, a: 1 },
  'text-tertiary': { r: 0.443, g: 0.443, b: 0.478, a: 1 },
  'border-default': { r: 0.153, g: 0.153, b: 0.165, a: 1 },
};

const SPACING = {
  'xs': 4, 'sm': 8, 'md': 12, 'base': 16,
  'lg': 20, 'xl': 24, 'xxl': 32, 'xxxl': 48
};

const RADIUS = {
  'xs': 6, 'sm': 10, 'md': 14, 'lg': 18,
  'xl': 22, 'xxl': 28, 'full': 9999
};

async function figmaAPI(method, endpoint, body) {
  const url = `${BASE}${endpoint}`;
  const opts = { method, headers };
  if (body) opts.body = JSON.stringify(body);

  const res = await fetch(url, opts);
  const data = await res.json();

  if (!res.ok) {
    console.error(`❌ ${method} ${endpoint}:`, data.message || data.err || JSON.stringify(data));
    return null;
  }
  return data;
}

async function getLocalVariableCollections() {
  return figmaAPI('GET', `/files/${FIGMA_FILE_KEY}/variables/local`);
}

async function createVariables() {
  console.log('🚀 Import des design tokens dans Figma...\n');

  const existing = await getLocalVariableCollections();
  if (!existing) {
    console.error('❌ Impossible de lire les variables. Vérifie ton token et les permissions.');
    process.exit(1);
  }

  console.log('✅ Connexion Figma OK\n');

  const payload = {
    variableCollections: [],
    variableModes: [],
    variables: [],
    variableModeValues: []
  };

  const colorCollectionId = 'temp_color_collection';
  const spacingCollectionId = 'temp_spacing_collection';

  const lightModeId = 'temp_light_mode';
  const darkModeId = 'temp_dark_mode';
  const defaultModeId = 'temp_default_mode';

  payload.variableCollections.push(
    { action: 'CREATE', id: colorCollectionId, name: 'DXB Colors', initialModeId: lightModeId },
    { action: 'CREATE', id: spacingCollectionId, name: 'DXB Spacing', initialModeId: defaultModeId }
  );

  payload.variableModes.push(
    { action: 'CREATE', id: lightModeId, name: 'Light', variableCollectionId: colorCollectionId },
    { action: 'CREATE', id: darkModeId, name: 'Dark', variableCollectionId: colorCollectionId },
    { action: 'CREATE', id: defaultModeId, name: 'Default', variableCollectionId: spacingCollectionId }
  );

  let varIndex = 0;

  for (const [name, value] of Object.entries(COLORS)) {
    const varId = `temp_color_${varIndex++}`;
    payload.variables.push({
      action: 'CREATE',
      id: varId,
      name: `color/${name}`,
      variableCollectionId: colorCollectionId,
      resolvedType: 'COLOR'
    });

    payload.variableModeValues.push({
      variableId: varId,
      modeId: lightModeId,
      value: value
    });

    const darkValue = DARK_COLORS[name] || value;
    payload.variableModeValues.push({
      variableId: varId,
      modeId: darkModeId,
      value: darkValue
    });
  }

  for (const [name, value] of Object.entries(SPACING)) {
    const varId = `temp_spacing_${varIndex++}`;
    payload.variables.push({
      action: 'CREATE',
      id: varId,
      name: `spacing/${name}`,
      variableCollectionId: spacingCollectionId,
      resolvedType: 'FLOAT'
    });
    payload.variableModeValues.push({
      variableId: varId,
      modeId: defaultModeId,
      value: value
    });
  }

  for (const [name, value] of Object.entries(RADIUS)) {
    const varId = `temp_radius_${varIndex++}`;
    payload.variables.push({
      action: 'CREATE',
      id: varId,
      name: `radius/${name}`,
      variableCollectionId: spacingCollectionId,
      resolvedType: 'FLOAT'
    });
    payload.variableModeValues.push({
      variableId: varId,
      modeId: defaultModeId,
      value: value
    });
  }

  console.log(`📦 Envoi de ${payload.variables.length} variables...`);
  console.log(`   - ${Object.keys(COLORS).length} couleurs (light + dark)`);
  console.log(`   - ${Object.keys(SPACING).length} spacing`);
  console.log(`   - ${Object.keys(RADIUS).length} radius\n`);

  const result = await figmaAPI('POST', `/files/${FIGMA_FILE_KEY}/variables`, payload);

  if (result) {
    console.log('✅ Variables créées avec succès dans Figma !\n');
    console.log('📊 Résumé :');
    console.log(`   Collections : 2 (DXB Colors, DXB Spacing)`);
    console.log(`   Modes       : 2 (Light, Dark) pour les couleurs`);
    console.log(`   Variables   : ${payload.variables.length} au total`);
    console.log(`\n🎨 Ouvre ton fichier Figma pour voir les variables :`);
    console.log(`   https://www.figma.com/design/${FIGMA_FILE_KEY}/Flysim\n`);
  } else {
    console.error('❌ Erreur lors de la création des variables.');
    console.log('\n💡 Solutions possibles :');
    console.log('   - Vérifie que ton token a les permissions "File content" en écriture');
    console.log('   - Regénère un token sur https://www.figma.com/developers/api#access-tokens');
    console.log('   - Assure-toi d\'avoir les droits d\'édition sur le fichier Flysim');
  }
}

createVariables().catch(console.error);
