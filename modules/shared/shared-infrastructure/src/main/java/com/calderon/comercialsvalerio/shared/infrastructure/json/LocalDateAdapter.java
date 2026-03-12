package com.calderon.comercialsvalerio.shared.infrastructure.json;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.YEAR_ONLY_DATE;

/**
 * Deserializador Jackson para manejar conversiones de {@link LocalDate}.
 */
public class LocalDateAdapter extends JsonDeserializer<LocalDate> {
    private static final List<DateTimeFormatter> FORMATTERS = List.of(
            DateTimeFormatter.ISO_LOCAL_DATE,
            YEAR_ONLY_DATE
    );

    @Override
    public LocalDate deserialize(JsonParser parser, DeserializationContext ctx) throws IOException {

        String value = parser.getValueAsString();

        if (value == null) {
            return null;
        }
        for (DateTimeFormatter fmt : FORMATTERS) {
            try {
                return LocalDate.parse(value, fmt);
            } catch (DateTimeParseException ex) {
                // intentar con el siguiente formato
            }
        }
        throw new IOException("Formato de fecha inválido");
    }
}