package com.calderon.comercialsvalerio.shared.infrastructure.json;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.List;

import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.YEAR_ONLY_DATE_TIME;
import static com.calderon.comercialsvalerio.shared.infrastructure.json.DateTimeFormatterUtils.SQL_DATETIME;

/** Deserializa cadenas o números en {@link LocalDateTime}. */
public class LocalDateTimeDeserializer extends AbstractTemporalDeserializer<LocalDateTime> {
    private static final List<DateTimeFormatter> FORMATTERS = List.of(
            DateTimeFormatter.ISO_LOCAL_DATE_TIME,
            SQL_DATETIME,
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
            new DateTimeFormatterBuilder()
                    .append(DateTimeFormatter.ISO_LOCAL_DATE)
                    .parseDefaulting(ChronoField.HOUR_OF_DAY, 0)
                    .parseDefaulting(ChronoField.MINUTE_OF_HOUR, 0)
                    .parseDefaulting(ChronoField.SECOND_OF_MINUTE, 0)
                    .toFormatter(),
            YEAR_ONLY_DATE_TIME
    );

    @Override
    protected List<DateTimeFormatter> formatters() {
        return FORMATTERS;
    }

    @Override
    protected LocalDateTime parse(String str, DateTimeFormatter formatter) {
        return LocalDateTime.parse(str, formatter);
    }

    @Override
    protected LocalDateTime fromYear(int year) {
        return LocalDate.of(year, 1, 1).atStartOfDay();
    }

    @Override
    protected String invalidFormatMessage() {
        return "Formato de fecha y hora inválido";
    }

    @Override
    protected String typeName() {
        return "LocalDateTime";
    }
}

