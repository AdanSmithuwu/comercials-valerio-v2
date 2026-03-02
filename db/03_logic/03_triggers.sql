/* Valida que el comprobante solo se registre para Venta o Pedido existente */
CREATE OR REPLACE FUNCTION fn_comprobante_validate()
RETURNS trigger AS
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM venta v
        WHERE v.idtransaccion = NEW.idtransaccion
    )
    AND NOT EXISTS (
        SELECT 1
        FROM pedido p
        WHERE p.idtransaccion = NEW.idtransaccion
    )
    THEN
        RAISE EXCEPTION
            USING MESSAGE = 'Comprobante solo para Venta o Pedido.',
                  ERRCODE = 'P0001';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_comprobante_insert
AFTER INSERT ON comprobante
FOR EACH ROW
EXECUTE FUNCTION fn_comprobante_validate();

/* Mantiene pagos = total en transacciones cerradas */
CREATE OR REPLACE FUNCTION fn_pago_transaccion_checksum()
RETURNS trigger AS
$$
DECLARE
    v_id_transaccion INT;
    v_total_pagos NUMERIC;
    v_total_neto NUMERIC;
    v_estado TEXT;
BEGIN

    -- Obtener idTransaccion afectado
    IF TG_OP = 'DELETE' THEN
        v_id_transaccion := OLD.idtransaccion;
    ELSE
        v_id_transaccion := NEW.idtransaccion;
    END IF;

    -- Obtener estado y total neto
    SELECT t.totalneto, t.estado
    INTO v_total_neto, v_estado
    FROM transaccion t
    WHERE t.idtransaccion = v_id_transaccion;

    -- Solo validar si está cerrada
    IF v_estado IN ('Completada', 'Entregada') THEN

        SELECT COALESCE(SUM(p.monto), 0)
        INTO v_total_pagos
        FROM pagotransaccion p
        WHERE p.idtransaccion = v_id_transaccion;

        IF v_total_pagos <> v_total_neto THEN
            RAISE EXCEPTION
                USING MESSAGE = 'La suma de pagos debe coincidir con el total neto para transacciones cerradas.',
                      ERRCODE = 'P0001';
        END IF;

    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pago_transaccion_checksum
AFTER INSERT OR UPDATE OR DELETE
ON pago_transaccion
FOR EACH ROW
EXECUTE FUNCTION fn_pago_transaccion_checksum();

/* Valida estado y reglas de tipo y precio en Presentacion */
CREATE OR REPLACE FUNCTION fn_presentacion_validate()
RETURNS trigger AS
$$
DECLARE
    v_es_fraccionable BOOLEAN;
    v_precio_unitario NUMERIC;
BEGIN

    -- B) Validar que el producto sea fraccionable
    SELECT (p.tipo = 'Fraccionable')
    INTO v_es_fraccionable
    FROM producto p
    WHERE p.idproducto = NEW.idproducto;

    IF NOT v_es_fraccionable THEN
        RAISE EXCEPTION
            USING MESSAGE = 'Sólo productos de tipo Fraccionable permiten presentaciones.',
                  ERRCODE = 'P0001';
    END IF;

    -- C) Validar precio proporcional
    SELECT p.preciounitario
    INTO v_precio_unitario
    FROM producto p
    WHERE p.idproducto = NEW.idproducto;

    IF NEW.precio > NEW.cantidad * v_precio_unitario THEN
        RAISE EXCEPTION
            USING MESSAGE = 'El precio de la presentación excede el proporcional del precio unitario.',
                  ERRCODE = 'P0001';
    END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_presentacion_validate
BEFORE INSERT OR UPDATE
ON presentacion
FOR EACH ROW
EXECUTE FUNCTION fn_presentacion_validate();
