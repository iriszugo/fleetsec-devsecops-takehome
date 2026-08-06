# Reporte de Uso de Inteligencia Artificial – Evaluación DevSecOps FleetSec

## Propósito

Este documento registra todas las interacciones relevantes con Inteligencia Artificial durante el desarrollo de la prueba técnica DevSecOps de FleetSec.

El objetivo es proporcionar trazabilidad completa del apoyo brindado por la IA, la validación humana, los inconvenientes detectados y las decisiones finales de implementación.

---

# 1. Bitácora de Interacciones con IA

| Día | Actividad | Asistencia de IA | Validación Humana | Resultado |
|------|-----------|------------------|-------------------|-----------|
| Día 0 | Inicialización del proyecto | Estructura del repositorio, carpetas y arquitectura inicial | Verificada manualmente | Aprobado |
| Día 0 | Entorno local | Guía para configuración de WSL2, Docker Desktop y VS Code | Ejecutada manualmente | Aprobado |
| Día 0 | Repositorio Git | Inicialización de Git y estructura del repositorio | Verificada | Aprobado |
| Día 1 | Laboratorio SQL Injection | Guía para implementación segura | Código revisado y probado | Aprobado |
| Día 1 | Regla Semgrep SQL | Generación de la regla | Validada con fixtures | Aprobado |
| Día 1 | Regla PII Logging | Regla personalizada de Semgrep | Validada manualmente | Aprobado |
| Día 1 | Script de verificación | Diseño de verify-day1.sh | Ejecutado exitosamente | Aprobado |
| Día 1 | Documentación técnica | Documentación inicial VAPT | Revisada | Aprobado |
| Día 2 | Laboratorio JWT | Implementaciones vulnerable y segura | Probadas manualmente | Aprobado |
| Día 2 | Laboratorio SSRF | Guía para implementación segura | Validada | Aprobado |
| Día 2 | Laboratorio Path Traversal | Guía para implementación segura | Validada | Aprobado |
| Día 2 | Rate Limiting | Implementación del middleware | Probada | Aprobado |
| Día 2 | Laboratorio IDOR | Controles de autorización | Probados | Aprobado |
| Día 2 | Reglas personalizadas Semgrep | Cinco reglas personalizadas | Fixtures positivos y negativos validados | Aprobado |
| Día 2 | Pruebas de seguridad Jest | Implementación de pruebas | Todas las suites ejecutadas | Aprobado |
| Día 2 | Script de verificación | Mejoras a verify-day2.sh | Ejecutado exitosamente | Aprobado |
| Día 2 | Reportes técnicos | Documentación VAPT | Revisada | Aprobado |
| Día 3 | Laboratorio Command Injection | Implementación segura utilizando execFile() | Probada | Aprobado |
| Día 3 | Endurecimiento HTTP | Integración de Helmet | Validada | Aprobado |
| Día 3 | Pruebas de seguridad | Implementación con Jest | Superadas | Aprobado |
| Día 3 | Regla Semgrep | Regla personalizada para Command Injection | Fixtures positivos y negativos validados | Aprobado |
| Día 3 | Script de verificación | verify-day3.sh | Ejecutado exitosamente | Aprobado |
| Día 3 | README | Documentación del repositorio | Revisada | Aprobado |

---

# 2. Errores o Alucinaciones de la IA

Durante el desarrollo fue necesario corregir manualmente las siguientes situaciones:

- Rutas del repositorio sugeridas incorrectamente durante las primeras iteraciones.
- Suposiciones incorrectas sobre archivos faltantes del proyecto.
- Los scripts de verificación requirieron varios refinamientos hasta cumplir los requisitos de la evaluación.
- El flujo de trabajo de Git fue corregido y validado manualmente antes de realizar cada commit.
- Los artefactos temporales generados durante las verificaciones requirieron limpieza manual.

Todas las respuestas generadas por la IA fueron revisadas antes de ser aceptadas.

---

# 3. Decisiones Humanas

e project documentation and AI usage report"Las siguientes decisiones fueron tomadas exclusivamente por el propietario del repositorio:

- Arquitectura final del repositorio.
- Aprobación de las implementaciones de seguridad.
- Aprobación de los commits realizados.
- Ejecución de los procesos de verificación.
- Revisión de la documentación técnica.
- Validación del pipeline CI/CD.
- Decisión final de integración (merge).

---

# 4. Actividades No Delegables

Las siguientes actividades fueron realizadas intencionalmente por el propietario del repositorio:

- Revisión del código fuente.
- Validación de controles de seguridad.
- Ejecución de pruebas manuales.
- Operaciones Git.
- Creación y aprobación de commits.
- Creación del Pull Request.
- Verificación final antes del merge.

---

# 5. Conclusión

La Inteligencia Artificial fue utilizada exclusivamente como una herramienta de apoyo durante el desarrollo.

Todas las implementaciones fueron revisadas, validadas, probadas y aprobadas manualmente antes de incorporarse al repositorio.

La responsabilidad final sobre el código fuente, la documentación y los controles de seguridad implementados recae exclusivamente en el propietario del repositorio.
