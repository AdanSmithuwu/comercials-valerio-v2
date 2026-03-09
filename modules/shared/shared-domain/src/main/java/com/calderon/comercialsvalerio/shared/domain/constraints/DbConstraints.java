package com.calderon.comercialsvalerio.shared.domain.constraints;

/**
 * Restricciones de base de datos compartidas extraídas de DDL.sql.
 * Estas constantes se reutilizan en las capas de dominio, DTO y entidades
 * para evitar números mágicos y mantener las validaciones consistentes.
 */
public final class DbConstraints {
    private DbConstraints() {}

    // Longitudes generales
    /** NVARCHAR(20) usado en Estado.nombre, MetodoPago.nombre, Rol.nombre, TipoProducto.nombre y TipoMovimiento.nombre. */
    public static final int LEN_NOMBRE_CORTO = 20;
    /** NVARCHAR(20) para la columna Estado.modulo. */
    public static final int LEN_MODULO = 20;
    /** NVARCHAR(40) de Categoria.nombre. */
    public static final int LEN_NOMBRE_CATEGORIA = 40;
    /** NVARCHAR(60) para Persona.nombres y Persona.apellidos. */
    public static final int LEN_NOMBRE_PERSONA = 60;
    /** Longitud de texto devuelto por la función fn_NombreCompleto. */
    public static final int LEN_NOMBRE_COMPLETO = 120;
    /** NVARCHAR(120) usado en Categoria.descripcion, Producto.descripcion y ParametroSistema.descripcion. */
    public static final int LEN_DESCRIPCION = 120;
    /** NVARCHAR(90) de Producto.nombre. */
    public static final int LEN_NOMBRE_PRODUCTO = 90;
    /** Longitud exacta del CHAR(8) Persona.dni. */
    public static final int LEN_DNI = 8;
    /** Definición CHAR para columnas de DNI como Persona.dni. */
    public static final String DEF_DNI_CHAR = "CHAR(" + LEN_DNI + ")";
    /** NVARCHAR(120) para Transaccion.observacion, Transaccion.motivoCancelacion y Pedido.comentarioCancelacion. */
    public static final int LEN_OBSERVACION = 120;
    /** NVARCHAR(10) de Producto.unidadMedida. */
    public static final int LEN_UNIDAD_MEDIDA = 10;
    /** NVARCHAR(120) para Cliente.direccion y Pedido.direccionEntrega. */
    public static final int LEN_DIRECCION = 120;
    /** NVARCHAR(15) de Persona.telefono. */
    public static final int LEN_TELEFONO = 15;
    /** Mínimo de dígitos requeridos para validar Persona.telefono. */
    public static final int TEL_MIN_DIGITS = 6;
    /** NVARCHAR(30) de Empleado.usuario. */
    public static final int LEN_USUARIO = 30;
    /** NVARCHAR(120) de Empleado.hashClave. */
    public static final int LEN_HASH_CLAVE = 120;
    /** Longitud mínima aceptada para Empleado.hashClave. */
    public static final int MIN_HASH_CLAVE = 60;
    /** NVARCHAR(6) de TallaStock.talla. */
    public static final int LEN_TALLA = 6;
    /** NVARCHAR(80) de MovimientoInventario.motivo. */
    public static final int LEN_MOTIVO = 80;
    /** NVARCHAR(20) de Pedido.tipoPedido. */
    public static final int LEN_TIPO_PEDIDO = 20;
    /** NVARCHAR(20) de Reporte.tipoReporte. */
    public static final int LEN_TIPO_REPORTE = 20;
    /** NVARCHAR(200) de Reporte.filtros. */
    public static final int LEN_FILTROS_REPORTE = 200;
    /** NVARCHAR(30) de ParametroSistema.clave. */
    public static final int LEN_CLAVE_PARAM = 30;

    // Precisiones decimales
    /** PRECIO_UNITARIO y campos DECIMAL(10,2) como Producto.precioUnitario, Producto.precioMayorista,
     *  Transaccion.totalBruto, Transaccion.descuento, Transaccion.cargo,
     *  DetalleTransaccion.precioUnitario, PagoTransaccion.monto y ParametroSistema.valor. */
    public static final int PRECIO_PRECISION = 10;
    public static final int PRECIO_SCALE = 2;
    /** Valores DECIMAL(12,3) usados en Producto.stockActual, Producto.umbral,
     *  TallaStock.stock, OrdenCompra.cantidad, DetalleTransaccion.cantidad,
     *  MovimientoInventario.cantidad y AlertaStock.stockActual/umbral. */
    public static final int STOCK_PRECISION = 12;
    public static final int STOCK_SCALE = 3;
    /** DECIMAL(8,3) exclusivo de Presentacion.cantidad. */
    public static final int CANTIDAD_PRECISION = 8;
    public static final int CANTIDAD_SCALE = 3;
    /** DECIMAL(22,5) para DetalleTransaccion.subtotal y reportes derivados. */
    public static final int SUBTOTAL_PRECISION = 22;
    public static final int SUBTOTAL_SCALE = 5;
    /** Dígitos enteros permitidos para columnas DECIMAL(10,2). */
    public static final int PRECIO_INTEGER   = PRECIO_PRECISION - PRECIO_SCALE;
    /** Dígitos enteros permitidos para columnas DECIMAL(12,3). */
    public static final int STOCK_INTEGER    = STOCK_PRECISION - STOCK_SCALE;
    /** Dígitos enteros permitidos para Presentacion.cantidad. */
    public static final int CANTIDAD_INTEGER = CANTIDAD_PRECISION - CANTIDAD_SCALE;
    /** Dígitos enteros permitidos para DetalleTransaccion.subtotal. */
    public static final int SUBTOTAL_INTEGER = SUBTOTAL_PRECISION - SUBTOTAL_SCALE;

    // Límites derivados de los valores de precisión
    /** Cantidad mínima de ovillos para aplicar precio mayorista en pedidos de hilo (lógica de negocio). */
    public static final int MIN_CANTIDAD_MAYORISTA_HILO = 200;
    /** Valor máximo permitido para cantidades DECIMAL(8,3). */
    public static final int MAX_CANTIDAD = (int) Math.pow(10, CANTIDAD_INTEGER) - 1;
}