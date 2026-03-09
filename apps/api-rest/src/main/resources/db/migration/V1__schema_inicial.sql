-- 1. CATÁLOGOS
DROP TABLE IF EXISTS Estado CASCADE;
CREATE TABLE Estado (
    idEstado INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    modulo VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Estado UNIQUE (nombre, modulo)
);

DROP TABLE IF EXISTS Rol CASCADE;
CREATE TABLE Rol (
    idRol INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE,
    nivel SMALLINT NOT NULL UNIQUE
);

DROP TABLE IF EXISTS TipoProducto CASCADE;
CREATE TABLE TipoProducto (
    idTipoProducto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS Categoria CASCADE;
CREATE TABLE Categoria (
    idCategoria INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(120),
    idEstado INT NOT NULL,
    CONSTRAINT FK_Categoria_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado)
);

DROP TABLE IF EXISTS TipoMovimiento CASCADE;
CREATE TABLE TipoMovimiento (
    idTipoMovimiento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS MetodoPago CASCADE;
CREATE TABLE MetodoPago (
    idMetodoPago INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

-- 2. PERSONAS / CLIENTES / EMPLEADOS
CREATE OR REPLACE FUNCTION fn_esdnivalido(dni CHAR(8))
RETURNS BOOLEAN
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT
AS $$
SELECT dni ~ '^[0-9]{8}$';
$$;

DROP TABLE IF EXISTS Persona CASCADE;
CREATE TABLE Persona (
    idPersona INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(60) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    dni CHAR(8) NOT NULL UNIQUE,
    CONSTRAINT CK_Persona_Dni CHECK (fn_esdnivalido(dni)),
    telefono VARCHAR(15),
    CONSTRAINT CK_Persona_Telefono CHECK (
        telefono IS NULL OR (telefono ~ '^[0-9]{6,15}$')
        ),
    fechaRegistro DATE NOT NULL DEFAULT CURRENT_DATE,
    idEstado INT NOT NULL,
    CONSTRAINT FK_Persona_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado)
);

DROP TABLE IF EXISTS Cliente CASCADE;
CREATE TABLE Cliente (
    idPersona INT PRIMARY KEY,
    direccion VARCHAR(120) NOT NULL,
    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (idPersona)
        REFERENCES Persona (idPersona) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Empleado CASCADE;
CREATE TABLE Empleado (
    idPersona INT PRIMARY KEY,
    usuario VARCHAR(30) NOT NULL UNIQUE,
    hashClave VARCHAR(120) NOT NULL,
    fechaCambioClave TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idRol INT NOT NULL,
    ultimoAcceso TIMESTAMP,
    intentosFallidos INT NOT NULL DEFAULT 0 CHECK (intentosFallidos >= 0),
    bloqueadoHasta TIMESTAMP,
    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (idPersona)
        REFERENCES Persona (idPersona) ON DELETE CASCADE,
    CONSTRAINT FK_Empleado_Rol FOREIGN KEY (idRol) REFERENCES Rol (idRol)
);

-- 3. PRODUCTOS, TALLAS, PRESENTACIONES
DROP TABLE IF EXISTS Producto CASCADE;
CREATE TABLE Producto (
    idProducto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(90) NOT NULL UNIQUE,
    descripcion VARCHAR(120),
    idCategoria INT NOT NULL,
    idTipoProducto INT NOT NULL,
    unidadMedida VARCHAR(10) NOT NULL,
    precioUnitario NUMERIC(10,2) CHECK (precioUnitario >= 0),
    mayorista BOOLEAN NOT NULL DEFAULT FALSE,
    minMayorista INT CHECK (minMayorista > 0),
    precioMayorista NUMERIC(10,2) CHECK (precioMayorista >= 0),
    paraPedido BOOLEAN NOT NULL DEFAULT FALSE,
    ignorarUmbralHastaCero BOOLEAN NOT NULL DEFAULT FALSE,
    tipoPedidoDefault VARCHAR(20)
        CHECK (tipoPedidoDefault IS NULL OR tipoPedidoDefault IN ('Domicilio', 'Especial')),
    stockActual NUMERIC(12,3) CHECK (stockActual >= 0),
    umbral NUMERIC(12,3) NOT NULL DEFAULT 0 CHECK (umbral >= 0),
    idEstado INT NOT NULL,
    CONSTRAINT FK_Producto_Tipo FOREIGN KEY (idTipoProducto) REFERENCES TipoProducto (idTipoProducto),
    CONSTRAINT FK_Producto_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (idCategoria) REFERENCES Categoria (idCategoria),
    CONSTRAINT CK_Producto_MayoristaParams CHECK (
        (mayorista AND minMayorista IS NOT NULL AND precioMayorista IS NOT NULL)
            OR (NOT mayorista AND minMayorista IS NULL AND precioMayorista IS NULL)
        ),
    CONSTRAINT CK_PrecioMayoristaMenor CHECK (
        precioMayorista IS NULL OR precioMayorista < precioUnitario
        )
);

CREATE OR REPLACE FUNCTION fn_estado(modulo_param VARCHAR(20), nombre_param VARCHAR(20))
RETURNS INT
LANGUAGE SQL
STABLE
RETURNS NULL ON NULL INPUT
AS $$
SELECT idEstado
FROM Estado
WHERE modulo = modulo_param
  AND nombre = nombre_param
    LIMIT 1;
$$;

DROP TABLE IF EXISTS TallaStock CASCADE;
CREATE TABLE TallaStock (
    idTallaStock INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idProducto INT NOT NULL,
    talla VARCHAR(6) NOT NULL,
    stock NUMERIC(12,3) NOT NULL CHECK (stock >= 0),
    idEstado INT NOT NULL DEFAULT fn_estado('Producto', 'Activo'),
    CONSTRAINT FK_TallaStock_Producto FOREIGN KEY (idProducto)
        REFERENCES Producto (idProducto) ON DELETE CASCADE,
    CONSTRAINT FK_TallaStock_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    CONSTRAINT UQ_TallaStock UNIQUE (idProducto, talla)
);

DROP TABLE IF EXISTS Presentacion CASCADE;
CREATE TABLE Presentacion (
    idPresentacion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idProducto INT NOT NULL,
    cantidad NUMERIC(8,3) NOT NULL CHECK (cantidad > 0),
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    idEstado INT NOT NULL DEFAULT fn_estado('Producto', 'Activo'),
    CONSTRAINT FK_Presentacion_Producto FOREIGN KEY (idProducto)
        REFERENCES Producto (idProducto) ON DELETE CASCADE,
    CONSTRAINT FK_Presentacion_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    CONSTRAINT UQ_Presentacion UNIQUE (idProducto, cantidad)
);

-- 4. TRANSACCIÓN – VENTA / PEDIDO
DROP TABLE IF EXISTS Transaccion CASCADE;
CREATE TABLE Transaccion (
    idTransaccion INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaDia DATE GENERATED ALWAYS AS (fecha::DATE) STORED,
    idEstado INT NOT NULL DEFAULT fn_estado('Transaccion', 'En Proceso'),
    totalBruto NUMERIC(10,2) NOT NULL CHECK (totalBruto >= 0),
    descuento NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    CONSTRAINT CK_Transaccion_DescuentoMenor CHECK (descuento <= totalBruto),
    cargo NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (cargo >= 0),
    totalNeto NUMERIC(10,2) GENERATED ALWAYS AS (totalBruto - descuento + cargo) STORED,
    observacion VARCHAR(120),
    motivoCancelacion VARCHAR(120),
    idEmpleado INT NOT NULL,
    idCliente INT NOT NULL,
    CONSTRAINT FK_Trans_Estado FOREIGN KEY (idEstado) REFERENCES Estado (idEstado),
    CONSTRAINT FK_Trans_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona),
    CONSTRAINT FK_Trans_Cliente FOREIGN KEY (idCliente) REFERENCES Cliente (idPersona)
);

DROP TABLE IF EXISTS Venta CASCADE;
CREATE TABLE Venta (
    idTransaccion INT PRIMARY KEY,
    CONSTRAINT FK_Venta_Trans FOREIGN KEY (idTransaccion)
        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Pedido CASCADE;
CREATE TABLE Pedido (
    idTransaccion INT PRIMARY KEY,
    direccionEntrega VARCHAR(120) NOT NULL,
    fechaHoraEntrega TIMESTAMP,
    idEmpleadoEntrega INT,
    tipoPedido VARCHAR(20) NOT NULL CHECK (tipoPedido IN ('Domicilio', 'Especial')),
    usaValeGas BOOLEAN NOT NULL DEFAULT FALSE,
    comentarioCancelacion VARCHAR(120),
    CONSTRAINT FK_Pedido_Trans FOREIGN KEY (idTransaccion)
        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    CONSTRAINT FK_Pedido_EmpleadoEntrega FOREIGN KEY (idEmpleadoEntrega)
        REFERENCES Empleado (idPersona)
);

DROP TABLE IF EXISTS OrdenCompra CASCADE;
CREATE TABLE OrdenCompra (
    idOrdenCompra INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idPedido INT NOT NULL,
    idCliente INT NOT NULL,
    idProducto INT NOT NULL,
    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    fechaCumplida TIMESTAMP,
    CONSTRAINT FK_Orden_Pedido FOREIGN KEY (idPedido)
        REFERENCES Pedido (idTransaccion) ON DELETE CASCADE,
    CONSTRAINT FK_Orden_Cliente FOREIGN KEY (idCliente)
        REFERENCES Cliente (idPersona) ON DELETE CASCADE,
    CONSTRAINT FK_Orden_Producto FOREIGN KEY (idProducto) REFERENCES Producto (idProducto)
);

-- 5. DETALLE, PAGOS
DROP TABLE IF EXISTS DetalleTransaccion CASCADE;
CREATE TABLE DetalleTransaccion (
    idDetalle INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idTransaccion INT NOT NULL,
    idProducto INT NOT NULL,
    idTallaStock INT,
    idTallaStockKey INT GENERATED ALWAYS AS (COALESCE(idTallaStock, -1)) STORED,
    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    precioUnitario NUMERIC(10,2) NOT NULL CHECK (precioUnitario >= 0),
    subtotal NUMERIC(22,5) GENERATED ALWAYS AS (cantidad * precioUnitario) STORED,
    CONSTRAINT FK_DetTrans_Trans FOREIGN KEY (idTransaccion)
        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    CONSTRAINT FK_DetTrans_Prod FOREIGN KEY (idProducto) REFERENCES Producto (idProducto),
    CONSTRAINT FK_DetTrans_Talla FOREIGN KEY (idTallaStock) REFERENCES TallaStock (idTallaStock)
);

DROP TABLE IF EXISTS PagoTransaccion CASCADE;
CREATE TABLE PagoTransaccion (
    idPago INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idTransaccion INT NOT NULL,
    idMetodoPago INT NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    CONSTRAINT FK_PagoTrans_Trans FOREIGN KEY (idTransaccion)
        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    CONSTRAINT FK_PagoTrans_Metodo FOREIGN KEY (idMetodoPago) REFERENCES MetodoPago (idMetodoPago),
    CONSTRAINT UQ_PagoTrans UNIQUE (idTransaccion, idMetodoPago)
);

-- 6. MOVIMIENTOS / PARÁMETROS / EVIDENCIA
DROP TABLE IF EXISTS MovimientoInventario CASCADE;
CREATE TABLE MovimientoInventario (
    idMovimiento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idProducto INT NOT NULL,
    idTallaStock INT,
    idTipoMovimiento INT NOT NULL,
    cantidad NUMERIC(12,3) NOT NULL CHECK (cantidad > 0),
    motivo VARCHAR(80),
    fechaHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idEmpleado INT NOT NULL,
    CONSTRAINT FK_MovInv_Producto FOREIGN KEY (idProducto)
        REFERENCES Producto (idProducto) ON DELETE CASCADE,
    CONSTRAINT FK_MovInv_Talla FOREIGN KEY (idTallaStock) REFERENCES TallaStock (idTallaStock),
    CONSTRAINT FK_MovInv_Tipo FOREIGN KEY (idTipoMovimiento) REFERENCES TipoMovimiento (idTipoMovimiento),
    CONSTRAINT FK_MovInv_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona)
);

DROP TABLE IF EXISTS Comprobante CASCADE;
CREATE TABLE Comprobante (
    idComprobante INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idTransaccion INT NOT NULL,
    fechaEmision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bytesPdf BYTEA NOT NULL,
    CONSTRAINT FK_Comprobante_Trans FOREIGN KEY (idTransaccion)
        REFERENCES Transaccion (idTransaccion) ON DELETE CASCADE,
    CONSTRAINT UQ_Comprobante_Trans UNIQUE (idTransaccion)
);

DROP TABLE IF EXISTS Reporte CASCADE;
CREATE TABLE Reporte (
    idReporte INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipoReporte VARCHAR(20) NOT NULL CHECK (tipoReporte IN ('Diario', 'Mensual', 'Rotacion')),
    idEmpleado INT NOT NULL,
    desde DATE NOT NULL,
    hasta DATE NOT NULL,
    filtros VARCHAR(200),
    bytesPdf BYTEA NOT NULL,
    fechaGeneracion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CHK_HastaMayorIgualDesde CHECK (hasta >= desde),
    CONSTRAINT FK_Reporte_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona)
);

DROP TABLE IF EXISTS OrdenCompraPdf CASCADE;
CREATE TABLE OrdenCompraPdf (
    idOrdenCompra INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idPedido INT NOT NULL,
    bytesPdf BYTEA NOT NULL,
    fechaGeneracion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_OrdenPdf_Pedido FOREIGN KEY (idPedido)
        REFERENCES Pedido (idTransaccion) ON DELETE CASCADE,
    CONSTRAINT UQ_OrdenPdf_Pedido UNIQUE (idPedido)
);

DROP TABLE IF EXISTS ParametroSistema CASCADE;
CREATE TABLE ParametroSistema (
    clave VARCHAR(30) PRIMARY KEY,
    valor NUMERIC(10,2) NOT NULL CHECK (valor >= 0),
    descripcion VARCHAR(120),
    actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idEmpleado INT NOT NULL,
    CONSTRAINT FK_Parametro_Empleado FOREIGN KEY (idEmpleado) REFERENCES Empleado (idPersona)
);

DROP TABLE IF EXISTS BitacoraLogin CASCADE;
CREATE TABLE BitacoraLogin (
    idBitacora INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idEmpleado INT NOT NULL,
    fechaEvento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exitoso BOOLEAN NOT NULL,
    CONSTRAINT FK_Bitacora_Emp FOREIGN KEY (idEmpleado)
        REFERENCES Empleado (idPersona) ON DELETE CASCADE
);

DROP TABLE IF EXISTS AlertaStock CASCADE;
CREATE TABLE AlertaStock (
    idAlerta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idProducto INT NOT NULL,
    stockActual NUMERIC(12,3) NOT NULL,
    umbral NUMERIC(12,3) NOT NULL,
    fechaAlerta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    procesada BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT FK_AlertaStock_Producto FOREIGN KEY (idProducto) REFERENCES Producto (idProducto)
);