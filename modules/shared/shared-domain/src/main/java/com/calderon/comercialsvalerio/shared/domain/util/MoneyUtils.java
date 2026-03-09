package com.calderon.comercialsvalerio.shared.domain.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

/** Utilidades para formatear valores monetarios. */
public final class MoneyUtils {
    private static final Locale ES_PE = Locale.of("es", "PE");
    private static final DecimalFormatSymbols ES_PE_SYMBOLS =
            DecimalFormatSymbols.getInstance(ES_PE);
    private static final ThreadLocal<DecimalFormat> FORMATTER =
            ThreadLocal.withInitial(() -> {
                DecimalFormat fmt = new DecimalFormat("\u00A4 #,##0.00",
                        ES_PE_SYMBOLS);
                fmt.setParseBigDecimal(true);
                return fmt;
            });

    private MoneyUtils() {
    }

    /** Formatea el valor dado para la localidad es-PE. */
    public static String format(BigDecimal value) {
        if (value == null) {
            value = BigDecimal.ZERO;
        }
        return FORMATTER.get().format(value);
    }

    /**
     * Convierte la cadena dada a {@link BigDecimal} usando el formato
     * configurado para la localidad es-PE.
     *
     * @param text cadena a convertir, puede ser {@code null} o vacía
     * @return el valor correspondiente o {@link BigDecimal#ZERO} si la cadena
     *         es nula o está vacía
     * @throws IllegalArgumentException si el texto no tiene un formato válido
     */
    public static BigDecimal parse(String text) {
        if (text == null || text.isBlank()) {
            return BigDecimal.ZERO;
        }
        try {
            return (BigDecimal) FORMATTER.get().parse(text);
        } catch (java.text.ParseException ex) {
            throw new IllegalArgumentException("Formato monetario inválido", ex);
        }
    }
}
