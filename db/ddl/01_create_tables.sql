CREATE DATABASE cv_ventas_v2;

CREATE SCHEMA cv;
SELECT schema_name FROM information_schema.schemata;
ALTER DATABASE cv_ventas_v2
SET search_path TO cv, public;

CREATE TABLE cv.rol (
    id_rol INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE,
    nivel SMALLINT NOT NULL UNIQUE
);

CREATE TABLE cv.metodo_pago (
    id_metodo_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cv.tipo_producto (
    id_tipo_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cv.categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(120),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_categoria_estado
        CHECK (estado IN ('ACTIVO','INACTIVO'))
    );

CREATE TABLE cv.persona (
    id_persona INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(60) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    dni CHAR(8) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_persona_dni
       CHECK (dni ~ '^[0-9]{8}$'),
    CONSTRAINT chk_persona_telefono
        CHECK (
            telefono IS NULL OR
            telefono ~ '^[0-9]{6,15}$'
        ),
    CONSTRAINT chk_persona_estado
        CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE cv.cliente (
    id_persona INTEGER PRIMARY KEY,
    direccion VARCHAR(120) NOT NULL,
    CONSTRAINT fk_cliente_persona
        FOREIGN KEY (id_persona)
        REFERENCES cv.persona(id_persona)
        ON DELETE CASCADE
);

CREATE TABLE cv.empleado (
    id_persona INTEGER PRIMARY KEY,
    id_rol INTEGER NOT NULL,
    CONSTRAINT fk_empleado_persona
        FOREIGN KEY (id_persona)
        REFERENCES cv.persona(id_persona)
        ON DELETE CASCADE,
    CONSTRAINT fk_empleado_rol
        FOREIGN KEY (id_rol)
        REFERENCES cv.rol(id_rol)
);

CREATE TABLE cv.usuario (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(120) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_cambio_clave TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    intentos_fallidos INTEGER NOT NULL DEFAULT 0 CHECK (intentos_fallidos >= 0),
    bloqueado_hasta TIMESTAMP,
    id_empleado INTEGER NOT NULL UNIQUE,
    CONSTRAINT fk_usuario_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona)
        ON DELETE CASCADE
);

CREATE TABLE cv.tipo_movimiento (
    id_tipo_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cv.producto (
    id_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(90) NOT NULL UNIQUE,
    descripcion VARCHAR(120),
    id_categoria INTEGER NOT NULL,
    id_tipo_producto INTEGER NOT NULL,
    unidad_medida VARCHAR(10) NOT NULL,
    precio_unitario NUMERIC(10,2) CHECK (precio_unitario >= 0),
    mayorista BOOLEAN NOT NULL DEFAULT FALSE,
    min_mayorista INTEGER CHECK (min_mayorista > 0),
    precio_mayorista NUMERIC(10,2) CHECK (precio_mayorista >= 0),
    para_pedido BOOLEAN NOT NULL DEFAULT FALSE,
    ignorar_umbral_hasta_cero BOOLEAN NOT NULL DEFAULT FALSE,
    tipo_pedido_default VARCHAR(20)
        CHECK (tipo_pedido_default IS NULL OR tipo_pedido_default IN ('Domicilio','Especial')),
    stock_actual NUMERIC(12,3) CHECK (stock_actual >= 0),
    umbral NUMERIC(12,3) NOT NULL DEFAULT 0 CHECK (umbral >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT chk_producto_estado
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    CONSTRAINT chk_producto_mayorista
        CHECK (
            (mayorista = TRUE AND min_mayorista IS NOT NULL AND precio_mayorista IS NOT NULL)
            OR
            (mayorista = FALSE AND min_mayorista IS NULL AND precio_mayorista IS NULL)
        ),

    CONSTRAINT chk_precio_mayorista
        CHECK (
            precio_mayorista IS NULL
            OR precio_mayorista < precio_unitario
        ),

    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES cv.categoria(id_categoria),

    CONSTRAINT fk_producto_tipo
        FOREIGN KEY (id_tipo_producto)
        REFERENCES cv.tipo_producto(id_tipo_producto)
);

CREATE TABLE cv.talla_stock (
    id_talla_stock INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    talla VARCHAR(6) NOT NULL,
    stock NUMERIC(12,3) NOT NULL CHECK (stock >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT chk_talla_estado
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    CONSTRAINT uq_talla_producto
        UNIQUE (id_producto, talla),

    CONSTRAINT fk_talla_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
        ON DELETE CASCADE
);

CREATE TABLE cv.presentacion (
    id_presentacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    cantidad NUMERIC(8,3) NOT NULL CHECK (cantidad > 0),
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT chk_presentacion_estado
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    CONSTRAINT uq_presentacion
        UNIQUE (id_producto, cantidad),

    CONSTRAINT fk_presentacion_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
        ON DELETE CASCADE
);

CREATE TABLE cv.transaccion (
    id_transaccion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'EN_PROCESO',
    total_bruto NUMERIC(10,2) NOT NULL CHECK (total_bruto >= 0),
    descuento NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    cargo NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (cargo >= 0),
    observacion VARCHAR(120),
    motivo_cancelacion VARCHAR(120),
    id_empleado INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,

    CONSTRAINT chk_trans_estado
        CHECK (estado IN ('EN_PROCESO','CONFIRMADA','CANCELADA')),

    CONSTRAINT chk_descuento_menor
        CHECK (descuento <= total_bruto),

    CONSTRAINT fk_trans_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona),

    CONSTRAINT fk_trans_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cv.cliente(id_persona)
);

CREATE TABLE cv.venta (
    id_transaccion INTEGER PRIMARY KEY,
    CONSTRAINT fk_venta_trans
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE
);

CREATE TABLE cv.pedido (
    id_transaccion INTEGER PRIMARY KEY,
    direccion_entrega VARCHAR(120) NOT NULL,
    fecha_hora_entrega TIMESTAMP,
    id_empleado_entrega INTEGER,
    tipo_pedido VARCHAR(20) NOT NULL CHECK (tipo_pedido IN ('Domicilio','Especial')),
    usa_vale_gas BOOLEAN NOT NULL DEFAULT FALSE,
    comentario_cancelacion VARCHAR(120),

    CONSTRAINT fk_pedido_trans
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_pedido_empleado
        FOREIGN KEY (id_empleado_entrega)
        REFERENCES cv.empleado(id_persona)
);

CREATE TABLE cv.detalle_transaccion (
    id_detalle INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transaccion INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    id_talla_stock INTEGER,
    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),

    CONSTRAINT fk_detalle_trans
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto),

    CONSTRAINT fk_detalle_talla
        FOREIGN KEY (id_talla_stock)
        REFERENCES cv.talla_stock(id_talla_stock)

    CONSTRAINT uq_detalle_transaccion
        UNIQUE (id_transaccion, id_producto, id_talla_stock)
);

CREATE TABLE cv.pago_transaccion (
    id_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transaccion INTEGER NOT NULL,
    id_metodo_pago INTEGER NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),

    CONSTRAINT fk_pago_trans
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_pago_metodo
        FOREIGN KEY (id_metodo_pago)
        REFERENCES cv.metodo_pago(id_metodo_pago),

    CONSTRAINT uq_pago_metodo
        UNIQUE (id_transaccion, id_metodo_pago)
);

CREATE TABLE cv.movimiento_inventario (
    id_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    id_talla_stock INTEGER,
    id_tipo_movimiento INTEGER NOT NULL,
    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    motivo VARCHAR(80),
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_empleado INTEGER NOT NULL,

    CONSTRAINT fk_mov_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
        ON DELETE CASCADE,

    CONSTRAINT fk_mov_talla
        FOREIGN KEY (id_talla_stock)
        REFERENCES cv.talla_stock(id_talla_stock),

    CONSTRAINT fk_mov_tipo
        FOREIGN KEY (id_tipo_movimiento)
        REFERENCES cv.tipo_movimiento(id_tipo_movimiento),

    CONSTRAINT fk_mov_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona)
);

CREATE TABLE cv.alerta_stock (
    id_alerta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    stock_actual NUMERIC(12,3) NOT NULL,
    umbral NUMERIC(12,3) NOT NULL,
    fecha_alerta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    procesada BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_alerta_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
);

CREATE TABLE cv.parametro_sistema (
    clave VARCHAR(30) PRIMARY KEY,
    valor NUMERIC(10,2) NOT NULL CHECK (valor >= 0),
    descripcion VARCHAR(120),
    actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_empleado INTEGER NOT NULL,

    CONSTRAINT fk_parametro_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona)
);

CREATE TABLE cv.bitacora_login (
    id_bitacora INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empleado INTEGER NOT NULL,
    fecha_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exitoso BOOLEAN NOT NULL,

    CONSTRAINT fk_bitacora_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona)
        ON DELETE CASCADE
);