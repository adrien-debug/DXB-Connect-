#!/bin/bash
# Script de test automatisé pour l'app iOS DXB Connect
# Usage: ./scripts/test-ios-app.sh

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="Apps/DXBClient"
SCHEME="DXBConnect"
SIMULATOR_NAME="iPhone 17"
BUNDLE_ID="com.dxbconnect.app"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Test Automatisé - App iOS DXB Connect${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. Vérifier Xcode
echo -e "${YELLOW}[1/7]${NC} Vérification Xcode..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode n'est pas installé${NC}"
    exit 1
fi
XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "${GREEN}✅ ${XCODE_VERSION}${NC}"
echo ""

# 2. Vérifier le projet
echo -e "${YELLOW}[2/7]${NC} Vérification du projet..."
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Dossier $PROJECT_DIR introuvable${NC}"
    exit 1
fi
cd "$PROJECT_DIR"
echo -e "${GREEN}✅ Projet trouvé${NC}"
echo ""

# 3. Résoudre les dépendances
echo -e "${YELLOW}[3/7]${NC} Résolution des dépendances Swift Package..."
xcodebuild -resolvePackageDependencies -scheme "$SCHEME" > /dev/null 2>&1
echo -e "${GREEN}✅ Dépendances résolues${NC}"
echo ""

# 4. Clean build
echo -e "${YELLOW}[4/7]${NC} Clean build..."
xcodebuild clean -scheme "$SCHEME" > /dev/null 2>&1
echo -e "${GREEN}✅ Clean effectué${NC}"
echo ""

# 5. Compilation
echo -e "${YELLOW}[5/7]${NC} Compilation de l'app..."
BUILD_START=$(date +%s)

# Trouver le simulateur
SIMULATOR_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -v "Pro" | head -n 1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')

if [ -z "$SIMULATOR_ID" ]; then
    echo -e "${RED}❌ Simulateur '$SIMULATOR_NAME' introuvable${NC}"
    echo -e "${YELLOW}Simulateurs disponibles:${NC}"
    xcrun simctl list devices available | grep "iPhone"
    exit 1
fi

# Build
if xcodebuild \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    build \
    > /tmp/xcode_build.log 2>&1; then

    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    echo -e "${GREEN}✅ Compilation réussie (${BUILD_TIME}s)${NC}"
else
    echo -e "${RED}❌ Échec de compilation${NC}"
    echo -e "${YELLOW}Logs:${NC}"
    tail -50 /tmp/xcode_build.log
    exit 1
fi
echo ""

# 6. Démarrer le simulateur
echo -e "${YELLOW}[6/7]${NC} Démarrage du simulateur..."
if xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -q "Booted"; then
    echo -e "${GREEN}✅ Simulateur déjà démarré${NC}"
else
    xcrun simctl boot "$SIMULATOR_ID" > /dev/null 2>&1
    sleep 3
    echo -e "${GREEN}✅ Simulateur démarré${NC}"
fi
echo ""

# 7. Installation et lancement
echo -e "${YELLOW}[7/7]${NC} Installation de l'app..."

# Trouver le .app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "DXBConnect.app" -type d | grep "Debug-iphonesimulator" | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ DXBConnect.app introuvable${NC}"
    exit 1
fi

# Installer
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH" > /dev/null 2>&1
echo -e "${GREEN}✅ App installée${NC}"

# Lancer
echo -e "${BLUE}🚀 Lancement de l'app...${NC}"
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID" > /dev/null 2>&1
echo -e "${GREEN}✅ App lancée${NC}"
echo ""

# Résumé
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Tests terminés avec succès !${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Informations:${NC}"
echo -e "  • Simulateur: $SIMULATOR_NAME ($SIMULATOR_ID)"
echo -e "  • Bundle ID: $BUNDLE_ID"
echo -e "  • App Path: $APP_PATH"
echo -e "  • Build Time: ${BUILD_TIME}s"
echo ""
echo -e "${BLUE}💡 Pour voir les logs:${NC}"
echo -e "  xcrun simctl spawn $SIMULATOR_ID log stream --predicate 'processImagePath contains \"DXBConnect\"'"
echo ""
