#!/bin/bash

echo "🚀 Démarrage de DXB Connect..."

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction pour vérifier si un port est utilisé
check_port() {
    lsof -ti:$1 > /dev/null 2>&1
}

# Arrêter les processus existants
echo -e "${BLUE}🛑 Arrêt des processus existants...${NC}"
if check_port 3001; then
    kill -9 $(lsof -ti:3001) 2>/dev/null
fi
if check_port 3000; then
    kill -9 $(lsof -ti:3000) 2>/dev/null
fi

# Créer les fichiers .env si nécessaire
if [ ! -f "Backend/.env" ]; then
    echo -e "${BLUE}📝 Création du fichier Backend/.env${NC}"
    cp Backend/.env.example Backend/.env
fi

if [ ! -f "Apps/DXBClient/.env.local" ]; then
    echo -e "${BLUE}📝 Création du fichier Apps/DXBClient/.env.local${NC}"
    cp Apps/DXBClient/.env.local.example Apps/DXBClient/.env.local
fi

# Installer les dépendances du backend
echo -e "${BLUE}📦 Installation des dépendances Backend...${NC}"
cd Backend
npm install
cd ..

# Installer les dépendances du frontend
echo -e "${BLUE}📦 Installation des dépendances Frontend...${NC}"
cd Apps/DXBClient
npm install
cd ../..

# Démarrer le backend
echo -e "${GREEN}🔧 Démarrage du Backend sur http://localhost:3001${NC}"
cd Backend
npm run dev > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Attendre que le backend démarre
sleep 3

# Démarrer le frontend
echo -e "${GREEN}🌐 Démarrage du Frontend sur http://localhost:3000${NC}"
cd Apps/DXBClient
npm run dev > ../../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ../..

echo ""
echo -e "${GREEN}✅ Tous les services sont démarrés!${NC}"
echo ""
echo "📊 Backend API: http://localhost:3001"
echo "   Health check: http://localhost:3001/health"
echo "   API docs: http://localhost:3001/api"
echo ""
echo "🌐 Frontend Web: http://localhost:3000"
echo ""
echo "📱 Pour lancer l'app iOS/macOS:"
echo "   cd Apps/DXBAdmin"
echo "   open DXBAdmin.xcodeproj"
echo ""
echo "📝 Logs:"
echo "   Backend: tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🛑 Pour arrêter: ./stop-all.sh"
echo ""

# Sauvegarder les PIDs
echo $BACKEND_PID > .backend.pid
echo $FRONTEND_PID > .frontend.pid
