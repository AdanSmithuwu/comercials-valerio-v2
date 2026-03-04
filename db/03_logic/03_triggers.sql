/*
 Valida coherencia estructural de Presentacion:
 - El estado debe pertenecer al módulo 'Producto'
 - Solo productos tipo 'Fraccionable' permiten presentaciones
 - El precio no puede exceder el proporcional del precio unitario
*/
CREATE OR REPLACE FUNCTION cv.fn_presentacion_validate()
RETURNS trigger AS
$$
DECLARE
    v_es_frac BOOLEAN;
    v_es_vest BOOLEAN;
    v_precio_unit NUMERIC;
BEGIN
    -- A) Validar que el estado pertenezca al módulo Producto
    IF NOT EXISTS (
        SELECT 1
        FROM cv.estado e
        WHERE e.id_estado = NEW.id_estado
          AND e.modulo = 'Producto'
    ) THEN
        RAISE EXCEPTION
        'El estado % no pertenece al módulo Producto.', NEW.id_estado;
        END IF;

    -- B) Validar tipo de producto
    SELECT
        cv.fn_es_tipo_producto(NEW.id_producto, 'Fraccionable'),
        cv.fn_es_tipo_producto(NEW.id_producto, 'Vestimenta')
    INTO v_es_frac, v_es_vest;

    IF NOT v_es_frac THEN
        RAISE EXCEPTION
        'Sólo productos de tipo Fraccionable permiten presentaciones.';
    END IF;

    -- C) Validar precio proporcional
    SELECT precio_unitario
    INTO v_precio_unit
    FROM cv.producto
    WHERE id_producto = NEW.id_producto;

    IF NEW.precio > NEW.cantidad * v_precio_unit THEN
        RAISE EXCEPTION
        'El precio de la presentación excede el proporcional del precio unitario.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_presentacion_validate
BEFORE INSERT OR UPDATE
ON cv.presentacion
FOR EACH ROW
EXECUTE FUNCTION cv.fn_presentacion_validate();


/*
 Mantiene coherencia financiera:
 La suma de pagos debe ser igual al total_neto
 cuando la transacción está en estado 'Completada' o 'Entregada'
*/
CREATE OR REPLACE FUNCTION cv.fn_pago_transaccion_checksum()
RETURNS trigger AS
$$
DECLARE
    v_id INTEGER;
BEGIN
    v_id := COALESCE(NEW.id_transaccion, OLD.id_transaccion);

    IF EXISTS (
        SELECT 1
        FROM cv.transaccion t
        JOIN cv.estado e ON e.id_estado = t.id_estado
        WHERE t.id_transaccion = v_id
          AND e.modulo = 'Transaccion'
          AND e.nombre IN ('Completada','Entregada')
          AND (
                SELECT COALESCE(SUM(p.monto),0)
                FROM cv.pago_transaccion p
                WHERE p.id_transaccion = v_id
              ) <> t.total_neto
    ) THEN
        RAISE EXCEPTION
        'La suma de pagos debe coincidir con el total neto para transacciones cerradas.';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pago_transaccion_checksum
AFTER INSERT OR UPDATE OR DELETE
ON cv.pago_transaccion
FOR EACH ROW
EXECUTE FUNCTION cv.fn_pago_transaccion_checksum();


/*
 Valida integridad estructural de Transaccion:
 - El estado debe pertenecer al módulo 'Transaccion'
 - Para cerrar (Completada/Entregada) debe existir al menos un detalle
 - No permite modificar montos ni cliente cuando la transacción está cerrada
*/
CREATE OR REPLACE FUNCTION cv.fn_transaccion_validate()
RETURNS trigger AS
$$
DECLARE
    v_estado_nombre TEXT;
BEGIN
    -- Validar que el estado pertenezca al módulo Transaccion
    IF NOT EXISTS (
        SELECT 1
        FROM cv.estado e
        WHERE e.id_estado = NEW.id_estado
          AND e.modulo = 'Transaccion'
    ) THEN
        RAISE EXCEPTION
        'Estado inválido para módulo Transaccion.';
    END IF;

    -- Obtener nombre del estado
    SELECT nombre INTO v_estado_nombre
    FROM cv.estado
    WHERE id_estado = NEW.id_estado;

    -- Si se está cerrando
    IF TG_OP = 'UPDATE' AND OLD.id_estado <> NEW.id_estado
        AND v_estado_nombre IN ('Completada','Entregada') THEN

            -- Debe existir al menos un detalle
            IF NOT EXISTS (
                SELECT 1
                FROM cv.detalle_transaccion d
                WHERE d.id_transaccion = NEW.id_transaccion
            ) THEN
                RAISE EXCEPTION
                'Para cerrar la transacción debe existir al menos un detalle.';
        END IF;

    END IF;

    -- Si ya estaba cerrada, bloquear cambios estructurales
    IF TG_OP = 'UPDATE' THEN
        IF EXISTS (
            SELECT 1
            FROM cv.estado e
            WHERE e.id_estado = OLD.id_estado
              AND e.nombre IN ('Completada','Entregada','Cancelada')
        ) THEN
            IF NEW.total_bruto  <> OLD.total_bruto OR
               NEW.descuento    <> OLD.descuento OR
               NEW.cargo        <> OLD.cargo OR
               NEW.total_neto   <> OLD.total_neto OR
               NEW.id_cliente   <> OLD.id_cliente THEN

                RAISE EXCEPTION
                'Transacción cerrada: no se permite modificar montos ni cliente.';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transaccion_validate
BEFORE INSERT OR UPDATE
ON cv.transaccion
FOR EACH ROW
EXECUTE FUNCTION cv.fn_transaccion_validate();

/*
 Valida coherencia estructural en MovimientoInventario:
 - Sólo productos tipo 'Vestimenta' pueden usar id_talla_stock
 - id_talla_stock debe pertenecer al mismo producto
 - Motivo obligatorio para tipo 'Ajuste'
 - No permite que el stock quede negativo
*/
CREATE OR REPLACE FUNCTION cv.fn_movinv_validate()
RETURNS trigger AS
$$
DECLARE
    v_es_vest BOOLEAN;
    v_tipo_nombre TEXT;
    v_stock_actual NUMERIC;
    v_delta NUMERIC;
BEGIN
    -- Validar coherencia talla-producto
    IF NEW.id_talla_stock IS NOT NULL THEN
        SELECT fn_es_tipo_producto(NEW.id_producto, 'Vestimenta')
        INTO v_es_vest;

        IF NOT v_es_vest THEN
            RAISE EXCEPTION
            'Sólo productos de tipo Vestimenta pueden usar id_talla_stock.';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM cv.talla_stock ts
            WHERE ts.id_talla_stock = NEW.id_talla_stock
              AND ts.id_producto = NEW.id_producto
        ) THEN
            RAISE EXCEPTION
            'El id_talla_stock no corresponde al producto indicado.';
        END IF;
    END IF;

    -- Obtener tipo de movimiento
    SELECT nombre
    INTO v_tipo_nombre
    FROM cv.tipo_movimiento
    WHERE id_tipo_movimiento = NEW.id_tipo_movimiento;

    -- Motivo obligatorio para Ajuste
    IF v_tipo_nombre = 'Ajuste'
        AND (NEW.motivo IS NULL OR trim(NEW.motivo) = '') THEN
        RAISE EXCEPTION
        'El motivo es obligatorio para movimientos de ajuste.';
    END IF;

    -- Validar que no deje stock negativo (solo validación, no actualización)
    SELECT stock_actual
    INTO v_stock_actual
    FROM cv.producto
    WHERE id_producto = NEW.id_producto;

    v_delta := CASE
                    WHEN v_tipo_nombre IN ('Entrada','Cancelación')
                        THEN NEW.cantidad
                    ELSE -NEW.cantidad
                END;

    IF v_stock_actual + v_delta < 0 THEN
        RAISE EXCEPTION
        'Stock negativo tras movimiento.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_movinv_validate
BEFORE INSERT
ON cv.movimiento_inventario
FOR EACH ROW
EXECUTE FUNCTION cv.fn_movinv_validate();