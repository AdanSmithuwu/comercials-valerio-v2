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
);

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
    id_estado INTEGER NOT NULL,

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

_______________________________________

diff --git a/db/DDL_postgresql.sql b/db/DDL_postgresql.sql
new file mode 100644
index 0000000000000000000000000000000000000000..9d9584d544ecd8de5fbe7745755f403b1d7dac86
--- /dev/null
+++ b/db/DDL_postgresql.sql
@@ -0,0 +1,415 @@
+-- Script DDL para PostgreSQL de la base de datos cv_ventas_distribucion.
+-- Crea tablas, funciones e índices equivalentes al diseño en SQL Server.
+
+-- Crea la base de datos si no existe (ejecutar con un usuario con permisos).
+-- SELECT 'CREATE DATABASE cv_ventas_distribucion'
+-- WHERE NOT EXISTS (
+--     SELECT 1 FROM pg_database WHERE datname = 'cv_ventas_distribucion'
+-- )\gexec
+-- \c cv_ventas_distribucion
+
+-- 1. CATÁLOGOS
+DROP TABLE IF EXISTS Estado CASCADE;
+CREATE TABLE Estado (
    +    idEstado INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(20) NOT NULL,
    +    modulo VARCHAR(20) NOT NULL,
    +    CONSTRAINT UQ_Estado UNIQUE (nombre, modulo)
+);
+
+DROP TABLE IF EXISTS Rol CASCADE;
+CREATE TABLE Rol (
    +    idRol INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(20) NOT NULL UNIQUE,
    +    nivel SMALLINT NOT NULL UNIQUE
+);
+
+DROP TABLE IF EXISTS TipoProducto CASCADE;
+CREATE TABLE TipoProducto (
    +    idTipoProducto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(20) NOT NULL UNIQUE
    +);
+
+DROP TABLE IF EXISTS Categoria CASCADE;
+CREATE TABLE Categoria (
    +    idCategoria INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(40) NOT NULL UNIQUE,
    +    descripcion VARCHAR(120),
    +    idEstado INT NOT NULL,
    +    CONSTRAINT FK_Categoria_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado)
+);
+
+DROP TABLE IF EXISTS TipoMovimiento CASCADE;
+CREATE TABLE TipoMovimiento (
    +    idTipoMovimiento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(20) NOT NULL UNIQUE
    +);
+
+DROP TABLE IF EXISTS MetodoPago CASCADE;
+CREATE TABLE MetodoPago (
    +    idMetodoPago INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(20) NOT NULL UNIQUE
    +);
+
+-- 2. PERSONAS / CLIENTES / EMPLEADOS
+CREATE OR REPLACE FUNCTION fn_esdnivalido(dni CHAR(8))
+RETURNS BOOLEAN
+LANGUAGE SQL
+IMMUTABLE
+RETURNS NULL ON NULL INPUT
+AS $$
+    SELECT dni ~ '^[0-9]{8}$';
+$$;
+
+DROP TABLE IF EXISTS Persona CASCADE;
+CREATE TABLE Persona (
    +    idPersona INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombres VARCHAR(60) NOT NULL,
    +    apellidos VARCHAR(60) NOT NULL,
    +    dni CHAR(8) NOT NULL UNIQUE,
    +    CONSTRAINT CK_Persona_Dni CHECK (fn_esdnivalido(dni)),
    +    telefono VARCHAR(15),
    +    CONSTRAINT CK_Persona_Telefono CHECK (
+        telefono IS NULL OR (telefono ~ '^[0-9]{6,15}$')
+    ),
    +    fechaRegistro DATE NOT NULL DEFAULT CURRENT_DATE,
    +    idEstado INT NOT NULL,
    +    CONSTRAINT FK_Persona_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado)
+);
+
+DROP TABLE IF EXISTS Cliente CASCADE;
+CREATE TABLE Cliente (
    +    idPersona INT PRIMARY KEY,
    +    direccion VARCHAR(120) NOT NULL,
    +    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (idPersona)
+        REFERENCES Persona (idPersona) ON DELETE CASCADE
+);
+
+DROP TABLE IF EXISTS Empleado CASCADE;
+CREATE TABLE Empleado (
    +    idPersona INT PRIMARY KEY,
    +    usuario VARCHAR(30) NOT NULL UNIQUE,
    +    hashClave VARCHAR(120) NOT NULL,
    +    fechaCambioClave TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    idRol INT NOT NULL,
    +    ultimoAcceso TIMESTAMP,
    +    intentosFallidos INT NOT NULL DEFAULT 0 CHECK (intentosFallidos >= 0),
    +    bloqueadoHasta TIMESTAMP,
    +    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (idPersona)
+        REFERENCES Persona (idPersona) ON DELETE CASCADE,
    +    CONSTRAINT FK_Empleado_Rol FOREIGN KEY (idRol) REFERENCES Rol (idRol)
+);
+
+-- 3. PRODUCTOS, TALLAS, PRESENTACIONES
+DROP TABLE IF EXISTS Producto CASCADE;
+CREATE TABLE Producto (
    +    idProducto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    nombre VARCHAR(90) NOT NULL UNIQUE,
    +    descripcion VARCHAR(120),
    +    idCategoria INT NOT NULL,
    +    idTipoProducto INT NOT NULL,
    +    unidadMedida VARCHAR(10) NOT NULL,
    +    precioUnitario NUMERIC(10,2) CHECK (precioUnitario >= 0),
    +    mayorista BOOLEAN NOT NULL DEFAULT FALSE,
    +    minMayorista INT CHECK (minMayorista > 0),
    +    precioMayorista NUMERIC(10,2) CHECK (precioMayorista >= 0),
    +    paraPedido BOOLEAN NOT NULL DEFAULT FALSE,
    +    ignorarUmbralHastaCero BOOLEAN NOT NULL DEFAULT FALSE,
    +    tipoPedidoDefault VARCHAR(20)
+        CHECK (tipoPedidoDefault IS NULL OR tipoPedidoDefault IN ('Domicilio', 'Especial')),
    +    stockActual NUMERIC(12,3) CHECK (stockActual >= 0),
    +    umbral NUMERIC(12,3) NOT NULL DEFAULT 0 CHECK (umbral >= 0),
    +    idEstado INT NOT NULL,
    +    CONSTRAINT FK_Producto_Tipo FOREIGN KEY (idTipoProducto) REFERENCES TipoProducto (idTipoProducto),
    +    CONSTRAINT FK_Producto_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    +    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (idCategoria) REFERENCES Categoria (idCategoria),
    +    CONSTRAINT CK_Producto_MayoristaParams CHECK (
+        (mayorista AND minMayorista IS NOT NULL AND precioMayorista IS NOT NULL)
+        OR (NOT mayorista AND minMayorista IS NULL AND precioMayorista IS NULL)
+    ),
    +    CONSTRAINT CK_PrecioMayoristaMenor CHECK (
+        precioMayorista IS NULL OR precioMayorista < precioUnitario
+    )
+);
+
+CREATE OR REPLACE FUNCTION fn_estado(modulo_param VARCHAR(20), nombre_param VARCHAR(20))
+RETURNS INT
+LANGUAGE SQL
+STABLE
+RETURNS NULL ON NULL INPUT
+AS $$
+    SELECT idEstado
                        +    FROM Estado
                 +    WHERE modulo = modulo_param
                 +      AND nombre = nombre_param
                 +    LIMIT 1;
+$$;
+
+DROP TABLE IF EXISTS TallaStock CASCADE;
+CREATE TABLE TallaStock (
    +    idTallaStock INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idProducto INT NOT NULL,
    +    talla VARCHAR(6) NOT NULL,
    +    stock NUMERIC(12,3) NOT NULL CHECK (stock >= 0),
    +    idEstado INT NOT NULL DEFAULT fn_estado('Producto', 'Activo'),
    +    CONSTRAINT FK_TallaStock_Producto FOREIGN KEY (idProducto)
+        REFERENCES Producto (idProducto) ON DELETE CASCADE,
    +    CONSTRAINT FK_TallaStock_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    +    CONSTRAINT UQ_TallaStock UNIQUE (idProducto, talla)
+);
+
+DROP TABLE IF EXISTS Presentacion CASCADE;
+CREATE TABLE Presentacion (
    +    idPresentacion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idProducto INT NOT NULL,
    +    cantidad NUMERIC(8,3) NOT NULL CHECK (cantidad > 0),
    +    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    +    idEstado INT NOT NULL DEFAULT fn_estado('Producto', 'Activo'),
    +    CONSTRAINT FK_Presentacion_Producto FOREIGN KEY (idProducto)
+        REFERENCES Producto (idProducto) ON DELETE CASCADE,
    +    CONSTRAINT FK_Presentacion_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    +    CONSTRAINT UQ_Presentacion UNIQUE (idProducto, cantidad)
+);
+
+-- 4. TRANSACCIÓN – VENTA / PEDIDO
+DROP TABLE IF EXISTS Transaccion CASCADE;
+CREATE TABLE Transaccion (
    +    idTransaccion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    fechaDia DATE GENERATED ALWAYS AS (fecha::DATE) STORED,
    +    idEstado INT NOT NULL DEFAULT fn_estado('Transaccion', 'En Proceso'),
    +    totalBruto NUMERIC(10,2) NOT NULL CHECK (totalBruto >= 0),
    +    descuento NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    +    CONSTRAINT CK_Transaccion_DescuentoMenor CHECK (descuento <= totalBruto),
    +    cargo NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (cargo >= 0),
    +    totalNeto NUMERIC(10,2) GENERATED ALWAYS AS (totalBruto - descuento + cargo) STORED,
    +    observacion VARCHAR(120),
    +    motivoCancelacion VARCHAR(120),
    +    idEmpleado INT NOT NULL,
    +    idCliente INT NOT NULL,
    +    CONSTRAINT FK_Trans_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    +    CONSTRAINT FK_Trans_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona),
    +    CONSTRAINT FK_Trans_Cliente FOREIGN KEY (idCliente) REFERENCES Cliente (idPersona)
+);
+
+DROP TABLE IF EXISTS Venta CASCADE;
+CREATE TABLE Venta (
    +    idTransaccion INT PRIMARY KEY,
    +    CONSTRAINT FK_Venta_Trans FOREIGN KEY (idTransaccion)
    +        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE
    +);
+
+DROP TABLE IF EXISTS Pedido CASCADE;
+CREATE TABLE Pedido (
    +    idTransaccion INT PRIMARY KEY,
    +    direccionEntrega VARCHAR(120) NOT NULL,
    +    fechaHoraEntrega TIMESTAMP,
    +    idEmpleadoEntrega INT,
    +    tipoPedido VARCHAR(20) NOT NULL CHECK (tipoPedido IN ('Domicilio', 'Especial')),
    +    usaValeGas BOOLEAN NOT NULL DEFAULT FALSE,
    +    comentarioCancelacion VARCHAR(120),
    +    CONSTRAINT FK_Pedido_Trans FOREIGN KEY (idTransaccion)
+        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    +    CONSTRAINT FK_Pedido_EmpleadoEntrega FOREIGN KEY (idEmpleadoEntrega)
+        REFERENCES Empleado (idPersona)
+);
+
+DROP TABLE IF EXISTS OrdenCompra CASCADE;
+CREATE TABLE OrdenCompra (
    +    idOrdenCompra INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idPedido INT NOT NULL,
    +    idCliente INT NOT NULL,
    +    idProducto INT NOT NULL,
    +    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    +    fechaCumplida TIMESTAMP,
    +    CONSTRAINT FK_Orden_Pedido FOREIGN KEY (idPedido)
+        REFERENCES Pedido (idTransaccion) ON DELETE CASCADE,
    +    CONSTRAINT FK_Orden_Cliente FOREIGN KEY (idCliente)
+        REFERENCES Cliente (idPersona) ON DELETE CASCADE,
    +    CONSTRAINT FK_Orden_Producto FOREIGN KEY (idProducto) REFERENCES Producto (idProducto)
+);
+
+-- 5. DETALLE, PAGOS
+DROP TABLE IF EXISTS DetalleTransaccion CASCADE;
+CREATE TABLE DetalleTransaccion (
    +    idDetalle INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idTransaccion INT NOT NULL,
    +    idProducto INT NOT NULL,
    +    idTallaStock INT,
    +    idTallaStockKey INT GENERATED ALWAYS AS (COALESCE(idTallaStock, -1)) STORED,
    +    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    +    precioUnitario NUMERIC(10,2) NOT NULL CHECK (precioUnitario >= 0),
    +    subtotal NUMERIC(22,5) GENERATED ALWAYS AS (cantidad * precioUnitario) STORED,
    +    CONSTRAINT FK_DetTrans_Trans FOREIGN KEY (idTransaccion)
+        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    +    CONSTRAINT FK_DetTrans_Prod FOREIGN KEY (idProducto) REFERENCES Producto (idProducto),
    +    CONSTRAINT FK_DetTrans_Talla FOREIGN KEY (idTallaStock) REFERENCES TallaStock (idTallaStock)
+);
+
+DROP TABLE IF EXISTS PagoTransaccion CASCADE;
+CREATE TABLE PagoTransaccion (
    +    idPago INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idTransaccion INT NOT NULL,
    +    idMetodoPago INT NOT NULL,
    +    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    +    CONSTRAINT FK_PagoTrans_Trans FOREIGN KEY (idTransaccion)
+        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    +    CONSTRAINT FK_PagoTrans_Metodo FOREIGN KEY (idMetodoPago) REFERENCES MetodoPago (idMetodoPago),
    +    CONSTRAINT UQ_PagoTrans UNIQUE (idTransaccion, idMetodoPago)
+);
+
+-- 6. MOVIMIENTOS / PARÁMETROS / EVIDENCIA
+DROP TABLE IF EXISTS MovimientoInventario CASCADE;
+CREATE TABLE MovimientoInventario (
    +    idMovimiento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idProducto INT NOT NULL,
    +    idTallaStock INT,
    +    idTipoMovimiento INT NOT NULL,
    +    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    +    motivo VARCHAR(80),
    +    fechaHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    idEmpleado INT NOT NULL,
    +    CONSTRAINT FK_MovInv_Producto FOREIGN KEY (idProducto)
+        REFERENCES Producto (idProducto) ON DELETE CASCADE,
    +    CONSTRAINT FK_MovInv_Talla FOREIGN KEY (idTallaStock) REFERENCES TallaStock (idTallaStock),
    +    CONSTRAINT FK_MovInv_Tipo FOREIGN KEY (idTipoMovimiento) REFERENCES TipoMovimiento (idTipoMovimiento),
    +    CONSTRAINT FK_MovInv_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona)
+);
+
+DROP TABLE IF EXISTS Comprobante CASCADE;
+CREATE TABLE Comprobante (
    +    idComprobante INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idTransaccion INT NOT NULL,
    +    fechaEmision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    bytesPdf BYTEA NOT NULL,
    +    CONSTRAINT FK_Comprobante_Trans FOREIGN KEY (idTransaccion)
    +        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    +    CONSTRAINT UQ_Comprobante_Trans UNIQUE (idTransaccion)
+);
+
+DROP TABLE IF EXISTS Reporte CASCADE;
+CREATE TABLE Reporte (
    +    idReporte INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    tipoReporte VARCHAR(20) NOT NULL CHECK (tipoReporte IN ('Diario', 'Mensual', 'Rotacion')),
    +    idEmpleado INT NOT NULL,
    +    desde DATE NOT NULL,
    +    hasta DATE NOT NULL,
    +    filtros VARCHAR(200),
    +    bytesPdf BYTEA NOT NULL,
    +    fechaGeneracion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    CONSTRAINT CHK_HastaMayorIgualDesde CHECK (hasta >= desde),
    +    CONSTRAINT FK_Reporte_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona)
+);
+
+DROP TABLE IF EXISTS OrdenCompraPdf CASCADE;
+CREATE TABLE OrdenCompraPdf (
    +    idOrdenCompra INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idPedido INT NOT NULL,
    +    bytesPdf BYTEA NOT NULL,
    +    fechaGeneracion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    CONSTRAINT FK_OrdenPdf_Pedido FOREIGN KEY (idPedido)
    +        REFERENCES Pedido (idTransaccion) ON DELETE CASCADE,
    +    CONSTRAINT UQ_OrdenPdf_Pedido UNIQUE (idPedido)
+);
+
+DROP TABLE IF EXISTS ParametroSistema CASCADE;
+CREATE TABLE ParametroSistema (
    +    clave VARCHAR(30) PRIMARY KEY,
    +    valor NUMERIC(10,2) NOT NULL CHECK (valor >= 0),
    +    descripcion VARCHAR(120),
    +    actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    idEmpleado INT NOT NULL,
    +    CONSTRAINT FK_Parametro_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona)
+);
+
+DROP TABLE IF EXISTS BitacoraLogin CASCADE;
+CREATE TABLE BitacoraLogin (
    +    idBitacora INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idEmpleado INT NOT NULL,
    +    fechaEvento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    exitoso BOOLEAN NOT NULL,
    +    CONSTRAINT FK_Bitacora_Emp FOREIGN KEY (idEmpleado)
    +        REFERENCES Empleado (idPersona) ON DELETE CASCADE
    +);
+
+DROP TABLE IF EXISTS AlertaStock CASCADE;
+CREATE TABLE AlertaStock (
    +    idAlerta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    +    idProducto INT NOT NULL,
    +    stockActual NUMERIC(12,3) NOT NULL,
    +    umbral NUMERIC(12,3) NOT NULL,
    +    fechaAlerta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    +    procesada BOOLEAN NOT NULL DEFAULT FALSE,
    +    CONSTRAINT FK_AlertaStock_Producto FOREIGN KEY (idProducto) REFERENCES Producto (idProducto)
+);
+
+-- 7. ÍNDICES
+DROP INDEX IF EXISTS IX_AlertaStock_Pendiente;
+CREATE UNIQUE INDEX IX_AlertaStock_Pendiente ON AlertaStock (idProducto) WHERE procesada = FALSE;
+DROP INDEX IF EXISTS IX_AlertaStock_Procesada;
+CREATE INDEX IX_AlertaStock_Procesada ON AlertaStock (procesada, fechaAlerta);
+DROP INDEX IF EXISTS IX_Bitacora_Empleado;
+CREATE INDEX IX_Bitacora_Empleado ON BitacoraLogin (idEmpleado);
+DROP INDEX IF EXISTS IX_Bitacora_ExitosoFecha;
+CREATE INDEX IX_Bitacora_ExitosoFecha ON BitacoraLogin (exitoso, fechaEvento);
+DROP INDEX IF EXISTS IX_Bitacora_Fecha;
+CREATE INDEX IX_Bitacora_Fecha ON BitacoraLogin (fechaEvento);
+DROP INDEX IF EXISTS IX_DetTrans_Producto;
+CREATE INDEX IX_DetTrans_Producto ON DetalleTransaccion (idProducto);
+DROP INDEX IF EXISTS IX_DetTrans_Talla;
+CREATE INDEX IX_DetTrans_Talla ON DetalleTransaccion (idTallaStock);
+DROP INDEX IF EXISTS IX_DetTrans_TransProdTalla;
+CREATE UNIQUE INDEX IX_DetTrans_TransProdTalla
    +    ON DetalleTransaccion (idTransaccion, idProducto, idTallaStockKey);
+DROP INDEX IF EXISTS IX_Empleado_Rol;
+CREATE INDEX IX_Empleado_Rol ON Empleado (idRol);
+DROP INDEX IF EXISTS IX_Estado_ModuloNombre;
+CREATE INDEX IX_Estado_ModuloNombre ON Estado (modulo, nombre);
+DROP INDEX IF EXISTS IX_MovInv_Empleado;
+CREATE INDEX IX_MovInv_Empleado ON MovimientoInventario (idEmpleado);
+DROP INDEX IF EXISTS IX_MovInv_Fecha;
+CREATE INDEX IX_MovInv_Fecha ON MovimientoInventario (fechaHora);
+DROP INDEX IF EXISTS IX_MovInv_Prod;
+CREATE INDEX IX_MovInv_Prod ON MovimientoInventario (idProducto);
+DROP INDEX IF EXISTS IX_MovInv_Prod_Fecha;
+CREATE INDEX IX_MovInv_Prod_Fecha ON MovimientoInventario (idProducto, fechaHora);
+DROP INDEX IF EXISTS IX_MovInv_Tipo;
+CREATE INDEX IX_MovInv_Tipo ON MovimientoInventario (idTipoMovimiento);
+DROP INDEX IF EXISTS IX_OrdenCompra_Cliente;
+CREATE INDEX IX_OrdenCompra_Cliente ON OrdenCompra (idCliente);
+DROP INDEX IF EXISTS IX_OrdenCompra_FechaCumplida;
+CREATE INDEX IX_OrdenCompra_FechaCumplida ON OrdenCompra (fechaCumplida);
+DROP INDEX IF EXISTS IX_OrdenCompra_Pedido;
+CREATE INDEX IX_OrdenCompra_Pedido ON OrdenCompra (idPedido);
+DROP INDEX IF EXISTS IX_OrdenCompra_Producto;
+CREATE INDEX IX_OrdenCompra_Producto ON OrdenCompra (idProducto);
+DROP INDEX IF EXISTS IX_OrdenCompraPdf_Fecha;
+CREATE INDEX IX_OrdenCompraPdf_Fecha ON OrdenCompraPdf (fechaGeneracion);
+DROP INDEX IF EXISTS IX_PagoTransaccion_Metodo;
+CREATE INDEX IX_PagoTransaccion_Metodo ON PagoTransaccion (idMetodoPago);
+DROP INDEX IF EXISTS IX_Pedido_EmpleadoEntrega;
+CREATE INDEX IX_Pedido_EmpleadoEntrega ON Pedido (idEmpleadoEntrega);
+DROP INDEX IF EXISTS IX_Pedido_Tipo;
+CREATE INDEX IX_Pedido_Tipo ON Pedido (tipoPedido);
+DROP INDEX IF EXISTS IX_Persona_Estado;
+CREATE INDEX IX_Persona_Estado ON Persona (idEstado);
+DROP INDEX IF EXISTS IX_Presentacion_Producto;
+CREATE INDEX IX_Presentacion_Producto ON Presentacion (idProducto);
+DROP INDEX IF EXISTS IX_Producto_Categoria;
+CREATE INDEX IX_Producto_Categoria ON Producto (idCategoria);
+DROP INDEX IF EXISTS IX_Producto_Estado;
+CREATE INDEX IX_Producto_Estado ON Producto (idEstado);
+DROP INDEX IF EXISTS IX_Producto_Mayorista;
+CREATE INDEX IX_Producto_Mayorista ON Producto (mayorista) INCLUDE (minMayorista, precioMayorista);
+DROP INDEX IF EXISTS IX_Producto_StockUmbral;
+CREATE INDEX IX_Producto_StockUmbral ON Producto (stockActual) INCLUDE (umbral);
+DROP INDEX IF EXISTS IX_Reporte_Empleado;
+CREATE INDEX IX_Reporte_Empleado ON Reporte (idEmpleado);
+DROP INDEX IF EXISTS IX_Reporte_FechaGen;
+CREATE INDEX IX_Reporte_FechaGen ON Reporte (fechaGeneracion);
+DROP INDEX IF EXISTS IX_TallaStock_Producto;
+CREATE INDEX IX_TallaStock_Producto ON TallaStock (idProducto);
+DROP INDEX IF EXISTS IX_Trans_ClienteFecha;
+CREATE INDEX IX_Trans_ClienteFecha ON Transaccion (idCliente, fecha) INCLUDE (totalNeto, idEstado);
+DROP INDEX IF EXISTS IX_Trans_Fecha;
+CREATE INDEX IX_Trans_Fecha ON Transaccion (fecha) INCLUDE (idCliente, totalNeto, idEstado);
