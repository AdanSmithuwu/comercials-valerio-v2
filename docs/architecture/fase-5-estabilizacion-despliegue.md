# Fase 5: Estabilización, optimización y despliegue

## 1. Objetivo
Consolidar el sistema para salida a producción con criterios de estabilidad,
seguridad, rendimiento y operación continua, asegurando un despliegue reproducible
para backend, frontend y base de datos PostgreSQL.

## 2. Alcance de Fase 5
- Endurecimiento de seguridad en backend y frontend.
- Optimización de consultas y rendimiento general.
- Observabilidad completa (logs, métricas, trazas).
- Dockerización y estandarización de entornos.
- Pipeline CI/CD con gates de calidad y despliegue controlado.
- Runbooks de operación e incidentes.

## 3. Estabilización funcional

### 3.1 Hardening de reglas críticas
- Verificar consistencia de flujos:
    - registrar venta,
    - registrar/modificar pedido,
    - ajustar inventario,
    - cancelar transacción.
- Validar casos borde y de concurrencia (stock simultáneo).
- Confirmar trazabilidad completa de auditoría por operación crítica.

### 3.2 Gestión de errores
- Catálogo final de errores funcionales cerrado y versionado.
- Mensajes de negocio homogéneos en UI y API.
- Inclusión obligatoria de `traceId` para diagnóstico cruzado.

## 4. Optimización de rendimiento

### 4.1 Base de datos
- Revisión de planes de ejecución de consultas críticas con `EXPLAIN ANALYZE`.
- Ajuste de índices por evidencia de carga real.
- Revisión de consultas de reportes (diario/mensual/rotación).
- Evaluación de vistas materializadas para agregaciones pesadas.

### 4.2 Backend
- Perfilado de endpoints de mayor tráfico.
- Reducción de N+1 queries y sobrecarga de serialización.
- Timeouts y reintentos controlados para integraciones externas.

### 4.3 Frontend
- Optimización de carga inicial y división de bundles.
- Estrategia de cache de consultas y revalidación.
- Reducción de re-renderizados en vistas transaccionales.

## 5. Seguridad de producción

### 5.1 Backend/API
- Rotación y gestión segura de secretos.
- Política de expiración y revocación de JWT/refresh tokens.
- Rate limiting para endpoints sensibles.
- Encabezados de seguridad y CORS restringido por entorno.

### 5.2 Frontend
- Protección de rutas por rol y sesión.
- Gestión segura de tokens en cliente.
- Política de cierre de sesión por inactividad/expiración.

### 5.3 Base de datos
- Usuarios por entorno con privilegios mínimos.
- Separación de cuentas de lectura/escritura cuando aplique.
- Respaldo cifrado y validación periódica de restauración.

## 6. Observabilidad y operación

### 6.1 Logs
- Logs estructurados JSON con `traceId` y `userId` (si aplica).
- Niveles de log por entorno (dev/qa/prod).

### 6.2 Métricas
- Métricas mínimas obligatorias:
    - latencia por endpoint,
    - tasa de errores por caso de uso,
    - throughput,
    - colisiones de concurrencia de inventario.

### 6.3 Alertas
- Alertas por umbrales de error y latencia.
- Alertas de salud de base de datos y disponibilidad de API.
- Canal de notificación operativa y escalamiento definido.

## 7. Dockerización y ambientes

### 7.1 Estandarización de contenedores
- Contenedor para backend Spring Boot.
- Contenedor para frontend React.
- Contenedor para PostgreSQL con volumen persistente.

### 7.2 Entornos
- `docker-compose` para desarrollo local.
- Entorno de integración (CI) con ejecución automática de migraciones.
- Entorno de staging espejo de producción para validación previa.

### 7.3 Inicialización
- Migraciones Flyway automáticas al iniciar backend.
- Carga controlada de catálogos y parámetros base.

## 8. Pipeline CI/CD

### 8.1 Etapas recomendadas
1. Build backend/frontend.
2. Validación estática y quality checks.
3. Ejecución de migraciones en entorno efímero.
4. Pruebas de integración y E2E críticas.
5. Empaquetado de imágenes.
6. Deploy a staging.
7. Aprobación manual para producción.

### 8.2 Gates de calidad
- No desplegar si falla migración de DB.
- No desplegar si fallan flujos críticos E2E.
- No desplegar si se exceden umbrales de error/latencia definidos.

## 9. Runbooks operativos

### 9.1 Runbook de despliegue
- Checklist predeploy.
- Orden de despliegue: DB -> backend -> frontend.
- Checklist postdeploy con smoke tests.

### 9.2 Runbook de incidentes
- Diagnóstico inicial por `traceId`.
- Procedimiento de rollback funcional/técnico.
- Comunicación de incidente y postmortem.

### 9.3 Runbook de mantenimiento
- Rotación de secretos.
- Depuración de bitácoras.
- Reindex/mantenimiento de DB programado.

## 10. Criterios de aceptación de Fase 5
- Sistema estable en staging con operación end-to-end validada.
- Rendimiento dentro de objetivos definidos por negocio.
- Seguridad y observabilidad activas en todos los componentes.
- Pipeline CI/CD operativo con gates de calidad.
- Runbooks aprobados por equipo técnico y operación.

## 11. Cierre del plan de modernización
La modernización se considera completa cuando el sistema reemplaza la operación histórica,
con lógica de negocio centralizada en backend, base de datos PostgreSQL gobernada por
migraciones versionadas y despliegues controlados en producción.
