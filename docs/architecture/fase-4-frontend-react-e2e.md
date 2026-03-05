# Fase 4: Frontend React e integración end-to-end

## 1. Objetivo
Implementar el frontend React para operación diaria del negocio, conectado al backend
Spring Boot mediante APIs REST estables, con foco en usabilidad operativa, consistencia
de validaciones y trazabilidad de errores.

## 2. Alcance de Fase 4
- Construir la arquitectura frontend por módulos funcionales.
- Integrar autenticación/autorización basada en JWT.
- Implementar flujos críticos: ventas, pedidos, inventario y reportes.
- Estandarizar formularios, validaciones y manejo de errores.
- Dejar operativo el flujo end-to-end con backend y PostgreSQL.

## 3. Arquitectura de frontend objetivo

### 3.1 Estructura por capas
- **UI Layer**
    - Componentes de presentación reutilizables (tablas, formularios, diálogos, alerts).
- **Feature Layer**
    - Módulos: `auth`, `ventas`, `pedidos`, `inventario`, `clientes`, `empleados`, `reportes`.
- **Application Layer (frontend)**
    - Hooks/casos de uso de UI para orquestación de acciones.
- **Data Layer**
    - Cliente HTTP tipado (fetch/axios) + adaptadores de DTO.
    - Gestión centralizada de errores de API.

### 3.2 Estado
- Estado global para sesión, permisos y datos transversales.
- Estado local para formularios y vistas específicas.
- Estrategia recomendada:
    - cache y sincronización por query keys,
    - invalidación por mutación,
    - control de carga (`loading`, `error`, `empty`).

## 4. Seguridad de sesión en frontend
- Login contra `/api/auth/login` y almacenamiento seguro de tokens.
- Refresh token controlado con renovación transparente.
- Cierre de sesión por expiración o revocación.
- Guardas de ruta por rol:
    - `ADMIN`: configuración, parámetros, operaciones sensibles.
    - `EMPLEADO`: operación de ventas/pedidos/inventario según permisos.

## 5. Módulos funcionales prioritarios

## 5.1 Módulo de autenticación
- Pantalla de login.
- Manejo de sesiones activas y expiración.
- Mensajería clara para credenciales inválidas y cuenta bloqueada.

## 5.2 Módulo de ventas
- Registro de venta con detalle dinámico de productos.
- Cálculo visual de subtotales/totales/pagos.
- Confirmación de transacción y estado final.

## 5.3 Módulo de pedidos
- Registro de pedido (`Domicilio`/`Especial`).
- Edición de pedido según estado permitido.
- Cambio de estado con trazabilidad visible.

## 5.4 Módulo de inventario
- Ajuste de stock con motivo obligatorio.
- Consulta de movimientos por filtros.
- Visualización de alertas de stock pendiente.

## 5.5 Módulo de reportes
- Vista de reporte diario, mensual y rotación.
- Filtros por fecha/categoría/modalidad.
- Exportación/impresión según capacidades backend.

## 6. Contratos de integración frontend-backend
- Los DTO de UI deben mapear 1:1 con contratos oficiales de backend.
- Versionar endpoints cuando haya ruptura de contrato.
- Manejar respuestas de error con estructura estándar:
    - `codigo`
    - `mensaje`
    - `detalle`
    - `traceId`
- Mostrar mensajes funcionales amigables y conservar `traceId` para soporte.

## 7. UX operacional y lineamientos de interacción
- Reducir cantidad de clics en flujos críticos de caja.
- Soporte de teclado en formularios de alta frecuencia.
- Confirmaciones explícitas para acciones destructivas (cancelar/eliminar/desactivar).
- Bloqueo visual de acciones durante solicitudes en curso para evitar doble envío.
- Diseño responsive para operación en pantallas de escritorio y tablets.

## 8. Estrategia de calidad en frontend

### 8.1 Pruebas funcionales de UI
- Casos críticos de login, registrar venta, registrar pedido y ajuste de stock.
- Validación de mensajes de error y estados vacíos.

### 8.2 Pruebas de integración API
- Simulación de respuestas exitosas y errores de negocio.
- Validación de refresh token y manejo de sesión expirada.

### 8.3 Pruebas E2E
- Flujo completo:
    1. autenticación,
    2. venta,
    3. pago,
    4. ajuste de inventario,
    5. consulta de reporte.

## 9. Plan por sprint para Fase 4

### Sprint F4-A
- Base del frontend, routing y layout principal.
- Login + guardas por rol + manejo de sesión.

### Sprint F4-B
- Módulo de ventas end-to-end con backend.
- Manejo de errores funcionales y confirmación de operación.

### Sprint F4-C
- Módulo de pedidos e inventario (registro, edición, estados y ajustes).
- Vistas de alertas y movimientos.

### Sprint F4-D
- Módulo de reportes + optimización de UX operativa.
- Endurecimiento de accesibilidad, performance y trazabilidad.

## 10. Criterios de aceptación de Fase 4
- Frontend permite operar autenticación, ventas, pedidos e inventario en entorno integrado.
- Errores de backend se muestran de forma clara y consistente.
- Seguridad de sesión y permisos por rol funcionan correctamente.
- Existe evidencia de pruebas E2E para flujos críticos.
- El sistema está listo para estabilización y optimización final (Fase 5).

## 11. Salida de Fase 4 y entrada a Fase 5
La fase concluye cuando la operación principal del negocio puede ejecutarse de punta a punta
(UI -> API -> DB) con estabilidad suficiente para iniciar optimización de rendimiento,
hardening de seguridad y despliegue controlado.
