# FleetSec — Procedimiento Break-Glass

## 1. Objetivo

Definir el mecanismo excepcional de acceso y cambio de emergencia cuando un incidente crítico impida seguir el flujo normal de aprobación.

## 2. Alcance

Aplica a cambios urgentes relacionados con:

- Seguridad
- Infraestructura
- CI/CD
- IAM
- Aplicaciones
- Recuperación ante incidentes

## 3. Condiciones de activación

Break-Glass solo puede utilizarse cuando exista:

- Incidente crítico de seguridad.
- Indisponibilidad severa del servicio.
- Riesgo inmediato para confidencialidad, integridad o disponibilidad.
- Imposibilidad técnica de esperar el flujo normal de cambio.

## 4. Aprobación

Todo cambio Break-Glass requiere dos aprobadores definidos mediante:

`.github/CODEOWNERS`

Aprobadores:

- @iriszugo
- @fleetsec-admin

No se permite autoaprobación como único control.

## 5. Procedimiento

1. Registrar motivo de emergencia.
2. Identificar activo, servicio o componente afectado.
3. Documentar riesgo de no ejecutar el cambio.
4. Obtener aprobación de dos responsables.
5. Ejecutar únicamente el cambio mínimo necesario.
6. Registrar comandos y evidencias.
7. Validar funcionamiento y controles de seguridad.
8. Crear revisión post-incidente.
9. Regularizar el cambio mediante el flujo normal.
10. Conservar evidencia para auditoría.

## 6. Evidencias mínimas

- Fecha y hora.
- Solicitante.
- Aprobadores.
- Motivo.
- Commit o cambio ejecutado.
- Resultado.
- Evidencia técnica.
- Riesgo residual.
- Acción posterior.

## 7. Restricciones

Break-Glass no debe utilizarse para:

- Evitar Quality Gates.
- Omitir controles de seguridad por conveniencia.
- Introducir secretos.
- Deshabilitar monitoreo.
- Evitar revisión de código.
- Normalizar cambios sin trazabilidad.

## 8. Cierre

Todo uso de Break-Glass debe generar revisión posterior y evidencia documental antes de considerarse cerrado.
