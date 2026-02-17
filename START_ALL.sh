#!/bin/bash

# 🚀 DXB Connect - Démarrage Complet
# Lance tous les services sur les ports configurés

set -e

echo "🚀 DXB Connect - Démarrage Complet"
echo "===================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

# Vérifier et tuer les processus existants
echo -e "${BLUE}🧹 Nettoyage des ports...${NC}"
lsof -ti:4000 | xargs kill -9 2>/dev/null || true
lsof -ti:4001 | xargs kill -9 2>/dev/null || true
lsof -ti:4002 | xargs kill -9 2>/dev/null || true
sleep 1

# Démarrer Next.js Client (Port 4000)
echo -e "${PURPLE}📱 Démarrage DXB Client (Next.js)...${NC}"
cd Apps/DXBClient
npm run dev > /tmp/dxb-client.log 2>&1 &
CLIENT_PID=$!
cd ../..
sleep 3

# Vérifier que le serveur répond
if curl -s http://localhost:4000 > /dev/null; then
    echo -e "${GREEN}✅ DXB Client démarré sur http://localhost:4000${NC}"
    echo -e "   PID: $CLIENT_PID"
else
    echo -e "${RED}❌ Erreur démarrage DXB Client${NC}"
    exit 1
fi

echo ""

# Démarrer iOS Simulator
echo -e "${PURPLE}📱 Démarrage iOS Simulator...${NC}"
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 17 Pro" | grep -o '[A-F0-9-]\{36\}' | head -1)

if [ -n "$DEVICE_ID" ]; then
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    open -a Simulator
    sleep 2

    # Lancer l'app iOS
    cd Apps/DXBClient
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/DXBConnect-*/Build/Products/Debug-iphonesimulator -name "DXBConnect.app" -type d | head -1)

    if [ -n "$APP_PATH" ]; then
        xcrun simctl install "$DEVICE_ID" "$APP_PATH" 2>/dev/null || true
        IOS_PID=$(xcrun simctl launch "$DEVICE_ID" com.dxbconnect.app 2>&1 | grep -o '[0-9]\+')
        echo -e "${GREEN}✅ iOS App lancée sur iPhone 17 Pro${NC}"
        echo -e "   PID: $IOS_PID"
    else
        echo -e "${RED}⚠️  iOS App non buildée - Exécuter: cd Apps/DXBClient && xcodebuild...${NC}"
    fi
    cd ../..
else
    echo -e "${RED}⚠️  Simulateur iPhone 17 Pro non trouvé${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Tous les services sont démarrés !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📍 URLs:${NC}"
echo -e "   🌐 Web:     http://localhost:4000"
echo -e "   📱 iOS:     Simulateur iPhone 17 Pro"
echo ""
echo -e "${BLUE}📊 PIDs:${NC}"
echo -e "   Next.js:    $CLIENT_PID"
echo -e "   iOS:        $IOS_PID"
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "   Next.js:    tail -f /tmp/dxb-client.log"
echo -e "   iOS:        xcrun simctl spawn $DEVICE_ID log stream"
echo ""
echo -e "${BLUE}🛑 Arrêter:${NC}"
echo -e "   kill $CLIENT_PID"
echo -e "   xcrun simctl terminate $DEVICE_ID com.dxbconnect.app"
echo ""
