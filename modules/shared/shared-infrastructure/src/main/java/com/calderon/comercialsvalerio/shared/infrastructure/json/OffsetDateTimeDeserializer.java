package com.calderon.comercialsvalerio.shared.infrastructure.json;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;

import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.SQL_DATETIME;
import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.SQL_DATETIME_WITH_ZONE;

/** Deserializa cadenas ISO o segundos epoch en {@link OffsetDateTime}. */
public class OffsetDateTimeDeserializer extends JsonDeserializer<OffsetDateTime> {

    private static final DateTimeFormatter FLEX_WITH_ZONE = new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd HH:mm:ss")
            .optionalStart()
            .appendFraction(ChronoField.NANO_OF_SECOND, 0, 9, true)
            .optionalEnd()
            .appendOffset("+HH:MM", "Z")
            .toFormatter();

    private static final DateTimeFormatter FLEX = new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd HH:mm:ss")
            .optionalStart()
            .appendFraction(ChronoField.NANO_OF_SECOND, 0, 9, true)
            .optionalEnd()
            .toFormatter();

    @Override
    public OffsetDateTime deserialize(JsonParser parser, DeserializationContext ctx) throws IOException {

        JsonToken token = parser.currentToken();
        if (token == null) {
            token = parser.nextToken();
        }

        if (token == JsonToken.VALUE_NULL) {
            return null;
        }

        try {

            if (token == JsonToken.VALUE_STRING) {

                String str = parser.getValueAsString();

                try {
                    return OffsetDateTime.parse(str);
                } catch (DateTimeParseException ex) {}

                try {
                    return OffsetDateTime.parse(str, SQL_DATETIME_WITH_ZONE);
                } catch (DateTimeParseException ex) {}

                try {
                    return OffsetDateTime.parse(str, FLEX_WITH_ZONE);
                } catch (DateTimeParseException ex) {}

                try {
                    LocalDateTime ldt = LocalDateTime.parse(str, SQL_DATETIME);
                    return ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
                } catch (DateTimeParseException ex) {}

                try {
                    LocalDateTime ldt = LocalDateTime.parse(str, FLEX);
                    return ldt.atZone(ZoneId.systemDefault()).toOffsetDateTime();
                } catch (DateTimeParseException ex) {
                    return parseEpoch(new BigDecimal(str));
                }
            }

            if (token == JsonToken.VALUE_NUMBER_INT || token == JsonToken.VALUE_NUMBER_FLOAT) {

                BigDecimal bd = parser.getDecimalValue();
                return parseEpoch(bd);
            }

        } catch (NumberFormatException | DateTimeParseException ex) {
            throw new IOException("Formato de fecha y hora inválido", ex);
        }

        throw new IOException("Token inesperado " + token + " al leer OffsetDateTime");
    }

    private OffsetDateTime parseEpoch(BigDecimal bd) {

        long seconds = bd.longValue();
        int nanos = bd.remainder(BigDecimal.ONE).movePointRight(9).intValue();

        return OffsetDateTime.ofInstant(
                Instant.ofEpochSecond(seconds, nanos),
                ZoneOffset.UTC
        );
    }
}