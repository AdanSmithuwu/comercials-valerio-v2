DROP INDEX IF EXISTS cv.ix_alerta_stock_pendiente;
CREATE UNIQUE INDEX ix_alerta_stock_pendiente
    ON cv.alerta_stock (id_producto)
    WHERE procesada = FALSE;

DROP INDEX IF EXISTS cv.ix_alerta_stock_procesada;
CREATE INDEX ix_alerta_stock_procesada
    ON cv.alerta_stock (procesada, fecha_alerta);

DROP INDEX IF EXISTS cv.ix_bitacora_empleado;
CREATE INDEX ix_bitacora_empleado
    ON cv.bitacora_login (id_empleado);

DROP INDEX IF EXISTS cv.ix_bitacora_exitoso_fecha;
CREATE INDEX ix_bitacora_exitoso_fecha
    ON cv.bitacora_login (exitoso, fecha_evento);

DROP INDEX IF EXISTS cv.ix_bitacora_fecha;
CREATE INDEX ix_bitacora_fecha
    ON cv.bitacora_login (fecha_evento);

DROP INDEX IF EXISTS cv.ix_detalle_producto;
CREATE INDEX ix_detalle_producto
    ON cv.detalle_transaccion (id_producto);

DROP INDEX IF EXISTS cv.ix_detalle_talla;
CREATE INDEX ix_detalle_talla
    ON cv.detalle_transaccion (id_talla_stock);

DROP INDEX IF EXISTS cv.ix_detalle_trans_prod_talla;
CREATE UNIQUE INDEX ix_detalle_trans_prod_talla
    ON cv.detalle_transaccion (id_transaccion, id_producto, id_talla_stock);

DROP INDEX IF EXISTS cv.ix_empleado_rol;
CREATE INDEX ix_empleado_rol
    ON cv.empleado (id_rol);

DROP INDEX IF EXISTS cv.ix_movinv_empleado;
CREATE INDEX ix_movinv_empleado
    ON cv.movimiento_inventario (id_empleado);

DROP INDEX IF EXISTS cv.ix_movinv_fecha;
CREATE INDEX ix_movinv_fecha
    ON cv.movimiento_inventario (fecha_hora);

DROP INDEX IF EXISTS cv.ix_movinv_producto;
CREATE INDEX ix_movinv_producto
    ON cv.movimiento_inventario (id_producto);

DROP INDEX IF EXISTS cv.ix_movinv_producto_fecha;
CREATE INDEX ix_movinv_producto_fecha
    ON cv.movimiento_inventario (id_producto, fecha_hora);

DROP INDEX IF EXISTS cv.ix_movinv_tipo;
CREATE INDEX ix_movinv_tipo
    ON cv.movimiento_inventario (id_tipo_movimiento);

DROP INDEX IF EXISTS cv.ix_orden_cliente;
CREATE INDEX ix_orden_cliente
    ON cv.orden_compra (id_cliente);

DROP INDEX IF EXISTS cv.ix_orden_fecha_cumplida;
CREATE INDEX ix_orden_fecha_cumplida
    ON cv.orden_compra (fecha_cumplida);

DROP INDEX IF EXISTS cv.ix_orden_pedido;
CREATE INDEX ix_orden_pedido
    ON cv.orden_compra (id_pedido);

DROP INDEX IF EXISTS cv.ix_orden_producto;
CREATE INDEX ix_orden_producto
    ON cv.orden_compra (id_producto);

DROP INDEX IF EXISTS cv.ix_orden_pdf_fecha;
CREATE INDEX ix_orden_pdf_fecha
    ON cv.orden_compra_pdf (fecha_generacion);

DROP INDEX IF EXISTS cv.ix_pago_metodo;
CREATE INDEX ix_pago_metodo
    ON cv.pago_transaccion (id_metodo_pago);

DROP INDEX IF EXISTS cv.ix_pedido_empleado_entrega;
CREATE INDEX ix_pedido_empleado_entrega
    ON cv.pedido (id_empleado_entrega);

DROP INDEX IF EXISTS cv.ix_pedido_tipo;
CREATE INDEX ix_pedido_tipo
    ON cv.pedido (tipo_pedido);

DROP INDEX IF EXISTS cv.ix_presentacion_producto;
CREATE INDEX ix_presentacion_producto
    ON cv.presentacion (id_producto);

DROP INDEX IF EXISTS cv.ix_producto_categoria;
CREATE INDEX ix_producto_categoria
    ON cv.producto (id_categoria);

DROP INDEX IF EXISTS cv.ix_producto_tipo;
CREATE INDEX ix_producto_tipo
    ON cv.producto (id_tipo_producto);

DROP INDEX IF EXISTS cv.ix_producto_mayorista;
CREATE INDEX ix_producto_mayorista
    ON cv.producto (mayorista);

DROP INDEX IF EXISTS cv.ix_producto_stock;
CREATE INDEX ix_producto_stock
    ON cv.producto (stock_actual);

DROP INDEX IF EXISTS cv.ix_reporte_empleado;
CREATE INDEX ix_reporte_empleado
    ON cv.reporte (id_empleado);

DROP INDEX IF EXISTS cv.ix_reporte_fecha;
CREATE INDEX ix_reporte_fecha
    ON cv.reporte (fecha_generacion);

DROP INDEX IF EXISTS cv.ix_talla_producto;
CREATE INDEX ix_talla_producto
    ON cv.talla_stock (id_producto);

DROP INDEX IF EXISTS cv.ix_trans_cliente_fecha;
CREATE INDEX ix_trans_cliente_fecha
    ON cv.transaccion (id_cliente, fecha);

DROP INDEX IF EXISTS cv.ix_trans_fecha;
CREATE INDEX ix_trans_fecha
    ON cv.transaccion (fecha);