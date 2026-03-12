package com.calderon.comercialsvalerio.shared.infrastructure.json;

import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;

/** Utilidades para instancias comunes de DateTimeFormatter. */
public final class DateTimeFormatterUtils {
    private DateTimeFormatterUtils() {
    }

    private static DateTimeFormatterBuilder yearBuilder() {
        return new DateTimeFormatterBuilder()
                .appendPattern("yyyy")
                .parseDefaulting(ChronoField.MONTH_OF_YEAR, 1)
                .parseDefaulting(ChronoField.DAY_OF_MONTH, 1);
    }

    /** Formato para cadenas de fecha que solo incluyen año. */
    public static final DateTimeFormatter YEAR_ONLY_DATE =
            yearBuilder().toFormatter();

    /** Formato para cadenas de fecha y hora que solo incluyen año. */
    public static final DateTimeFormatter YEAR_ONLY_DATE_TIME = yearBuilder()
            .parseDefaulting(ChronoField.HOUR_OF_DAY, 0)
            .parseDefaulting(ChronoField.MINUTE_OF_HOUR, 0)
            .parseDefaulting(ChronoField.SECOND_OF_MINUTE, 0)
            .toFormatter();

    /** Formato para valores DATETIME2 de SQL Server sin zona. */
    public static final DateTimeFormatter SQL_DATETIME =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSSS");

    /** Formato para valores DATETIME2 de SQL Server con zona. */
    public static final DateTimeFormatter SQL_DATETIME_WITH_ZONE =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSSSXXX");
}