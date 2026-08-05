#!/bin/bash

# ==============================================================================
# SCRIPT DE AUDITORÍA DE MADUREZ DEL REPOSITORIO (NIVEL 10/10)
# Evaluado contra: OpenSSF Scorecard, GitHub Enterprise & DevSecOps Standards
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCORE=0
TOTAL_CHECKS=10

echo -e "${BLUE}=======================================================${NC}"
echo -e "${BLUE}   AUDITORÍA DE MADUREZ DEVSECOPS - FLEETSEC S.A.S.   ${NC}"
echo -e "${BLUE}=======================================================${NC}\n"

eval_check() {
    local desc="$1"
    local condition="$2"
    echo -n " Check: $desc ... "
    if eval "$condition"; then
        echo -e "${GREEN}[CUMPLE +1.0]${NC}"
        SCORE=$((SCORE + 1))
    else
        echo -e "${RED}[NO CUMPLE 0.0]${NC}"
    fi
}

# 1. OpenSSF: Gobernanza y Divulgación de Seguridad
eval_check "Política de Divulgación de Vulnerabilidades (SECURITY.md)" "test -f SECURITY.md"
eval_check "Licencia del Repositorio (LICENSE)" "test -f LICENSE"

# 2. GitHub Enterprise: Protección de Ramas y Código
eval_check "Asignación de Propietarios de Código (.github/CODEOWNERS)" "test -f .github/CODEOWNERS"
eval_check "Automatización de Actualizaciones (.github/dependabot.yml)" "test -f .github/dependabot.yml"

# 3. Shift-Left Security: Prevención Local
eval_check "Hook Local de Detección de Secretos (.pre-commit-config.yaml)" "test -f .pre-commit-config.yaml"
eval_check "Exclusión de Archivos Sensibles e Instaladores (.gitignore)" "grep -q '*.zip' .gitignore 2>/dev/null"

# 4. Arquitectura y Entregables (Estructura de Carpetas)
eval_check "Directorio de Entregables de Aplicación (app/)" "test -d app"
eval_check "Directorio de Infraestructura como Código (terraform/)" "test -d terraform"
eval_check "Directorio de Detección e Incidentes (detection/)" "test -d detection"
eval_check "Registro de Decisiones de Arquitectura (docs/adr/)" "test -d docs/adr"

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${YELLOW} PUNTUACIÓN FINAL DE MADUREZ: ${SCORE} / ${TOTAL_CHECKS}${NC}"

if [ $SCORE -eq 10 ]; then
    echo -e "${GREEN} ESTADO: MADUREZ 10/10 — REPOSITORIO LISTO PARA EVALUACIÓN DÍA 1${NC}"
else
    echo -e "${RED} ESTADO: FALTAN CONTROLES PARA ALCANZAR EL NIVEL 10/10${NC}"
fi
echo -e "${BLUE}=======================================================${NC}"
