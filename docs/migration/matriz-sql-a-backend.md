# Matriz SQL -> Backend (P1 inicial)

| Artefacto SQL | Regla de negocio | Nuevo caso de uso | Clase destino | Prioridad |
|---|---|---|---|---|
| sp_RegistrarVenta | Registrar venta con validación de stock y cálculo total | RegistrarVentaUseCase | application.usecase.RegistrarVentaUseCase | P1 |
| sp_RegistrarPedido | Registrar pedido con datos de entrega y estado inicial | RegistrarPedidoUseCase | application.usecase.RegistrarPedidoUseCase | P1 |
| sp_AgregarPagosTransaccion | Validar que suma de pagos no exceda total neto | AgregarPagosTransaccionUseCase | application.usecase.AgregarPagosTransaccionUseCase | P1 |
| sp_ActualizarEstadoPedido | Transición válida de estados de pedido | ActualizarEstadoPedidoUseCase | application.usecase.ActualizarEstadoPedidoUseCase | P1 |
| trg_DetalleTransaccion_Maintenance | Aplicar reglas de detalle, precio y stock | RegistrarVentaUseCase + políticas | domain.service.PricingPolicy / domain.service.InventoryPolicy | P1 |
| trg_MovInv_ValidateAndUpdate | Ajuste y consistencia de inventario | AplicarAjusteInventarioUseCase | application.usecase.AplicarAjusteInventarioUseCase | P1 |
| trg_PagoTransaccion_CheckSum | Validar consistencia entre pagos y total | AgregarPagosTransaccionUseCase | domain.service.PaymentDomainService | P1 |
| trg_Transaccion_Update | Reglas de cambio de estado de transacción | ActualizarEstadoTransaccionUseCase | domain.service.TransactionStateService | P1 |
| fn_StockDisponible | Consultar stock disponible por producto | ConsultarInventarioUseCase | application.query.InventoryQueryService | P1 |
| fn_TotalPagosTransaccion | Calcular total pagado de una transacción | ConsultarPagosTransaccionUseCase | domain.service.PaymentDomainService | P1 |