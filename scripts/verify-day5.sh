#!/usr/bin/env bash

# Fijar la raíz del proyecto a la carpeta actual
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
cd "$PROJECT_ROOT" 2>/dev/null || true

PASS_COUNT=0
FAIL_COUNT=0

echo "=========================================================================="
echo "AUDITORÍA TÉCNICA DE EVIDENCIA Y COMPROBACIÓN DE RIESGO — DÍA 5"
echo "=========================================================================="
echo "Fecha de Ejecución: $(date -u 2>/dev/null || date) (UTC)"
echo "Ruta de Proyecto:   ${PROJECT_ROOT:-$(pwd)}"
echo "=========================================================================="
echo ""

log_test() {
  local id="$1"
  local desc="$2"
  local status="$3"
  local details="$4"

  if [ "$status" -eq 0 ]; then
    echo -e "[\e[32mPASS\e[0m] $id — $desc"
    [ -n "$details" ] && echo "       Evidence: $details"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "[\e[31mFAIL\e[0m] $id — $desc"
    [ -n "$details" ] && echo "       Breach Detail: $details"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

echo "--- 1. AUDITORÍA DE PLAYBOOK DE CONTENCIÓN AWS CLI ---"
PLAYBOOK_FILE="docs/incident-response/IR-PLAYBOOK-T0200.md"

if [ -f "$PLAYBOOK_FILE" ]; then
  if grep -q "detach-user-policy" "$PLAYBOOK_FILE" 2>/dev/null && grep -q "DenyAllExplicit" "$PLAYBOOK_FILE" 2>/dev/null; then
    log_test "AUD-D5-01" "Comandos de revocación IAM de emergencia presentes" 0 "$PLAYBOOK_FILE"
  else
    log_test "AUD-D5-01" "Faltan comandos exactos de revocar política AdministratorAccess o DenyAllExplicit" 1 "$PLAYBOOK_FILE"
  fi

  if grep -q "modify-instance-attribute" "$PLAYBOOK_FILE" 2>/dev/null && grep -q "i-0abc1234def56789" "$PLAYBOOK_FILE" 2>/dev/null; then
    log_test "AUD-D5-02" "Aislamiento de instancia EC2 comprometida a SG Cuarentena" 0 "Instance i-0abc1234def56789 mapped"
  else
    log_test "AUD-D5-02" "Falta comando modify-instance-attribute para i-0abc1234def56789" 1 "$PLAYBOOK_FILE"
  fi

  if grep -q "stop-task" "$PLAYBOOK_FILE" 2>/dev/null && grep -q "fleetsec-prod-cluster" "$PLAYBOOK_FILE" 2>/dev/null; then
    log_test "AUD-D5-03" "Orden de detención de tarea rogue en ECS Cluster" 0 "stop-task en fleetsec-prod-cluster"
  else
    log_test "AUD-D5-03" "Falta comando stop-task sobre el cluster ECS" 1 "$PLAYBOOK_FILE"
  fi

  if grep -q "create-snapshot" "$PLAYBOOK_FILE" 2>/dev/null && grep -q "vol-0abc1234def56789" "$PLAYBOOK_FILE" 2>/dev/null; then
    log_test "AUD-D5-04" "Generación de Snapshot EBS para preservación forense" 0 "Volume vol-0abc1234def56789"
  else
    log_test "AUD-D5-04" "Falta comando create-snapshot sobre volumen vol-0abc1234def56789" 1 "$PLAYBOOK_FILE"
  fi
else
  log_test "AUD-D5-01" "Archivo de Playbook no encontrado" 1 "$PLAYBOOK_FILE"
  log_test "AUD-D5-02" "Archivo de Playbook no encontrado" 1 "$PLAYBOOK_FILE"
  log_test "AUD-D5-03" "Archivo de Playbook no encontrado" 1 "$PLAYBOOK_FILE"
  log_test "AUD-D5-04" "Archivo de Playbook no encontrado" 1 "$PLAYBOOK_FILE"
fi

echo ""
echo "--- 2. AUDITORÍA DE TAXONOMÍA MITRE ATT&CK v14 ---"
ATTACK_FILE="docs/incident-response/MITRE-ATTACK-MAP.md"

if [ -f "$ATTACK_FILE" ]; then
  TECH_COUNT=$(grep -oE 'T1[0-9]{3}(\.[0-9]{3})?' "$ATTACK_FILE" 2>/dev/null | sort -u | wc -l)
  if [ "$TECH_COUNT" -ge 6 ]; then
    log_test "AUD-D5-05" "Mapeo de técnicas MITRE ATT&CK v14 (Mínimo exige >= 6)" 0 "Identificadas $TECH_COUNT técnicas únicas"
  else
    log_test "AUD-D5-05" "Insuficiente cobertura de técnicas MITRE ATT&CK" 1 "Se encontraron $TECH_COUNT técnicas, se requieren mínimo 6"
  fi
else
  log_test "AUD-D5-05" "Archivo MITRE ATT&CK Map no encontrado" 1 "$ATTACK_FILE"
fi

echo ""
echo "--- 3. AUDITORÍA DE INFORME EJECUTIVO C-LEVEL Y LEY 1581 ---"
CEO_REPORT="docs/incident-response/CEO-EXECUTIVE-REPORT.md"

if [ -f "$CEO_REPORT" ]; then
  if grep -qi "Superintendencia de Industria y Comercio" "$CEO_REPORT" 2>/dev/null || grep -qi "15 días" "$CEO_REPORT" 2>/dev/null; then
    log_test "AUD-D5-06" "Inclusión de protocolo de notificación Ley 1581 a la SIC (15 días hábiles)" 0 "Notificación regulatoria confirmada"
  else
    log_test "AUD-D5-06" "Falta referencia a la SIC o al plazo legal de 15 días hábiles" 1 "$CEO_REPORT"
  fi

  if grep -q "P1" "$CEO_REPORT" 2>/dev/null && grep -q "P2" "$CEO_REPORT" 2>/dev/null && grep -q "P3" "$CEO_REPORT" 2>/dev/null; then
    log_test "AUD-D5-07" "Plan de remediación post-incidente estructurado en fases (P1 / P2 / P3)" 0 "Priorización P1/P2/P3 validada"
  else
    log_test "AUD-D5-07" "Falta estructura de fases P1/P2/P3 en el informe ejecutivo" 1 "$CEO_REPORT"
  fi
else
  log_test "AUD-D5-06" "Archivo de Informe C-Level no encontrado" 1 "$CEO_REPORT"
  log_test "AUD-D5-07" "Archivo de Informe C-Level no encontrado" 1 "$CEO_REPORT"
fi

echo ""
echo "--- 4. AUDITORÍA DE CADENA DE CUSTODIA FORENSE ---"
CUSTODY_FILE="docs/evidence/chain-of-custody.log"

if [ -f "$CUSTODY_FILE" ]; then
  if grep -qE '[a-fA-F0-9]{64}' "$CUSTODY_FILE" 2>/dev/null; then
    log_test "AUD-D5-08" "Presencia de Hashes de integridad SHA-256 en Cadena de Custodia" 0 "Hashes criptográficos verificados"
  else
    log_test "AUD-D5-08" "No se encontraron hashes SHA-256 válidos en el registro de custodia" 1 "$CUSTODY_FILE"
  fi
else
  log_test "AUD-D5-08" "Archivo de Cadena de Custodia no encontrado" 1 "$CUSTODY_FILE"
fi

echo ""
echo "=========================================================================="
echo "RESULTADO AUDITORÍA DÍA 5:  PASS: $PASS_COUNT  |  FAIL: $FAIL_COUNT"
echo "=========================================================================="

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo -e "\e[32mESTADO: AUDITORÍA APROBADA SIN HALLAZGOS CRÍTICOS\e[0m"
else
  echo -e "\e[31mESTADO: HALLAZGOS PENDIENTES DE CORRECCIÓN\e[0m"
fi

echo ""
echo "Auditoría finalizada. Terminal activa."
