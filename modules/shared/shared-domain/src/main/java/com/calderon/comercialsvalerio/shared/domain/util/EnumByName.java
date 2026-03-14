package com.calderon.comercialsvalerio.shared.domain.util;

import com.comercialvalerio.domain.model.NombreComparable;
import java.util.Arrays;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/** Utilidad para obtener constantes enum a partir de su nombre legible. */
public final class EnumByName {
    private static final Map<Class<?>, Map<String, Enum<?>>> CACHE = new ConcurrentHashMap<>();

    private EnumByName() {
    }

    /**
     * Devuelve la constante del enum indicado cuyo nombre coincide con el texto
     * proporcionado sin distinguir mayúsculas.
     *
     * @param type   clase del enum
     * @param nombre nombre legible
     * @param <E>    tipo que implementa {@link NombreComparable}
     * @return constante coincidente
     * @throws IllegalArgumentException si no existe coincidencia
     */
    @SuppressWarnings("unchecked")
    public static <E extends Enum<E> & NombreComparable> E fromNombre(Class<E> type,
                                                                      String nombre) {
        if (nombre == null || nombre.isBlank()) {
            throw new IllegalArgumentException("Nombre nulo o vacío");
        }
        String key = nombre.toLowerCase(Locale.ROOT);
        Map<String, Enum<?>> map = CACHE.computeIfAbsent(type, c -> {
            Class<E> clazz = (Class<E>) c;
            Map<String, E> m = Arrays.stream(clazz.getEnumConstants())
                    .collect(Collectors.toUnmodifiableMap(
                            e -> ((NombreComparable) e).getNombre().toLowerCase(Locale.ROOT),
                            e -> e));
            return (Map<String, Enum<?>>) (Map<?, ?>) m;
        });
        E result = (E) map.get(key);
        if (result == null) {
            throw new IllegalArgumentException(type.getSimpleName() + " inválido: " + nombre);
        }
        return result;
    }
}
