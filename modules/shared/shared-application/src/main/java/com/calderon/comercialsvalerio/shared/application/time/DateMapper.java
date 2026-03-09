package com.calderon.comercialsvalerio.shared.application.time;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;

/** Utilidades para convertir valores de fecha y hora usando la zona configurada. */
public final class DateMapper {
    private DateMapper() {
    }

    /** Convierte el {@link LocalDateTime} dado a {@link OffsetDateTime} en la zona configurada. */
    public static OffsetDateTime toOffsetDateTime(LocalDateTime value) {
        if (value == null) {
            return null;
        }
        return value.atZone(TimeZoneProvider.zone()).toOffsetDateTime();
    }

    /** Convierte el {@link OffsetDateTime} dado a {@link LocalDateTime} en la zona configurada. */
    public static LocalDateTime toLocalDateTime(OffsetDateTime value) {
        if (value == null) {
            return null;
        }
        return value.atZoneSameInstant(TimeZoneProvider.zone()).toLocalDateTime();
    }
}