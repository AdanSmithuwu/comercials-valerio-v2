# Fase 6: Operación continua y mejora evolutiva

## 1. Objetivo
Establecer el modelo operativo posterior al go-live para asegurar continuidad del servicio,
mejora continua del producto, control de deuda técnica y evolución segura del sistema
(Spring Boot + React + PostgreSQL) en producción.

## 2. Alcance de Fase 6
- Gobierno operativo y técnico post-producción.
- Gestión de incidentes y confiabilidad (SRE lite).
- Evolución funcional controlada por roadmap.
- Gestión de deuda técnica y refactor continuo.
- Optimización de costos, capacidad y rendimiento.
- Cumplimiento, auditoría y seguridad continua.

## 3. Modelo operativo post-producción

### 3.1 Ciclo operativo
- Monitoreo diario de salud de plataforma.
- Revisión semanal de KPIs técnicos y de negocio.
- Revisión quincenal de incidentes y acciones preventivas.
- Revisión mensual de arquitectura y deuda técnica.

### 3.2 Responsables sugeridos
- **Owner funcional**: prioriza valor de negocio.
- **Owner técnico**: mantiene arquitectura y calidad.
- **Owner operativo**: coordina soporte, monitoreo y despliegues.

## 4. Confiabilidad y SLOs

### 4.1 SLOs iniciales recomendados
- Disponibilidad API: >= 99.5% mensual.
- Error rate en operaciones críticas: <= 1%.
- Latencia p95 en endpoints críticos: <= 800 ms.
- Tiempo de recuperación ante incidente severo (MTTR): <= 60 minutos.

### 4.2 Gestión por error budget
- Si se consume el error budget mensual:
    - congelar cambios no críticos,
    - priorizar correcciones de confiabilidad,
    - ejecutar revisión postmortem obligatoria.

## 5. Gestión de incidentes y soporte

### 5.1 Flujo de incidente
1. Detección (alerta automática o reporte de usuario).
2. Triage (severidad, alcance, impacto).
3. Mitigación rápida.
4. Resolución técnica.
5. Postmortem sin culpables.

### 5.2 Severidades
- **Sev-1**: operación principal caída (ventas/pedidos no operables).
- **Sev-2**: degradación severa con workaround.
- **Sev-3**: error parcial sin impacto crítico.
- **Sev-4**: mejora/defecto menor.

### 5.3 Entregables obligatorios
- Timeline del incidente.
- Causa raíz.
- Acciones correctivas y preventivas.
- Responsable y fecha compromiso.

## 6. Roadmap evolutivo del producto

### 6.1 Gestión del backlog
- Priorizar por valor de negocio + riesgo técnico.
- Mantener balance entre:
    - nuevas funcionalidades,
    - deuda técnica,
    - estabilidad y performance.

### 6.2 Política de releases
- Release planificado (semanal/quincenal).
- Hotfix solo para severidad alta.
- Feature flags para liberar funcionalidades progresivamente.

## 7. Deuda técnica y calidad continua

### 7.1 Prácticas obligatorias
- Refactor incremental por módulo en cada sprint.
- Revisión de código con checklist técnico.
- Cobertura de pruebas para cambios críticos.
- Auditoría periódica de consultas SQL y performance.

### 7.2 Indicadores de salud técnica
- Tiempo promedio de entrega de cambios.
- Tasa de rollback por release.
- Defectos en producción por sprint.
- Tendencia de latencia y consumo de recursos.

## 8. Seguridad continua y cumplimiento

### 8.1 Seguridad
- Rotación periódica de secretos.
- Revisión de dependencias y vulnerabilidades.
- Pruebas de hardening en endpoints sensibles.
- Revisión de permisos por rol y principio de mínimo privilegio.

### 8.2 Cumplimiento y auditoría
- Retención y trazabilidad de logs según política.
- Evidencia de cambios (migraciones, despliegues, accesos críticos).
- Revisión de cumplimiento normativo aplicable al negocio.

## 9. Capacidad, costos y escalabilidad

### 9.1 Gestión de capacidad
- Proyección trimestral de carga por transacciones.
- Plan de escalado horizontal/vertical por componente.
- Pruebas periódicas de estrés en flujos críticos.

### 9.2 Gestión de costos
- Monitorear consumo por entorno (DB, backend, frontend, observabilidad).
- Ajustar recursos por uso real.
- Eliminar recursos ociosos y cargas innecesarias.

## 10. Gobierno de datos y migraciones continuas
- Mantener Flyway como única vía de cambio estructural de DB.
- Versionar y auditar toda migración aplicada.
- Validar migraciones en ambiente efímero antes de producción.
- Documentar rollback compensatorio por cada cambio crítico.

## 11. KPIs de éxito de Fase 6
- Estabilidad sostenida del sistema por 3 ciclos de release consecutivos.
- Reducción progresiva de incidentes Sev-1 y Sev-2.
- Cumplimiento de SLOs acordados.
- Lead time de cambios dentro de objetivo definido por equipo.
- Backlog técnico bajo control con tendencia decreciente.

## 12. Criterio de cierre y continuidad
La Fase 6 no cierra como proyecto tradicional; se convierte en el modelo operativo
permanente del sistema. Se considera consolidada cuando el equipo opera con disciplina
de confiabilidad, releases controlados y mejora continua basada en métricas.
