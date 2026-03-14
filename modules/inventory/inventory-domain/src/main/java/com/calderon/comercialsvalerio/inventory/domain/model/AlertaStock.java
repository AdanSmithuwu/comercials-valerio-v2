package com.calderon.comercialsvalerio.inventory.domain.model;

import com.calderon.comercialsvalerio.shared.domain.exception.BusinessRuleViolationException;
import static com.calderon.comercialsvalerio.shared.domain.Validation.ValidationUtils.*;
import com.calderon.comercialsvalerio.shared.domain.constraints.DbConstraints;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/*
 * Alerta generada cuando el stock de un producto cae por debajo de su umbral.
 */
public class AlertaStock extends BaseEntity<Integer> {

    private Integer idAlerta;         // PK autogenerada
    private Producto producto;        // FK obligatorio
    private BigDecimal stockActual;   // >= 0
    private BigDecimal umbral;        // >= 0
    private LocalDateTime fechaAlerta;// no futura
    private boolean procesada;

    public AlertaStock(Integer idAlerta, Producto producto, BigDecimal stockActual,
                       BigDecimal umbral, LocalDateTime fechaAlerta, boolean procesada) {
        setProducto(producto);
        setStockActual(stockActual);
        setUmbral(umbral);
        setFechaAlerta(fechaAlerta);
        this.idAlerta = idAlerta;
        this.procesada = procesada;
    }

    public AlertaStock() {}

    public Integer getIdAlerta() { return idAlerta; }
    @Override
    public Integer getId() { return idAlerta; }
    public Producto getProducto() { return producto; }
    public BigDecimal getStockActual() { return stockActual; }
    public BigDecimal getUmbral() { return umbral; }
    public LocalDateTime getFechaAlerta() { return fechaAlerta; }
    public boolean isProcesada() { return procesada; }

    public void setIdAlerta(Integer id) {
        requireIdNotSet(this.idAlerta, id,
                "El idAlerta ya fue asignado y no puede modificarse");
        this.idAlerta = id;
    }

    public void setProducto(Producto producto) {
        requireNotNull(producto, "Producto obligatorio en alerta");
        this.producto = producto;
    }

    public void setStockActual(BigDecimal stockActual) {
        requireNonNegative(stockActual, "StockActual inválido");
        requirePrecision(stockActual, DbConstraints.STOCK_PRECISION, DbConstraints.STOCK_SCALE,
                "stockActual fuera de rango (" + DbConstraints.STOCK_PRECISION + ',' + DbConstraints.STOCK_SCALE + ")");
        this.stockActual = stockActual;
    }

    public void setUmbral(BigDecimal umbral) {
        requireNonNegative(umbral, "Umbral inválido");
        requirePrecision(umbral, DbConstraints.STOCK_PRECISION, DbConstraints.STOCK_SCALE,
                "umbral fuera de rango (" + DbConstraints.STOCK_PRECISION + ',' + DbConstraints.STOCK_SCALE + ")");
        this.umbral = umbral;
    }

    public void setFechaAlerta(LocalDateTime fechaAlerta) {
        if (fechaAlerta == null || fechaAlerta.isAfter(LocalDateTime.now()))
            throw new BusinessRuleViolationException("Fecha de alerta inválida");
        this.fechaAlerta = fechaAlerta;
    }

    public void setProcesada(boolean procesada) { this.procesada = procesada; }
}