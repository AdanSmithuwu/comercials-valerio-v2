CREATE TABLE producto (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    precio_unitario NUMERIC(12, 2) NOT NULL CHECK (precio_unitario >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    stock_total INTEGER NOT NULL DEFAULT 0 CHECK (stock_total >= 0),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cliente (
    id BIGSERIAL PRIMARY KEY,
    documento VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(120),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaccion (
    id BIGSERIAL PRIMARY KEY,
    cliente_id BIGINT NULL,
    estado VARCHAR(30) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL CHECK (subtotal >= 0),
    descuento NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    total NUMERIC(12, 2) NOT NULL CHECK (total >= 0),
    fecha_transaccion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transaccion_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    CONSTRAINT chk_transaccion_estado
        CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'CANCELADA'))
);

CREATE TABLE detalle_transaccion (
    id BIGSERIAL PRIMARY KEY,
    transaccion_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12, 2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal_linea NUMERIC(12, 2) NOT NULL CHECK (subtotal_linea >= 0),
    CONSTRAINT fk_detalle_transaccion
        FOREIGN KEY (transaccion_id) REFERENCES transaccion(id),
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (producto_id) REFERENCES producto(id),
    CONSTRAINT uq_detalle_producto_transaccion
        UNIQUE (transaccion_id, producto_id)
);

CREATE INDEX idx_producto_nombre ON producto(nombre);
CREATE INDEX idx_transaccion_fecha ON transaccion(fecha_transaccion);
CREATE INDEX idx_detalle_transaccion_id ON detalle_transaccion(transaccion_id);