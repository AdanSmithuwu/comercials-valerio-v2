CREATE TABLE cv.estado (
    id_estado INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    modulo VARCHAR(20) NOT NULL,
    CONSTRAINT uq_estado UNIQUE (nombre, modulo)
);

CREATE TABLE cv.rol (
    id_rol INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE,
    nivel SMALLINT NOT NULL UNIQUE
)

CREATE TABLE cv.tipo_producto (
    id_tipo_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cv.categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(120),
    id_estado INTEGER NOT NULL,
    CONSTRAINT fk_categoria_estado
        FOREIGN KEY (id_estado)
        REFERENCES cv.estado(id_estado)
);

CREATE TABLE cv.tipo_movimiento (
    id_tipo_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cv.metodo_pago (
    id_metodo_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE cv.persona (
    id_persona INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(60) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    dni CHAR(8) NOT NULL UNIQUE,

    CONSTRAINT ck_persona_dni
        CHECK (dni ~ '^[0-9]{8}$'),
        telefono VARCHAR(15),

    CONSTRAINT ck_persona_telefono
        CHECK (
            telefono IS NULL OR
            telefono ~ '^[0-9]{6,15}$'
        ),
        fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
        id_estado INTEGER NOT NULL,

    CONSTRAINT fk_persona_estado
        FOREIGN KEY (id_estado)
        REFERENCES cv.estado(id_estado)
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
    usuario VARCHAR(30) NOT NULL UNIQUE,
    hash_clave VARCHAR(120) NOT NULL,
    fecha_cambio_clave TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL,
    intentos_fallidos INTEGER NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMP NULL,
    id_rol INTEGER NOT NULL,

    CONSTRAINT ck_empleado_intentos
        CHECK (intentos_fallidos >= 0),

    CONSTRAINT fk_empleado_persona
        FOREIGN KEY (id_persona)
        REFERENCES cv.persona(id_persona)
        ON DELETE CASCADE,

    CONSTRAINT fk_empleado_rol
        FOREIGN KEY (id_rol)
        REFERENCES cv.rol(id_rol)
);

CREATE TABLE cv.producto (
    id_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(90) NOT NULL UNIQUE,
    descripcion VARCHAR(120),
    id_categoria INTEGER NOT NULL,
    id_tipo_producto INTEGER NOT NULL,
    unidad_medida VARCHAR(10) NOT NULL,
    precio_unitario NUMERIC(10,2),
    mayorista BOOLEAN NOT NULL DEFAULT FALSE,
    min_mayorista INTEGER,
    precio_mayorista NUMERIC(10,2),
    para_pedido BOOLEAN NOT NULL DEFAULT FALSE,
    ignorar_umbral_hasta_cero BOOLEAN NOT NULL DEFAULT FALSE,
    tipo_pedido_default VARCHAR(20),
    stock_actual NUMERIC(12,3),
    umbral NUMERIC(12,3) NOT NULL DEFAULT 0,
    id_estado INTEGER NOT NULL

    CONSTRAINT ck_producto_precio_unitario
        CHECK (precio_unitario IS NULL OR precio_unitario >= 0),

    CONSTRAINT ck_producto_tipo_pedido
        CHECK (
            tipo_pedido_default IS NULL
            OR tipo_pedido_default IN ('Domicilio','Especial')
            ),

    CONSTRAINT ck_producto_stock
        CHECK (stock_actual IS NULL OR stock_actual >= 0),

    CONSTRAINT ck_producto_umbral
        CHECK (umbral >= 0),

    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES cv.categoria(id_categoria),

    CONSTRAINT fk_producto_tipo
        FOREIGN KEY (id_tipo_producto)
        REFERENCES cv.tipo_producto(id_tipo_producto),

    CONSTRAINT fk_producto_estado
        FOREIGN KEY (id_estado)
        REFERENCES cv.estado(id_estado),

    CONSTRAINT ck_producto_mayorista_params CHECK (
        (mayorista = TRUE AND min_mayorista IS NOT NULL AND precio_mayorista IS NOT NULL)
        OR
        (mayorista = FALSE AND min_mayorista IS NULL AND precio_mayorista IS NULL)
        ),

    CONSTRAINT ck_precio_mayorista_menor CHECK (
        precio_mayorista IS NULL
        OR precio_unitario IS NULL
        OR precio_mayorista < precio_unitario
        )
);

CREATE TABLE cv.talla_stock (
    id_talla_stock INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    talla VARCHAR(6) NOT NULL,
    stock NUMERIC(12,3) NOT NULL,
    id_estado INTEGER NOT NULL,

    CONSTRAINT ck_talla_stock_stock
        CHECK (stock >= 0),

    CONSTRAINT fk_talla_stock_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
        ON DELETE CASCADE,

    CONSTRAINT fk_talla_stock_estado
        FOREIGN KEY (id_estado)
        REFERENCES cv.estado(id_estado),

    CONSTRAINT uq_talla_stock UNIQUE (id_producto, talla)
);

CREATE TABLE cv.presentacion (
    id_presentacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    cantidad NUMERIC(8,3) NOT NULL,
    id_estado INTEGER NOT NULL,
    precio NUMERIC(10,2) NOT NULL,

    CONSTRAINT ck_presentacion_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT ck_presentacion_precio
        CHECK (precio >= 0),

    CONSTRAINT fk_presentacion_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
        ON DELETE CASCADE,

    CONSTRAINT fk_presentacion_estado
        FOREIGN KEY (id_estado)
        REFERENCES cv.estado(id_estado),

    CONSTRAINT uq_presentacion UNIQUE (id_producto, cantidad)
);

CREATE TABLE cv.transaccion (
    id_transaccion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_estado INTEGER NOT NULL,
    total_bruto NUMERIC(10,2) NOT NULL,
    descuento NUMERIC(10,2) NOT NULL DEFAULT 0,
    cargo NUMERIC(10,2) NOT NULL DEFAULT 0,
    observacion VARCHAR(120),
    motivo_cancelacion VARCHAR(120),
    id_empleado INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,

    CONSTRAINT ck_transaccion_total_bruto
        CHECK (total_bruto >= 0),

    CONSTRAINT ck_transaccion_descuento
        CHECK (descuento >= 0 AND descuento <= total_bruto),

    CONSTRAINT ck_transaccion_cargo
        CHECK (cargo >= 0),

    CONSTRAINT fk_trans_estado
        FOREIGN KEY (id_estado)
        REFERENCES cv.estado(id_estado),

    CONSTRAINT fk_trans_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona),

    CONSTRAINT fk_trans_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cv.cliente(id_persona)
);

CREATE TABLE cv.venta (
    id_transaccion INTEGER PRIMARY KEY,

    CONSTRAINT fk_venta_transaccion
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE
);

CREATE TABLE cv.pedido(
    id_transaccion INTEGER PRIMARY KEY,
    direccion_entrega VARCHAR(120) NOT NULL,
    fecha_hora_entrega TIMESTAMP NULL,
    id_empleado_entrega INTEGER NULL,
    tipo_pedido VARCHAR(20)  NOT NULL,
    usa_vale_gas BOOLEAN NOT NULL DEFAULT FALSE,
    comentario_cancelacion VARCHAR(120),

    CONSTRAINT ck_pedido_tipo
        CHECK (tipo_pedido IN ('Domicilio', 'Especial')),

    CONSTRAINT fk_pedido_transaccion
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion (id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_pedido_empleado_entrega
        FOREIGN KEY (id_empleado_entrega)
        REFERENCES cv.empleado (id_persona)
);

CREATE TABLE cv.orden_compra (
    id_orden_compra INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad NUMERIC(12,3) NOT NULL,
    fecha_cumplida TIMESTAMP NULL,

    CONSTRAINT ck_orden_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT fk_orden_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES cv.pedido(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_orden_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cv.cliente(id_persona)
        ON DELETE CASCADE,

    CONSTRAINT fk_orden_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
);

CREATE TABLE cv.detalle_transaccion (
    id_detalle INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transaccion INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    id_talla_stock INTEGER NULL,
    cantidad NUMERIC(12,3) NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT ck_detalle_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT ck_detalle_precio
        CHECK (precio_unitario >= 0),

    CONSTRAINT fk_detalle_transaccion
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto),

    CONSTRAINT fk_detalle_talla
        FOREIGN KEY (id_talla_stock)
        REFERENCES cv.talla_stock(id_talla_stock)
);

CREATE TABLE cv.pago_transaccion (
    id_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transaccion INTEGER NOT NULL,
    id_metodo_pago INTEGER NOT NULL,
    monto NUMERIC(10,2) NOT NULL,

    CONSTRAINT ck_pago_monto
        CHECK (monto > 0),

    CONSTRAINT fk_pago_transaccion
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT fk_pago_metodo
        FOREIGN KEY (id_metodo_pago)
        REFERENCES cv.metodo_pago(id_metodo_pago),

    CONSTRAINT uq_pago_trans UNIQUE (id_transaccion, id_metodo_pago)
);

CREATE TABLE cv.movimiento_inventario (
    id_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    id_talla_stock INTEGER NULL,
    id_tipo_movimiento INTEGER NOT NULL,
    cantidad NUMERIC(12,3) NOT NULL,
    motivo VARCHAR(80),
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_empleado INTEGER NOT NULL,

    CONSTRAINT ck_movimiento_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT fk_movinv_producto
        FOREIGN KEY (id_producto)
        REFERENCES cv.producto(id_producto)
        ON DELETE CASCADE,

    CONSTRAINT fk_movinv_talla
        FOREIGN KEY (id_talla_stock)
        REFERENCES cv.talla_stock(id_talla_stock),

    CONSTRAINT fk_movinv_tipo
        FOREIGN KEY (id_tipo_movimiento)
        REFERENCES cv.tipo_movimiento(id_tipo_movimiento),

    CONSTRAINT fk_movinv_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona)
);

CREATE TABLE cv.comprobante (
    id_comprobante INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transaccion INTEGER NOT NULL,
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bytes_pdf BYTEA NOT NULL,

    CONSTRAINT fk_comprobante_transaccion
        FOREIGN KEY (id_transaccion)
        REFERENCES cv.transaccion(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT uq_comprobante_trans UNIQUE (id_transaccion)
);

CREATE TABLE cv.reporte (
    id_reporte INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_reporte VARCHAR(20) NOT NULL,
    id_empleado INTEGER NOT NULL,
    fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_reporte_tipo
        CHECK (tipo_reporte IN ('Diario','Mensual','Rotacion')),

    desde DATE NOT NULL,
    hasta DATE NOT NULL,
    CONSTRAINT ck_reporte_fechas
        CHECK (hasta >= desde),

    filtros VARCHAR(200),
    bytes_pdf BYTEA NOT NULL,

    CONSTRAINT fk_reporte_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES cv.empleado(id_persona)
);

CREATE TABLE cv.orden_compra_pdf (
    id_orden_compra_pdf INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    bytes_pdf BYTEA NOT NULL,
    fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orden_pdf_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES cv.pedido(id_transaccion)
        ON DELETE CASCADE,

    CONSTRAINT uq_orden_pdf_pedido UNIQUE (id_pedido)
);

CREATE TABLE cv.parametro_sistema (
    clave VARCHAR(30) PRIMARY KEY,
    valor NUMERIC(10,2) NOT NULL,
    descripcion VARCHAR(120),
    actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_empleado INTEGER NOT NULL,

    CONSTRAINT ck_parametro_valor
        CHECK (valor >= 0),

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