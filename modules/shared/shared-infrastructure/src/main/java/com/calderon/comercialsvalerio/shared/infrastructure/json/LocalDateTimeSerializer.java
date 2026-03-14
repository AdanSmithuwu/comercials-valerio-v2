package com.calderon.comercialsvalerio.shared.infrastructure.json;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

import java.io.IOException;
import java.time.LocalDateTime;

import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.SQL_DATETIME;

/** Serializa valores de {@link LocalDateTime} usando el patrón DATETIME2 de SQL Server. */
public class LocalDateTimeSerializer extends JsonSerializer<LocalDateTime> {

    @Override
    public void serialize(LocalDateTime value, JsonGenerator gen, SerializerProvider serializers) throws IOException {

        if (value == null) {
            gen.writeNull();
        } else {
            gen.writeString(value.format(SQL_DATETIME));
        }
    }
}