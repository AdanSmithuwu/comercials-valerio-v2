package com.calderon.comercialsvalerio.shared.domain.util;

import java.util.List;

/** Utilidades para construir listas de dependencias. */
public final class DependencyUtils {
    private DependencyUtils() {}

    /**
     * Agrega el elemento cuando la condición es verdadera.
     *
     * @param condition si la dependencia existe
     * @param item      elemento a agregar
     * @param list      lista a actualizar
     * @return la misma lista para encadenar
     */
    public static <T> List<T> addIf(boolean condition, T item, List<T> list) {
        if (condition) {
            list.add(item);
        }
        return list;
    }
}