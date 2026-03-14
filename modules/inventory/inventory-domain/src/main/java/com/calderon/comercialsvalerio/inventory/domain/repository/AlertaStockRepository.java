package com.calderon.comercialsvalerio.inventory.domain.repository;

import com.calderon.comercialsvalerio.inventory.domain.model.AlertaStock;
import java.util.List;

/* Registro de alertas de bajo stock */
public interface AlertaStockRepository {

    List<AlertaStock> findPendientes();

    void marcarProcesada(Integer idAlerta);

    /** Marca como procesadas todas las alertas pendientes del producto dado. */
    void marcarProcesadaByProducto(Integer idProducto);

    void save(AlertaStock alerta);

    /** Devuelve {@code true} si el producto ya posee una alerta sin resolver. */
    boolean existsPendienteByProducto(Integer idProducto);

    /** Elimina todas las alertas del producto indicado. */
    void deleteByProducto(Integer idProducto);
}
