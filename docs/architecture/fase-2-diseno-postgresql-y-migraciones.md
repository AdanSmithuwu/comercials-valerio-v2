# Fase 2: Diseño objetivo de PostgreSQL y estrategia de migraciones

## 1. Objetivo
Consolidar PostgreSQL como plataforma de datos del sistema, definiendo una estrategia
versionada, reproducible y segura para evolucionar esquema, catálogos y reglas mínimas
de integridad sin regresar a lógica de negocio en base de datos.

## 2. Resultado esperado de la fase
- Esquema PostgreSQL estable y versionado.
- Migraciones repetibles por entorno (dev, QA, prod).
- Semillas de catálogos controladas.
- Trazabilidad de cambios de base de datos por release.
- Criterios claros de rollback y verificación post-despliegue.

## 3. Decisiones técnicas de base de datos

### 3.1 Herramienta de migración
- Adoptar **Flyway** como estándar del proyecto.
- Convención de scripts:
    - `V{version}__{descripcion}.sql` para cambios versionados.
    - `R__{descripcion}.sql` para objetos repetibles (si aplica).
- Una migración nunca se edita tras desplegarse; cualquier ajuste entra en una nueva versión.

### 3.2 Principios de modelado
- Mantener PK/FK/UNIQUE/CHECK/NOT NULL como base de integridad.
- Evitar triggers de lógica de negocio.
- Mantener funciones SQL solo para utilidades acotadas y estables.
- Todas las reglas de proceso (ventas, pedidos, stock operativo, seguridad funcional)
  deben implementarse en backend.

### 3.3 Convenciones de nombres
- Definir estándar para nuevos artefactos:
    - Tablas: `snake_case`.
    - Columnas: `snake_case`.
    - Índices: `ix_{tabla}_{columnas}`.
    - FK: `fk_{tabla}_{tabla_ref}`.
- Para tablas heredadas ya definidas en `DDL_postgresql.sql`, mantener compatibilidad
  durante la transición y normalizar en fases posteriores si el costo/beneficio lo justifica.

## 4. Estructura de migraciones iniciales (propuesta)

### 4.1 Línea base
- **V1**: esquema inicial PostgreSQL derivado de `db/DDL_postgresql.sql`.
- Incluir tablas, constraints, funciones utilitarias mínimas e índices estratégicos.

### 4.2 Catálogos y datos base
- **V2**: catálogos obligatorios (`Estado`, `Rol`, `TipoProducto`, `MetodoPago`, etc.).
- **V3**: parámetros de sistema iniciales (por ejemplo, cargos/descuentos configurables).

### 4.3 Hardening
- **V4**: ajustes de índices según plan de consultas reales.
- **V5**: restricciones adicionales de integridad detectadas en pruebas de integración.

## 5. Estrategia de migración de datos

### 5.1 Enfoque
- Migración por lotes desde SQL Server con tablas de staging cuando sea necesario.
- Validación por conteo y checksum funcional (totales, saldos, transacciones cerradas).

### 5.2 Orden recomendado
1. Catálogos.
2. Personas, clientes y empleados.
3. Productos, tallas y presentaciones.
4. Transacciones (cabecera).
5. Detalles y pagos.
6. Movimientos de inventario.
7. Evidencias (comprobantes/reportes binarios) si aplica.

### 5.3 Reglas de consistencia
- No cargar transacciones con referencias faltantes.
- Verificar sumatoria de pagos por transacción.
- Verificar no negatividad de stock al cierre de migración histórica.

## 6. Plan de validación técnica

### 6.1 Validaciones de esquema
- Todas las migraciones deben ejecutar sin error en entorno limpio.
- Todas las migraciones deben ejecutar idempotentemente en pipeline (controlado por Flyway).

### 6.2 Validaciones de datos
- Conteo por tabla origen vs destino (con tolerancias documentadas).
- Validación de integridad referencial al 100%.
- Muestreo de casos críticos: ventas, pedidos cancelados, transacciones entregadas.

### 6.3 Validaciones de rendimiento
- Medir queries críticas de:
    - historial por cliente,
    - resumen diario,
    - alertas de stock,
    - pedidos pendientes.
- Ajustar índices con evidencia de `EXPLAIN ANALYZE`.

## 7. Rollback y contingencia
- Nunca borrar una migración ya aplicada en ambientes compartidos.
- Rollback por nueva migración compensatoria.
- En cambios de alto riesgo:
    - respaldo previo,
    - ventana controlada,
    - checklist de verificación post-deploy,
    - plan de reversa documentado.

## 8. Entregables de Fase 2
- Documento de diseño objetivo PostgreSQL (este documento).
- Decisión oficial de herramienta de migración (Flyway).
- Backlog técnico de scripts `V1..Vn` priorizados.
- Checklist de validación de migraciones y calidad de datos.

## 9. Criterios de aceptación de Fase 2
- Existe una línea base de migración versionada definida y aprobada.
- Se acordó estándar de naming y gobernanza de scripts.
- Está definido el plan de validación de datos y performance.
- El equipo puede iniciar implementación de migraciones en Fase 3 sin ambigüedad.

## 10. Puerta de entrada a Fase 3
La Fase 3 inicia cuando:
- estén aprobadas las migraciones base,
- se definan responsables por script,
- y exista pipeline CI para ejecutar Flyway sobre PostgreSQL en entorno de integración.
