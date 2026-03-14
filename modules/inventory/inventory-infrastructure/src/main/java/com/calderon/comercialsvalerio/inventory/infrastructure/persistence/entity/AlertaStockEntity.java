package com.calderon.comercialsvalerio.inventory.infrastructure.persistence.entity;

import static com.calderon.comercialsvalerio.shared.domain.constraints.DbConstraints.*;

import jakarta.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity(name = "AlertaStock")
@Table(name = "AlertaStock")
@NamedQueries({
        @NamedQuery(name = "AlertaStock.countPendienteByProducto",
                query = "SELECT COUNT(a) FROM AlertaStock a WHERE a.procesada = false AND a.producto.idProducto = :p"),
        @NamedQuery(
                name = "AlertaStock.marcarProcesadaByProducto",
                query = "UPDATE AlertaStock a SET a.procesada = true " +
                        "WHERE a.procesada = false AND a.producto.idProducto = :p"
        ),
        @NamedQuery(name = "AlertaStock.deleteByProducto",
                query = "DELETE FROM AlertaStock a WHERE a.producto.idProducto = :p")
})
@NamedStoredProcedureQueries({
        @NamedStoredProcedureQuery(name = "AlertaStock.listarPendientes",
                procedureName = "dbo.sp_ListarAlertasPendientes",
                resultSetMappings = "AlertaStockPendienteMapping")
})
@SqlResultSetMapping(name = "AlertaStockPendienteMapping",
        entities = @EntityResult(entityClass = AlertaStockEntity.class))
public class AlertaStockEntity implements Serializable {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idAlerta")
    private Integer idAlerta;

    @ManyToOne(optional = false) @JoinColumn(name = "idProducto")
    private ProductoEntity producto;

    @Column(name = "stockActual", nullable = false,
            precision = STOCK_PRECISION, scale = STOCK_SCALE)
    private BigDecimal stockActual;

    @Column(name = "umbral", nullable = false,
            precision = STOCK_PRECISION, scale = STOCK_SCALE)
    private BigDecimal umbral;

    @Column(name = "fechaAlerta", nullable = false)
    private LocalDateTime fechaAlerta;

    @Column(name = "procesada", nullable = false)
    private boolean procesada;

    public AlertaStockEntity() {}

    public Integer getIdAlerta() { return idAlerta; }
    public void setIdAlerta(Integer idAlerta) { this.idAlerta = idAlerta; }

    public ProductoEntity getProducto() { return producto; }
    public void setProducto(ProductoEntity producto) { this.producto = producto; }

    public BigDecimal getStockActual() { return stockActual; }
    public void setStockActual(BigDecimal stockActual) { this.stockActual = stockActual; }

    public BigDecimal getUmbral() { return umbral; }
    public void setUmbral(BigDecimal umbral) { this.umbral = umbral; }

    public LocalDateTime getFechaAlerta() { return fechaAlerta; }
    public void setFechaAlerta(LocalDateTime fechaAlerta) { this.fechaAlerta = fechaAlerta; }

    public boolean isProcesada() { return procesada; }
    public void setProcesada(boolean procesada) { this.procesada = procesada; }
}