# Fase 3: Implementación del backend core (Spring Boot)

## 1. Objetivo
Implementar el núcleo transaccional del sistema en Spring Boot, trasladando la lógica crítica
que hoy reside en SP/triggers hacia casos de uso, servicios de dominio y políticas de negocio.

## 2. Alcance de Fase 3
- Construir el esqueleto productivo del backend por capas.
- Implementar casos de uso críticos de ventas, pedidos e inventario.
- Integrar seguridad JWT con autorización por rol.
- Definir contratos API mínimos para operación inicial de frontend.
- Establecer estándares de errores, transacciones y observabilidad.

## 3. Arquitectura interna objetivo

### 3.1 Capas
- **domain**
    - Entidades agregadas: `Transaccion`, `Pedido`, `DetalleTransaccion`, `Producto`, `MovimientoInventario`.
    - Objetos de valor: dinero, cantidad, estado, identificadores tipados.
    - Políticas: precio mayorista, validación de stock, transición de estados.
- **application**
    - Casos de uso orquestadores (`UseCase`/`Service`).
    - Puertos de salida para repositorios y servicios externos.
    - Gestión transaccional y publicación de eventos de dominio.
- **infrastructure**
    - Adaptadores de persistencia PostgreSQL (JPA o SQL nativo según caso).
    - Configuración JWT, filtros de seguridad, auditoría técnica.
    - Integración con migraciones Flyway.
- **presentation-api** (dentro del backend)
    - Controladores REST, DTOs, validaciones de request.
    - Mapeo de errores de negocio a códigos HTTP y payload funcional.

### 3.2 Reglas de diseño
- Ningún controlador debe contener lógica de negocio.
- Ningún repositorio debe decidir reglas de proceso.
- Todas las reglas de negocio críticas deben ser testeables en capa `domain`/`application`.

## 4. Casos de uso prioritarios de implementación

## 4.1 Ventas (prioridad alta)
- `RegistrarVentaUseCase`
    - Valida cliente/empleado/estado.
    - Calcula total bruto/neto, descuentos y cargos.
    - Valida pagos y consistencia de suma.
    - Actualiza inventario según reglas del producto.
- `CancelarVentaUseCase`
    - Valida estado cancelable.
    - Revierte stock cuando aplique.
    - Registra motivo y auditoría.

## 4.2 Pedidos (prioridad alta)
- `RegistrarPedidoUseCase`
    - Valida tipo de pedido (`Domicilio`, `Especial`).
    - Determina cargos/descuentos parametrizados.
    - Reserva/descuenta stock según política definida.
- `ModificarPedidoUseCase`
    - Aplica reglas de edición por estado y ventana operativa.
- `ActualizarEstadoPedidoUseCase`
    - Aplica máquina de estados y reglas de transición.

## 4.3 Inventario (prioridad alta)
- `AplicarAjusteInventarioUseCase`
    - Registra movimiento con motivo y actor.
    - Asegura no negatividad de stock.
    - Garantiza consistencia producto/talla.

## 5. Contratos API mínimos (MVP backend)

### 5.1 Seguridad
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`

### 5.2 Ventas y pedidos
- `POST /api/transacciones/ventas`
- `POST /api/transacciones/pedidos`
- `PUT /api/transacciones/pedidos/{id}`
- `PATCH /api/transacciones/pedidos/{id}/estado`
- `POST /api/transacciones/{id}/pagos`
- `POST /api/transacciones/{id}/cancelacion`

### 5.3 Inventario
- `POST /api/inventario/ajustes`
- `GET /api/inventario/movimientos`
- `GET /api/inventario/alertas`

## 6. Seguridad y autorización
- JWT con access token corto y refresh token controlado.
- Roles iniciales: `ADMIN`, `EMPLEADO`.
- Política mínima por endpoint:
    - Gestión de parámetros y catálogos críticos: solo `ADMIN`.
    - Operaciones de venta/pedido/inventario: `ADMIN` y `EMPLEADO` con permisos específicos.
- Bloqueo por intentos fallidos y bitácora de autenticación en backend.

## 7. Transaccionalidad y concurrencia
- Operaciones de venta/pedido/ajuste inventario dentro de transacción ACID.
- Definir estrategia por caso:
    - Bloqueo pesimista para actualización de stock en alta contención.
    - Optimista para entidades de baja colisión.
- Evitar condiciones de carrera en doble venta del mismo stock.

## 8. Errores funcionales y observabilidad

### 8.1 Catálogo de errores
- Definir códigos de error de negocio (ejemplo: `TX_STOCK_INSUFICIENTE`, `TX_ESTADO_INVALIDO`).
- Retornar payload uniforme:
    - `codigo`
    - `mensaje`
    - `detalle`
    - `timestamp`
    - `traceId`

### 8.2 Observabilidad
- Logs estructurados JSON.
- Correlación por `traceId` en toda la cadena request -> servicio -> repositorio.
- Métricas mínimas:
    - tiempo de respuesta por endpoint,
    - tasa de error por caso de uso,
    - conflictos de concurrencia en inventario.

## 9. Plan por sprint para Fase 3

### Sprint A
- Estructura base del backend y seguridad JWT.
- Endpoint de login y autorización por rol.
- Setup de Flyway en entorno local e integración.

### Sprint B
- Implementación de `RegistrarVentaUseCase` + pagos.
- Pruebas de integración de flujo de venta completo.
- Validación de concurrencia básica de inventario.

### Sprint C
- Implementación de `RegistrarPedidoUseCase`, `ModificarPedidoUseCase` y transición de estado.
- Endpoints de inventario (ajustes/movimientos/alertas).

### Sprint D
- Endpoints de reportes iniciales para frontend.
- Endurecimiento de errores, métricas y auditoría.
- Revisión de performance de consultas clave.

## 10. Criterios de aceptación de Fase 3
- Casos de uso críticos operativos por API (`ventas`, `pedidos`, `inventario`).
- Seguridad JWT activa con control por rol.
- Migraciones de DB integradas en startup/pipeline.
- Errores funcionales estandarizados y trazables.
- Evidencia de pruebas de integración para flujos críticos.

## 11. Salida de Fase 3 y entrada a Fase 4
La fase termina cuando el backend permite operar los procesos críticos de negocio y
expone contratos estables para que frontend React complete la operación end-to-end.
