package com.calderon.comercialsvalerio.inventory.infrastructure.persistence.mapper;

import org.mapstruct.Mapper;

import com.calderon.comercialsvalerio.inventory.domain.model.AlertaStock;
import com.calderon.comercialsvalerio.inventory.infrastructure.persistence.entity.AlertaStockEntity;

@Mapper(componentModel = "spring", uses = {ProductoMapper.class})
public interface AlertaStockMapper {
    AlertaStock toDomain(AlertaStockEntity entity);
    AlertaStockEntity toEntity(AlertaStock model);
}
