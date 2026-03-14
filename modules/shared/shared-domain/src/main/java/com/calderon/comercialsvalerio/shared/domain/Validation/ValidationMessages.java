package com.calderon.comercialsvalerio.shared.domain.Validation;

import com.calderon.comercialsvalerio.shared.domain.constraints.DbConstraints;

/** Constantes comunes de mensajes de validación reutilizadas en el dominio. */
public final class ValidationMessages {
    private ValidationMessages() {}

    public static final String NAME_CHARS_ONLY =
            "El nombre contiene caracteres inválidos";

    public static final String MODULE_CHARS_ONLY =
            "El módulo solo puede contener letras, números y espacios";

    /** Template: El nombre {0} es obligatorio (máx. {1} caracteres) */
    public static final String NAME_REQUIRED_MAX_LENGTH =
            "El nombre %s es obligatorio (máx. %d caracteres)";

    /** Template: {0} es obligatorio (máx. {1} caracteres) */
    public static final String FIELD_REQUIRED_MAX_LENGTH =
            "%s es obligatorio (máx. %d caracteres)";

    /** Template: El usuario es obligatorio (máx. {0} caracteres) */
    public static final String USER_REQUIRED_MAX_LENGTH =
            "El usuario es obligatorio (máx. %d caracteres)";

    public static final String DESCRIPTION_TOO_LONG =
            "La descripción supera " + DbConstraints.LEN_DESCRIPCION + " caracteres";

    public static final String STATE_REQUIRED =
            "El estado es obligatorio";

    public static final String UNIT_PRICE_POSITIVE =
            "El precio unitario debe ser \u2265 0";

    public static final String QUANTITY_GREATER_THAN_ZERO =
            "La cantidad debe ser mayor a cero";

    public static final String PAYMENTS_TOTAL_MISMATCH =
            "La suma de pagos debe coincidir con el total neto";
}