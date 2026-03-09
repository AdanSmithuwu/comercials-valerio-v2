# Fase 0: Gobierno técnico y definición base del sistema

## 1. Objetivo de esta fase
Establecer una base técnica única para rediseñar el sistema completo (backend, frontend y base de datos),
priorizando mantenibilidad, escalabilidad, trazabilidad y reducción de lógica de negocio en base de datos.

## 2. Alcance
- Definir arquitectura objetivo por capas.
- Definir criterios de calidad y estándares de desarrollo.
- Definir Definition of Done por módulo.
- Definir el plan de transición desde SQL Server (SP/Triggers) a PostgreSQL + Spring Boot.

## 3. Decisiones de arquitectura (baseline)

### 3.1 Estilo arquitectónico
- Backend con arquitectura en capas alineada al repositorio:
    - `domain`: reglas de dominio puras y objetos de valor.
    - `application`: casos de uso y orquestación transaccional.
    - `infrastructure`: persistencia, adaptadores externos y seguridad técnica.
    - `presentation-ui`: frontend React consumiendo APIs REST.
- Base de datos PostgreSQL orientada a integridad y performance, no a lógica de negocio compleja.

### 3.2 Regla central de negocio
- Las reglas de negocio críticas deben vivir en backend (servicios de aplicación y dominio).
- En base de datos se mantienen:
    - PK/FK.
    - UNIQUE.
    - CHECK simples.
    - índices para rendimiento.

### 3.3 Seguridad
- Autenticación con JWT.
- Autorización por rol (`ADMIN`, `EMPLEADO`) y permisos por caso de uso.
- Auditoría de acceso y operaciones sensibles desde backend.

### 3.4 Modelo de datos
- PostgreSQL como fuente única de verdad.
- Migraciones versionadas obligatorias (Flyway o Liquibase).
- Prohibido editar estructuras manualmente en producción sin script versionado.

## 4. Principios de implementación
- Un caso de uso = un contrato API + una transacción consistente.
- Errores de negocio tipificados y trazables.
- Idempotencia en operaciones críticas cuando aplique.
- Observabilidad mínima: logs estructurados y correlación por request.
- Código nuevo con responsabilidad única y bajo acoplamiento.

## 5. Definition of Done por módulo

### 5.1 `db`
- Script de migración versionado aplicado correctamente.
- Constraints e índices validados.
- Sin triggers de negocio nuevos.
- Documentación de cambios y rollback.

### 5.2 `domain`
- Entidades y objetos de valor con invariantes explícitas.
- Sin dependencias de infraestructura.
- Reglas críticas cubiertas con pruebas unitarias del módulo (cuando se habilite plan de pruebas).

### 5.3 `application`
- Caso de uso implementado con transacción y validaciones.
- DTOs de entrada/salida definidos.
- Errores de negocio mapeados a códigos funcionales.

### 5.4 `infrastructure`
- Repositorios y adaptadores implementados y desacoplados.
- Persistencia alineada al modelo PostgreSQL vigente.
- Auditoría técnica en operaciones sensibles.

### 5.5 `presentation-ui`
- Formulario/pantalla consume API real.
- Validaciones de UX alineadas con backend.
- Manejo de errores funcionales visible para usuario.

### 5.6 Criterios transversales
- Documentación mínima del cambio.
- Revisión técnica de pares.
- Cumplimiento de convenciones de nombres y estilo.

## 6. Mapa de transición de lógica SQL Server

### 6.1 Qué se conserva en base de datos
- Integridad relacional.
- Restricciones simples de consistencia.
- Índices y optimización de lectura.

### 6.2 Qué se migra al backend
- Validaciones de flujo de venta/pedido.
- Cálculos de precios, descuentos, cargos y reglas mayoristas.
- Reglas de cancelación, entrega y transición de estados.
- Reglas de stock derivadas de operaciones transaccionales.

### 6.3 Qué se revisa caso por caso
- Vistas de reporte: mantener como SQL optimizado o mover a consultas de aplicación.
- Funciones escalares: mantener solo utilitarias no acopladas a lógica de proceso.

## 7. Roadmap inmediato (siguiente fase)

### Fase 1: Inventario funcional y matriz de migración
- Construir matriz `origen SQL -> destino backend` para:
    - Triggers.
    - Stored procedures.
    - Funciones.
    - Vistas.
- Priorizar por criticidad operativa:
    1. Ventas y pagos.
    2. Pedidos y entregas.
    3. Inventario y alertas.
    4. Seguridad y auditoría.
    5. Reportes.

## 8. Entregables de Fase 0
- Este documento como baseline de gobierno técnico.
- Lista de responsables por módulo (pendiente de completar por el equipo).
- Calendario de hitos por sprint (pendiente de completar por el equipo).

## 9. Riesgos identificados
- Dependencia oculta en triggers/SP históricos.
- Divergencia funcional durante la transición.
- Riesgos de concurrencia en inventario.
- Sobrecarga de reportes sin estrategia de consulta/índices.

## 10. Criterio de cierre de Fase 0
La fase se considera cerrada cuando el equipo aprueba formalmente:
- la arquitectura objetivo,
- el Definition of Done por módulo,
- y el plan de ejecución de Fase 1.

comercialsvalerio/
├─ pom.xml
├─ README.md
├─ .gitignore
├─ docs/
│  ├─ architecture/
│  │  ├─ adr/
│  │  ├─ guia-control-paralelo-proyecto-nuevo.md
│  │  ├─ fase-beta-base-proyecto-comercialsvalerio.md
│  │  └─ tablero-control-paralelo.md
│  ├─ api/
│  ├─ domain/
│  ├─ persistence/
│  └─ runbooks/
│
├─ apps/
│  ├─ api-rest/                          # Spring Boot app (main)
│  │  └─ src/main/java/com/calderon/comercialsvalerio/
│  │     ├─ api/                         # controllers REST, handlers
│  │     ├─ config/                      # security, openapi, jackson
│  │     └─ bootstrap/                   # config inicial, seeds
│  └─ backoffice-ui/                     # frontend (cuando toque)
│
├─ modules/
│  ├─ shared/
│  │  ├─ shared-domain/                  # value objects comunes, errores base
│  │  ├─ shared-application/             # DTO base, contratos cross-cutting
│  │  └─ shared-infrastructure/          # utilidades técnicas transversales
│
│  ├─ iam/                               # autenticación/autorización
│  │  ├─ iam-domain/
│  │  ├─ iam-application/
│  │  └─ iam-infrastructure/
│
│  ├─ sales/                             # ventas/transacciones/comprobantes
│  │  ├─ sales-domain/
│  │  ├─ sales-application/
│  │  └─ sales-infrastructure/
│
│  ├─ orders/                            # pedidos/entregas/orden compra
│  │  ├─ orders-domain/
│  │  ├─ orders-application/
│  │  └─ orders-infrastructure/
│
│  ├─ inventory/                         # stock/alertas/movimientos
│  │  ├─ inventory-domain/
│  │  ├─ inventory-application/
│  │  └─ inventory-infrastructure/
│
│  ├─ catalog/                           # productos/categorías/presentaciones
│  │  ├─ catalog-domain/
│  │  ├─ catalog-application/
│  │  └─ catalog-infrastructure/
│
│  ├─ customers/                         # clientes/historial cliente
│  │  ├─ customers-domain/
│  │  ├─ customers-application/
│  │  └─ customers-infrastructure/
│
│  └─ reports/                           # reportes diarios/mensuales/rotación
│     ├─ reports-domain/
│     ├─ reports-application/
│     └─ reports-infrastructure/
│
└─ db/
├─ migration/                         # Flyway
├─ seed/
└─ scripts/