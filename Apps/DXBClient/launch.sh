#!/bin/bash

# 🚀 DXB Connect - SwiftUI Native App Launcher
# Compile, installe et lance l'app sur le simulateur

set -e

echo "🎨 DXB Connect - SwiftUI Native"
echo "================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="DXBConnect"
SCHEME="DXBConnect"
BUNDLE_ID="com.dxbconnect.app"
SIMULATOR_NAME="iPhone 17 Pro"

echo -e "${BLUE}📱 Recherche du simulateur...${NC}"
DEVICE_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -o '[A-F0-9-]\{36\}' | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Simulateur $SIMULATOR_NAME non trouvé"
    echo "Simulateurs disponibles:"
    xcrun simctl list devices available | grep "iPhone"
    exit 1
fi

echo -e "${GREEN}✅ Simulateur trouvé: $DEVICE_ID${NC}"

# Démarrer le simulateur si nécessaire
echo -e "${BLUE}🔄 Démarrage du simulateur...${NC}"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator
sleep 2

# Clean build (optionnel)
if [ "$1" == "clean" ]; then
    echo -e "${PURPLE}🧹 Clean build...${NC}"
    cd "$PROJECT_DIR"
    xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" clean
    rm -rf ~/Library/Developer/Xcode/DerivedData/$PROJECT_NAME-*
fi

# Build
echo -e "${PURPLE}🔨 Compilation...${NC}"
cd "$PROJECT_DIR"
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -quiet \
    build

if [ $? -ne 0 ]; then
    echo "❌ Erreur de compilation"
    exit 1
fi

echo -e "${GREEN}✅ Compilation réussie${NC}"

# Trouver le .app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/$PROJECT_NAME-*/Build/Products/Debug-iphonesimulator -name "$PROJECT_NAME.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ App non trouvée"
    exit 1
fi

echo -e "${BLUE}📦 Installation...${NC}"
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

echo -e "${GREEN}✅ App installée${NC}"

# Terminer l'app si elle tourne déjà
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true

# Lancer l'app
echo -e "${PURPLE}🚀 Lancement de l'app...${NC}"
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

echo ""
echo -e "${GREEN}✨ App lancée avec succès !${NC}"
echo ""
echo "📱 Simulateur: $SIMULATOR_NAME"
echo "🎨 Design: Violet Premium Glassmorphism"
echo ""
echo "Pour voir les logs:"
echo "  xcrun simctl spawn $DEVICE_ID log stream --predicate 'processImagePath contains \"$PROJECT_NAME\"' --level debug"
echo ""
echo "Pour prendre une capture:"
echo "  xcrun simctl io $DEVICE_ID screenshot ~/Desktop/screenshot.png"
echo ""
