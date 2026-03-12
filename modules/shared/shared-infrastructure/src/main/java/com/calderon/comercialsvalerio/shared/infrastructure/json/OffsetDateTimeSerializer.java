package com.calderon.comercialsvalerio.shared.infrastructure.json;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

import java.io.IOException;
import java.time.OffsetDateTime;

import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.SQL_DATETIME_WITH_ZONE;

/** Serializa OffsetDateTime usando el formato SQL Server DATETIME2 con zona. */
public class OffsetDateTimeSerializer extends JsonSerializer<OffsetDateTime> {

    @Override
    public void serialize(OffsetDateTime value, JsonGenerator gen, SerializerProvider serializers) throws IOException {

        if (value == null) {
            gen.writeNull();
        } else {
            gen.writeString(value.format(SQL_DATETIME_WITH_ZONE));
        }
    }
}
