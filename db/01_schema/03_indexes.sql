CREATE INDEX idx_trans_cliente_fecha
ON cv.transaccion (id_cliente, fecha);

CREATE INDEX idx_trans_fecha
ON cv.transaccion (fecha);

CREATE INDEX idx_detalle_producto
ON cv.detalle_transaccion (id_producto);

CREATE INDEX idx_detalle_talla
ON cv.detalle_transaccion (id_talla_stock);

CREATE INDEX idx_mov_producto
ON cv.movimiento_inventario (id_producto);

CREATE INDEX idx_mov_fecha
ON cv.movimiento_inventario (fecha_hora);

CREATE INDEX idx_mov_tipo
ON cv.movimiento_inventario (id_tipo_movimiento);

CREATE INDEX idx_mov_producto
ON cv.movimiento_inventario (id_producto);

CREATE INDEX idx_mov_fecha
ON cv.movimiento_inventario (fecha_hora);

CREATE INDEX idx_mov_tipo
ON cv.movimiento_inventario (id_tipo_movimiento);

CREATE INDEX idx_bitacora_empleado
ON cv.bitacora_login (id_empleado);

CREATE INDEX idx_bitacora_fecha
ON cv.bitacora_login (fecha_evento);

CREATE UNIQUE INDEX idx_alerta_pendiente
ON cv.alerta_stock (id_producto)
WHERE procesada = FALSE;