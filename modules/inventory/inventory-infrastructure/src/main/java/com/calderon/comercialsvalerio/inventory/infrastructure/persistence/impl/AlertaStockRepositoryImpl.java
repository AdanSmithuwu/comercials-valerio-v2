package com.calderon.comercialsvalerio.inventory.infrastructure.persistence.impl;


import java.util.List;

import com.calderon.comercialsvalerio.inventory.domain.model.AlertaStock;
import com.calderon.comercialsvalerio.inventory.domain.repository.AlertaStockRepository;
import com.comercialvalerio.infrastructure.persistence.BaseRepository;
import com.calderon.comercialsvalerio.inventory.infrastructure.persistence.entity.AlertaStockEntity;
import com.calderon.comercialsvalerio.inventory.infrastructure.persistence.mapper.AlertaStockMapper;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.StoredProcedureQuery;

@ApplicationScoped
public class AlertaStockRepositoryImpl extends BaseRepository
        implements AlertaStockRepository {

    @Inject AlertaStockMapper mapper;

    @Override
    public List<AlertaStock> findPendientes() {
        return tx(em -> {
            StoredProcedureQuery sp =
                    em.createNamedStoredProcedureQuery("AlertaStock.listarPendientes");
            var rows = BaseRepository.resultList(sp, AlertaStockEntity.class);
            return rows.stream()
                    .map(mapper::toDomain)
                    .toList();
        });
    }

    @Override
    public void marcarProcesada(Integer idAlerta) {
        tx(em -> {
            AlertaStockEntity e = em.find(AlertaStockEntity.class, idAlerta);
            if (e != null) {
                e.setProcesada(true);
            }
            return null;
        });
    }

    @Override
    public void marcarProcesadaByProducto(Integer idProducto) {
        tx(em -> {
            em.createNamedQuery("AlertaStock.marcarProcesadaByProducto")
                    .setParameter("p", idProducto)
                    .executeUpdate();
            return null;
        });
    }

    @Override
    public void save(AlertaStock alerta) {
        tx(em -> {
            AlertaStockEntity e = mapper.toEntity(alerta);
            em.persist(e);
            alerta.setIdAlerta(e.getIdAlerta());
            return null;
        });
    }

    @Override
    public boolean existsPendienteByProducto(Integer idProducto) {
        return read(em -> em.createNamedQuery(
                        "AlertaStock.countPendienteByProducto",
                        Long.class)
                .setParameter("p", idProducto)
                .getSingleResult() > 0);
    }

    @Override
    public void deleteByProducto(Integer idProducto) {
        tx(em -> {
            em.createNamedQuery("AlertaStock.deleteByProducto")
                    .setParameter("p", idProducto)
                    .executeUpdate();
            return null;
        });
    }
}