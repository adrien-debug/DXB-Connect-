#!/bin/bash

echo "🛑 Arrêt de tous les services DXB Connect..."

# Couleurs
RED='\033[0;31m'
NC='\033[0m'

# Arrêter par PID si disponible
if [ -f ".backend.pid" ]; then
    BACKEND_PID=$(cat .backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo -e "${RED}Arrêt du Backend (PID: $BACKEND_PID)${NC}"
        kill -9 $BACKEND_PID 2>/dev/null
    fi
    rm .backend.pid
fi

if [ -f ".frontend.pid" ]; then
    FRONTEND_PID=$(cat .frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo -e "${RED}Arrêt du Frontend (PID: $FRONTEND_PID)${NC}"
        kill -9 $FRONTEND_PID 2>/dev/null
    fi
    rm .frontend.pid
fi

# Arrêter par port en backup
lsof -ti:3001 | xargs kill -9 2>/dev/null
lsof -ti:3000 | xargs kill -9 2>/dev/null

echo "✅ Tous les services sont arrêtés"
