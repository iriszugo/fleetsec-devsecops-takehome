#!/bin/bash
echo "=== VALIDACIÓN INTEGRAL DÍA 0 — FLEETSEC DEVSECOPS ==="
docker --version && git --version && node -v && cyclonedx-npm --version && \
pre-commit --version && terraform -v | head -n 1 && checkov -v && aws --version
if [ $? -eq 0 ]; then
  echo "✅ GATE FINAL APROBADO: El Día 0 se encuentra cerrado al 100%."
else
  echo "❌ ERROR EN GATE FINAL: Revisar dependencias pendientes."
fi
