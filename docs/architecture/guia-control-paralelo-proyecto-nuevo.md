# Guía de control paralelo: proyecto original vs proyecto nuevo

## 1. Propósito de este documento
Este documento define cómo construir un proyecto nuevo desde cero (Spring Boot) manteniendo
trazabilidad fase a fase con el proyecto original de este repositorio.

La meta es que, en cada avance, puedas responder claramente:
- qué pieza del nuevo sistema es equivalente al sistema original,
- qué código se reutilizó casi igual,
- qué se adaptó,
- y qué se creó como mejora nueva.

## 2. Principio de trabajo simultáneo
Trabaja siempre con dos vistas al mismo tiempo:
- **Vista A (original / referencia):** fuente funcional y técnica existente en `nose`.
- **Vista B (nuevo / objetivo):** implementación moderna que estás creando desde cero.

Cada ítem implementado en la Vista B debe quedar registrado en una matriz con:
- referencia exacta de origen,
- decisión tomada,
- evidencia de validación,
- fase en la que se implementó.

## 3. Reglas de mapeo para no perder el hilo
Para cada componente que migres o recrees, clasifícalo en una de estas categorías:

- **IGUAL**: se replica comportamiento y estructura con mínimos cambios técnicos.
- **EQUIVALENTE**: se conserva el comportamiento, cambia diseño interno.
- **MEJORADO**: se conserva objetivo funcional y se optimiza diseño/regla.
- **NUEVO**: no existe en original; surge por necesidades de calidad o arquitectura.

> Recomendación: usa una etiqueta por clase, endpoint, script SQL o caso de uso para mantener
> claridad del progreso.

## 4. Mapa base de equivalencia de capas
Usa este mapa como plantilla base para enlazar componentes del original con el nuevo proyecto.

| Capa en `nose` | Rol en original | Equivalente sugerido en nuevo Spring Boot | Tipo de relación esperada |
|---|---|---|---|
| `domain` | Entidades y reglas de negocio puras | `domain` (`model`, `valueobject`, `service`) | EQUIVALENTE / MEJORADO |
| `application` | Casos de uso y orquestación | `application` (`usecase`, `port.in`, `port.out`) | EQUIVALENTE |
| `infrastructure` | Persistencia y adaptadores | `infrastructure` (`adapter.persistence`, `adapter.rest`, `config`) | EQUIVALENTE / MEJORADO |
| `presentation-ui` | Interfaz web y flujos de UI | Proyecto frontend separado o módulo UI equivalente | EQUIVALENTE / MEJORADO |
| `db` | Estructura y artefactos SQL | `db/migration` (Flyway/Liquibase) + scripts de soporte | IGUAL / MEJORADO |
| `common` | Utilidades transversales | `shared` o `common` en nuevo proyecto | EQUIVALENTE |

## 5. Método operativo por fase (0 a 7)

### Fase 0: Gobierno técnico y arranque guiado
- Define estructura de paquetes del proyecto nuevo.
- Crea convenciones de nombres, errores, DTOs, logs y migraciones.
- Abre el tablero de control paralelo (ver sección 7).
- Resultado mínimo: una lista inicial de equivalencias de módulos y responsabilidades.

### Fase 1: Inventario funcional y matriz de migración
- Recorre artefactos clave del original (casos de uso, SQL, servicios).
- Construye una **matriz origen -> destino** por prioridad (P1/P2/P3).
- Señala qué reglas se mantienen en DB y cuáles pasan al backend.
- Resultado mínimo: backlog de migración ordenado y trazable.

### Fase 2: Modelo de datos y migraciones
- Conserva el modelo funcional de la base actual (misma semántica).
- Implementa migraciones versionadas para el proyecto nuevo.
- Marca explícitamente diferencias aceptadas (nombres, tipos, índices).
- Resultado mínimo: esquema reproducible y registro de diferencias justificadas.

### Fase 3: Backend core
- Implementa casos de uso críticos en el nuevo backend.
- Por cada caso de uso: enlaza fuente original, clase nueva y pruebas manuales/técnicas.
- Mantén catálogo de reglas: regla original, regla nueva, estado (igual/mejorada).
- Resultado mínimo: flujo crítico funcional con trazabilidad completa.

### Fase 4: Frontend e integración E2E
- Replica primero flujos UI equivalentes al original.
- Después aplica mejoras de UX sin perder paridad funcional.
- Documenta cada pantalla con su equivalente en el original.
- Resultado mínimo: flujo punta a punta funcionando sobre backend nuevo.

### Fase 5: Estabilización y despliegue
- Cierra brechas entre comportamiento original y nuevo.
- Optimiza rendimiento y seguridad conservando resultado funcional.
- Registra cada ajuste técnico indicando si cambia o no la semántica.
- Resultado mínimo: versión desplegable con checklist de calidad cumplido.

### Fase 6: Operación y mejora continua
- Monitorea incidencias comparando contra expectativas del sistema original.
- Prioriza deuda técnica nacida durante la migración.
- Mantén histórico de cambios evolutivos sobre componentes equivalentes.
- Resultado mínimo: ciclo de mejora continua con métricas periódicas.

### Fase 7: Escalamiento estratégico
- Introduce capacidades nuevas no presentes en el original.
- Preserva la trazabilidad histórica para diferenciar migración vs innovación.
- Evalúa impacto funcional y operativo antes de escalar.
- Resultado mínimo: roadmap evolutivo con base estable ya modernizada.

## 6. Protocolo de implementación de cada pieza
Aplica este flujo para cada clase, endpoint, tabla o regla de negocio:

1. **Identificar origen**
    - Localiza el artefacto en `nose` (módulo, archivo, función/regla).
2. **Definir destino**
    - Decide paquete/clase/tabla del proyecto nuevo donde vivirá.
3. **Clasificar relación**
    - IGUAL, EQUIVALENTE, MEJORADO o NUEVO.
4. **Implementar y comentar decisión**
    - Documenta por qué se copió, adaptó o rediseñó.
5. **Validar comportamiento**
    - Comprueba entradas/salidas esperadas contra el comportamiento del original.
6. **Registrar evidencia**
    - Actualiza tablero paralelo con commit, fecha y observaciones.

## 7. Plantilla de tablero de control paralelo
Copia esta tabla en tu herramienta de seguimiento (Markdown, Notion, Excel o Jira).

| ID | Fase | Dominio | Artefacto original (`nose`) | Artefacto nuevo | Relación | Estado | Evidencia |
|---|---|---|---|---|---|---|---|
| PAR-001 | 1 | Autenticación | `infrastructure/...` | `auth/application/LoginUseCase.java` | EQUIVALENTE | En progreso | Commit `abc123` |
| PAR-002 | 2 | Base de datos | `db/...` | `db/migration/V1__baseline.sql` | IGUAL | Hecho | Script aplicado local |
| PAR-003 | 3 | Ventas | `sp_RegistrarVenta` | `sales/application/RegistrarVentaUseCase.java` | MEJORADO | Pendiente | Sin evidencia |

> Recomendación: usa un prefijo por fase (`F0-`, `F1-`, etc.) para facilitar reportes.

## 8. Plantilla de ficha por componente (nivel detallado)

```markdown
### Componente: Registrar venta
- Fase: 3
- Tipo: Caso de uso backend
- Origen (nose): [ruta/artefacto original]
- Destino (nuevo): [paquete/clase nueva]
- Relación: IGUAL | EQUIVALENTE | MEJORADO | NUEVO
- Regla funcional original: [resumen]
- Implementación nueva: [resumen]
- Diferencias intencionales: [lista]
- Riesgos: [lista]
- Validación ejecutada: [pasos]
- Evidencia: [commit, PR, captura, log]
```

## 9. Convención de commits para seguimiento paralelo
Además del mensaje de commit en inglés, agrega trazabilidad en el cuerpo:

```text
Implement sales registration use case

Parallel-Trace: PAR-003
Phase: 3
Relation: IMPROVED
Original-Ref: sp_RegistrarVenta
```

Así podrás auditar fácilmente qué parte se migró, qué se mejoró y dónde está su equivalente.

## 10. Criterio de avance por fase en modo simultáneo
Una fase se considera controlada cuando:
- existe cobertura de los ítems prioritarios en el tablero,
- cada ítem tiene relación (IGUAL/EQUIVALENTE/MEJORADO/NUEVO),
- cada ítem tiene evidencia técnica,
- y las diferencias intencionales están justificadas.

## 11. Recomendación práctica para aprendizaje
Como objetivo personal de aprendizaje, trabaja cada ítem con esta secuencia:
1. Leer cómo está resuelto en el original.
2. Explicar con tus palabras qué problema resuelve.
3. Implementarlo en el proyecto nuevo.
4. Mejorarlo en una segunda pasada (no en la primera).
5. Registrar qué cambió y por qué cambió.

Esto te permitirá aprender arquitectura y diseño sin perder trazabilidad sobre el legado.
