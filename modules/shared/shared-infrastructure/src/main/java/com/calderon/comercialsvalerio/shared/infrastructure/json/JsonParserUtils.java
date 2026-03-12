package com.calderon.comercialsvalerio.shared.infrastructure.json;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;

/** Utilidades para {@link JsonParser}. */
public final class JsonParserUtils {
    private JsonParserUtils() {
    }

    /**
     * Devuelve el token actual del parser o avanza cuando no hay uno disponible.
     * Si el parser no tiene más tokens o encuentra un valor nulo, se devuelve {@code null}.
     */
    public static JsonToken currentEventOrNext(JsonParser parser) throws java.io.IOException {
        if (parser.isClosed()) {
            return null;
        }

        JsonToken ev = parser.currentToken();
        if (ev == null) {
            ev = parser.nextToken();
        }

        while (ev == JsonToken.FIELD_NAME
                || ev == JsonToken.START_OBJECT
                || ev == JsonToken.START_ARRAY) {

            ev = parser.nextToken();
            if (ev == null) {
                return null;
            }
        }

        return ev == JsonToken.VALUE_NULL ? null : ev;
    }
}
