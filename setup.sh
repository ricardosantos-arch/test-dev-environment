#!/usr/bin/env bash
# =============================================================================
# Proffer — Setup do Ambiente de Desenvolvimento Local
# =============================================================================
# Compatível com: Linux, macOS
# Para Windows: usar setup.ps1
#
# Uso: ./setup.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Proffer — Ambiente de Desenvolvimento        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# --- Verificar Docker ---
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker não encontrado.${NC}"
    echo "Instale em: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose V2 não encontrado.${NC}"
    echo "Atualize o Docker Desktop ou instale o plugin compose."
    exit 1
fi

echo -e "${GREEN}Docker encontrado:${NC} $(docker --version)"
echo ""

# --- Detectar SO ---
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM="Linux" ;;
    Darwin*)    PLATFORM="macOS" ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="Windows (WSL/Git Bash)" ;;
    *)          PLATFORM="Desconhecido ($OS)" ;;
esac
echo -e "${GREEN}Sistema:${NC} $PLATFORM"
echo ""

# --- Selecionar perfil ---
echo "Selecione seu perfil de trabalho:"
echo ""
echo "  1) Backend Developer     — APIs Flask + PostgreSQL + MongoDB"
echo "  2) Frontend Developer    — React/Vite + APIs"
echo "  3) Full Stack            — Backend + Frontend"
echo "  4) Engenheiro de Dados   — JupyterLab + Beam + PostgreSQL + MongoDB"
echo "  5) Cientista de Dados    — JupyterLab + BigQuery + MongoDB"
echo "  6) Analytics / P&D       — JupyterLab (somente leitura)"
echo "  7) Platform Engineering  — Infra (só bancos, sem aplicação)"
echo "  8) CTO / Tech Lead       — Full Stack + JupyterLab"
echo ""
read -p "Perfil [1-8]: " PROFILE

# --- Configurar env files ---
if [ ! -f .env.backend ]; then
    cp .env.example .env.backend
    echo -e "${YELLOW}Criado .env.backend a partir de .env.example${NC}"
fi

if [ ! -f .env.frontend ]; then
    cp .env.example .env.frontend
    echo -e "${YELLOW}Criado .env.frontend a partir de .env.example${NC}"
fi

# --- Montar compose command ---
BASE="docker compose -f docker-compose.yml"

case "$PROFILE" in
    1)
        COMPOSE="$BASE -f docker-compose.backend.yml"
        PROFILE_NAME="Backend Developer"
        URLS="API Principal: http://localhost:5000\n  API Parceiros: http://localhost:5001"
        ;;
    2)
        COMPOSE="$BASE -f docker-compose.frontend.yml"
        PROFILE_NAME="Frontend Developer"
        URLS="Frontend: http://localhost:3000"
        ;;
    3)
        COMPOSE="$BASE -f docker-compose.backend.yml -f docker-compose.frontend.yml"
        PROFILE_NAME="Full Stack"
        URLS="Frontend: http://localhost:3000\n  API Principal: http://localhost:5000\n  API Parceiros: http://localhost:5001"
        ;;
    4|5|6)
        COMPOSE="$BASE -f docker-compose.data.yml"
        PROFILE_NAME="Data / Analytics"
        URLS="JupyterLab: http://localhost:8888 (token: proffer)"
        ;;
    7)
        COMPOSE="$BASE"
        PROFILE_NAME="Platform Engineering"
        URLS="PostgreSQL: localhost:5432\n  MongoDB: localhost:27017"
        ;;
    8)
        COMPOSE="$BASE -f docker-compose.backend.yml -f docker-compose.frontend.yml -f docker-compose.data.yml"
        PROFILE_NAME="CTO / Tech Lead"
        URLS="Frontend: http://localhost:3000\n  API Principal: http://localhost:5000\n  API Parceiros: http://localhost:5001\n  JupyterLab: http://localhost:8888 (token: proffer)"
        ;;
    *)
        echo -e "${RED}Perfil inválido.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Perfil:${NC} $PROFILE_NAME"
echo -e "${BLUE}Comando:${NC} $COMPOSE up -d"
echo ""

# --- Deseja incluir ferramentas visuais? ---
read -p "Incluir ferramentas visuais (pgAdmin + Mongo Express)? [y/N]: " TOOLS
if [[ "$TOOLS" =~ ^[Yy]$ ]]; then
    COMPOSE="$COMPOSE --profile tools"
fi

# --- Subir containers ---
echo ""
echo -e "${YELLOW}Subindo containers...${NC}"
$COMPOSE up -d --build

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Ambiente pronto!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Perfil: ${BLUE}$PROFILE_NAME${NC}"
echo -e "  $URLS"
echo ""
echo "  PostgreSQL: localhost:5432 (proffer_dev / proffer_dev_2026)"
echo "  MongoDB:    localhost:27017 (proffer_dev / proffer_dev_2026)"

if [[ "$TOOLS" =~ ^[Yy]$ ]]; then
    echo ""
    echo "  pgAdmin:       http://localhost:5050 (dev@proffer.com.br / proffer_dev_2026)"
    echo "  Mongo Express: http://localhost:8081"
fi

echo ""
echo -e "  Para parar:   ${YELLOW}$COMPOSE down${NC}"
echo -e "  Para resetar:  ${YELLOW}$COMPOSE down -v${NC} (apaga dados dos bancos)"
echo ""
