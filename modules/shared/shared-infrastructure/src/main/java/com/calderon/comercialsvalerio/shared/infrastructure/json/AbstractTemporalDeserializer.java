package com.calderon.comercialsvalerio.shared.infrastructure.json;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Deserializador base para tipos temporales usando una lista de {@link DateTimeFormatter}s.
 */
public abstract class AbstractTemporalDeserializer<T> extends JsonDeserializer<T> {
    @Override
    public T deserialize(JsonParser parser, DeserializationContext ctx) throws IOException {
        JsonToken ev = parser.getCurrentToken();
        if (ev == null) {
            ev = parser.nextToken();
        }
        if (ev == JsonToken.VALUE_STRING) {
            String str = parser.getValueAsString();
            for (DateTimeFormatter fmt : formatters()) {
                try {
                    return parse(str, fmt);
                } catch (DateTimeParseException ex) {
                    // intentar con el siguiente patrón
                }
            }
            throw new IOException(invalidFormatMessage());
        } else if (ev == JsonToken.VALUE_NUMBER_INT) {
            int year = parser.getIntValue();
            return fromYear(year);
        }
        throw new IOException("Token inesperado " + ev + " al leer " + typeName());
    }

    /** Lista de formatters usada para analizar valores de texto. */
    protected abstract List<DateTimeFormatter> formatters();

    /** Analiza la cadena usando el formatter proporcionado. */
    protected abstract T parse(String str, DateTimeFormatter formatter) throws DateTimeParseException;

    /** Crea un valor solo con la parte del año. */
    protected abstract T fromYear(int year);

    /** Mensaje de error cuando ninguno de los formatters coincide. */
    protected abstract String invalidFormatMessage();

    /** Nombre del tipo temporal para los mensajes de error. */
    protected abstract String typeName();
}