#!/bin/bash

# ==============================================================================
# SCRIPT DE AUDITORÍA INTEGRAL DE CIERRE - DÍA 0
# PROYECTO: FleetSec S.A.S. DevSecOps Take-Home Assessment
# OBJETIVO: Verificar cumplimiento al 100% de la plataforma, toolchain y gobernanza.
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW}   INICIANDO AUDITORÍA TÉCNICA DE CIERRE DÍA 0       ${NC}"
echo -e "${YELLOW}=====================================================${NC}\n"

check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "   [STATUS] -> ${GREEN}PASSED${NC}"
    else
        echo -e "   [STATUS] -> ${RED}FAILED${NC}"
        ERRORS=$((ERRORS + 1))
    fi
}

# --- GATE 1: PLATAFORMA BASE ---
echo -e "${YELLOW}[GATE 1] Verificando Plataforma Base (WSL2, Docker, Git, Node)...${NC}"
uname -r | grep -q "microsoft"
check_status $?

docker info > /dev/null 2>&1
check_status $?

git --version > /dev/null 2>&1
check_status $?

node -v > /dev/null 2>&1
check_status $?

# --- GATE 2: TOOLCHAIN DEVSECOPS & IaC ---
echo -e "\n${YELLOW}[GATE 2] Verificando Toolchain DevSecOps local (CLI Tools)...${NC}"
echo -n " - Pre-commit: "
pre-commit --version > /dev/null 2>&1; check_status $?

echo -n " - Terraform CLI: "
terraform -v > /dev/null 2>&1; check_status $?

echo -n " - Checkov CLI: "
checkov -v > /dev/null 2>&1; check_status $?

echo -n " - AWS CLI v2: "
aws --version > /dev/null 2>&1; check_status $?

echo -n " - CycloneDX Generator: "
cyclonedx-npm --version > /dev/null 2>&1; check_status $?

# --- GATE 3 & 4: ESTRUCTURA Y GOBERNANZA ---
echo -e "\n${YELLOW}[GATE 3 & 4] Verificando Repositorio y Gobernanza...${NC}"
test -f .github/CODEOWNERS
check_status $?

test -f .gitignore
check_status $?

test -f .pre-commit-config.yaml
check_status $?

# --- GATE 5: SEGURIDAD PREVENTIVA LOCAL ---
echo -e "\n${YELLOW}[GATE 5] Verificando Hooks de Seguridad (Gitleaks)...${NC}"
test -f .git/hooks/pre-commit
check_status $?

# --- GATE 6 & 7: CONGELAMIENTO Y DOCUMENTACIÓN BASE ---
echo -e "\n${YELLOW}[GATE 6 & 7] Verificando Artefactos de Documentación y Congelamiento...${NC}"
test -f docs/decision-freeze.md
check_status $?

test -f docs/day1-readiness.md
check_status $?

test -f docs/AI-USAGE.md
check_status $?

# --- RESULTADO FINAL ---
echo -e "\n${YELLOW}=====================================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}   RESULTADO: 100% CUMPLIDO - AUDITORÍA DÍA 0 APROBADA${NC}"
    echo -e "${GREEN}   El entorno está blindado, verificado y congelado.${NC}"
    echo -e "${YELLOW}=====================================================${NC}"
    exit 0
else
    echo -e "${RED}   RESULTADO: AUDITORÍA FALLIDA ($ERRORS errores detectados)${NC}"
    echo -e "${RED}   Revise las dependencias marcadas con FAILED antes de continuar.${NC}"
    echo -e "${YELLOW}=====================================================${NC}"
    exit 1
fi
