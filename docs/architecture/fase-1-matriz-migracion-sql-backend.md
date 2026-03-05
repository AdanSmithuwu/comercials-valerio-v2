# Fase 1: Inventario funcional y matriz de migración SQL -> Backend

## 1. Objetivo
Definir el plan ejecutable para migrar la lógica de negocio histórica de SQL Server
(triggers, procedimientos, funciones y vistas) hacia una arquitectura moderna con
Spring Boot + PostgreSQL, minimizando riesgo funcional.

## 2. Criterios de decisión por artefacto
- **Se queda en DB**: integridad estructural (PK, FK, UNIQUE, CHECK simples, índices).
- **Migra a backend**: reglas de proceso, validaciones de flujo, cálculo de negocio,
  transición de estados y control operativo.
- **Evaluación mixta**: reportes y agregaciones (consulta SQL optimizada + servicio Java).

## 3. Matriz de migración priorizada (P1/P2/P3)

## 3.1 Triggers (SQL Server -> Spring Boot)

| Prioridad | Artefacto SQL | Responsabilidad actual | Destino objetivo | Componente sugerido |
|---|---|---|---|---|
| P1 | `trg_DetalleTransaccion_Maintenance` | Valida talla/producto, aplica precio mayorista, controla estado de transacción, recalcula totales | Backend transaccional | `TransactionService`, `PricingPolicy`, `InventoryPolicy` |
| P1 | `trg_MovInv_ValidateAndUpdate` | Valida ajuste y sincroniza stock por movimiento | Backend + locking | `InventoryService` |
| P1 | `trg_PagoTransaccion_CheckSum` | Verifica suma de pagos vs total neto | Backend en cierre de transacción | `PaymentService` |
| P1 | `trg_Transaccion_Update` | Reglas de transición de estado de transacción | Backend con state machine | `TransactionStateService` |
| P1 | `trg_Pedido_Validate` | Reglas de pedidos (tipo, datos de entrega y consistencia) | Backend | `OrderService` |
| P2 | `trg_Producto_ValidateAndAdjust` | Reglas de activación, umbral y coherencia de atributos | Backend + constraints simples en DB | `ProductService` |
| P2 | `trg_TallaStock_ValidateAndUpdate` | Coherencia de stock por talla y producto | Backend | `InventoryService` |
| P2 | `trg_Empleado_LoginHandling` | Bloqueo por intentos y fecha de desbloqueo | Backend de seguridad | `AuthService` |
| P3 | `trg_Comprobante_Insert` | Restringe comprobantes a transacciones válidas | FK + validación backend | `ReceiptService` |
| P3 | `trg_Persona_ValidarEstado` | Consistencia de estado en persona | Backend + FK/estado catálogo | `PersonService` |
| P3 | `trg_Venta_Insert` | Reglas al crear venta | Backend | `SalesService` |
| P3 | `trg_Presentacion_Validate` | Coherencia de presentación por producto | Backend + CHECK | `ProductPresentationService` |
| P3 | `trg_Rol_AdminOnly` | Restricción administrativa | Seguridad de API | `AuthorizationService` |
| P3 | `trg_ParametroSistema_AdminOnly` | Restricción administrativa sobre parámetros | Seguridad de API | `SystemParameterService` |

## 3.2 Stored Procedures (SQL Server -> Casos de uso)

| Prioridad | SP | Dominio | Caso de uso backend |
|---|---|---|---|
| P1 | `sp_RegistrarVenta` | Ventas | `RegistrarVentaUseCase` |
| P1 | `sp_RegistrarPedido` | Pedidos | `RegistrarPedidoUseCase` |
| P1 | `sp_ModificarPedido` | Pedidos | `ModificarPedidoUseCase` |
| P1 | `sp_AplicarAjusteInventario` | Inventario | `AplicarAjusteInventarioUseCase` |
| P1 | `sp_AgregarPagosTransaccion` | Pagos | `AgregarPagosTransaccionUseCase` |
| P1 | `sp_ActualizarEstadoPedido` | Pedidos | `ActualizarEstadoPedidoUseCase` |
| P1 | `sp_CancelarVenta` | Ventas | `CancelarVentaUseCase` |
| P2 | `sp_RegistrarCliente` | Clientes | `RegistrarClienteUseCase` |
| P2 | `sp_RegistrarEmpleado` | Empleados/Seguridad | `RegistrarEmpleadoUseCase` |
| P2 | `sp_ValidarPersonaBasica` | Clientes/Empleados | `ValidarPersonaBasicaService` |
| P2 | `sp_PrepararTransaccion` | Ventas/Pedidos | Integrado en `TransactionPreparationService` |
| P2 | `sp_DescontarStock_Detalle` | Inventario | Integrado en `InventoryService` |
| P2 | `sp_ListarAlertasPendientes` | Inventario/Alertas | `ListarAlertasPendientesQuery` |
| P2 | `sp_ListarPedidosPendientes` | Pedidos | `ListarPedidosPendientesQuery` |
| P3 | `sp_InsertCategoria` | Catálogos | `CrearCategoriaUseCase` |
| P3 | `sp_UpdateCategoria` | Catálogos | `EditarCategoriaUseCase` |
| P3 | `sp_DeleteCategoria` | Catálogos | `EliminarCategoriaUseCase` |
| P3 | `sp_CambiarEstadoCategoria` | Catálogos | `CambiarEstadoCategoriaUseCase` |
| P3 | `sp_GenerarReporteDiario` | Reportes | `GenerarReporteDiarioUseCase` |
| P3 | `sp_GenerarReporteMensual` | Reportes | `GenerarReporteMensualUseCase` |
| P3 | `sp_GenerarReporteRotacion` | Reportes | `GenerarReporteRotacionUseCase` |
| P3 | `sp_RecalcularStockProductos` | Inventario | Job interno `RecalcularStockJob` |
| P3 | `sp_DepurarBitacoraLogin` | Seguridad | Job interno `DepurarBitacoraLoginJob` |
| P3 | `sp_ListarClientesFrecuentes` | Reportes/Clientes | Query read model `ClientesFrecuentesQuery` |
| P3 | `sp_SetSessionFlags` | Infra SQL Server | Eliminar (no aplica en arquitectura nueva) |
| P3 | `sp_DisableSeedTriggers` / `sp_EnableSeedTriggers` | Infra SQL Server | Eliminar (no aplica) |
| P3 | `sp_ValidarEstado` / `sp_AssertEmpleadoContext` / `sp_AssertAdmin` / `sp_CheckAdminTrigger` | Seguridad técnica SQL | Sustituir por autorización JWT + reglas de aplicación |

## 3.3 Funciones SQL (SQL Server -> Dominio/infra)

| Prioridad | Función | Destino |
|---|---|---|
| P1 | `fn_StockDisponible`, `fn_StockDisponibleTalla` | `InventoryQueryService` |
| P1 | `fn_TotalPagosTransaccion` | `PaymentDomainService` |
| P1 | `fn_EsTipoProducto` | `ProductTypePolicy` |
| P1 | `fn_GetParametroDecimal`, `fn_CargoRepartoActual`, `fn_DescuentoValeGas` | `SystemParameterService` |
| P2 | `fn_MinCantidadMayoristaHilo`, `fn_MaxIntentosFallidos`, `fn_MinutosBloqueoCuenta` | Parámetros de configuración versionados |
| P2 | `fn_EsTelefonoValido`, `fn_NormalizarTelefono`, `fn_NormalizarEspacios`, `fn_Capitalizar` | Utilidades de validación/normalización en backend |
| P3 | `fn_NombreCompleto` | Proyección en consultas o mapper DTO |
| P3 | `fn_actor_id`, `fn_actor_nivel` | Eliminadas por JWT/Contexto de seguridad de Spring |
| P3 | `fn_AssertEstadoModulo`, `fn_TieneStockNegativo` | Reglas de dominio directas en servicios |

## 3.4 Vistas de reporte (SQL Server -> Read model)

| Prioridad | Vista | Estrategia objetivo |
|---|---|---|
| P2 | `vw_TransaccionesPorDia` | Query SQL nativa optimizada + endpoint de dashboard |
| P2 | `vw_PagoMetodoDia` | Query SQL nativa optimizada |
| P2 | `vw_ReporteMensualCategoria` | Query agregada con índices por periodo/categoría |
| P2 | `vw_ResumenMensualModalidad` | Query agregada por modalidad |
| P2 | `vw_RotacionMensual`, `vw_RotacionRango` | Query agregada o vista materializada según volumen |
| P3 | `vw_ClientesFrecuentes`, `vw_HistorialTransaccionesPorCliente`, `vw_ProductosMasVendidos`, `vw_ClientesActivos` | Read models para módulo comercial |

## 4. Backlog técnico por sprint (propuesta)

### Sprint 1 (P1 Ventas/Pagos)
- Implementar `RegistrarVentaUseCase`.
- Implementar `AgregarPagosTransaccionUseCase`.
- Implementar reglas de totales, precios y validación de pagos.
- Implementar pruebas de integración con PostgreSQL para flujo de venta.

### Sprint 2 (P1 Pedidos/Inventario)
- Implementar `RegistrarPedidoUseCase`, `ModificarPedidoUseCase`, `ActualizarEstadoPedidoUseCase`.
- Implementar `AplicarAjusteInventarioUseCase` y políticas de stock.
- Resolver concurrencia de stock (bloqueo optimista/pesimista por caso).

### Sprint 3 (P2 Seguridad/Personas)
- Implementar autenticación JWT y autorización por rol.
- Implementar registro de empleado/cliente con validaciones.
- Implementar bitácora de acceso y política de bloqueo por intentos.

### Sprint 4 (P2/P3 Reportes y cierre de legado SQL)
- Implementar endpoints de reportes diarios/mensuales/rotación.
- Evaluar vistas materializadas para consultas de alta carga.
- Retirar dependencias restantes de SP/triggers no migrados.

## 5. Criterios de aceptación de Fase 1
- Existe trazabilidad completa de cada trigger/SP/función/vista a su destino.
- Cada artefacto está priorizado con una estrategia concreta (migrar, mantener, eliminar).
- Se aprueba backlog de sprints para iniciar implementación técnica.

## 6. Dependencias para iniciar Fase 2
- Confirmación del stack de migraciones DB (Flyway o Liquibase).
- Aprobación de naming conventions y versionado de APIs.
- Definición de catálogo de errores funcionales y códigos de negocio.
