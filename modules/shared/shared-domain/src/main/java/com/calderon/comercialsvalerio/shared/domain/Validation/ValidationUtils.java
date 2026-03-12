package com.calderon.comercialsvalerio.shared.domain.Validation;

import static com.calderon.comercialsvalerio.shared.domain.exception.BusinessRuleViolationException;
import static com.calderon.comercialsvalerio.shared.domain.constraints.DbConstraints;
import java.math.BigDecimal;
import java.util.regex.Pattern;

/** Utilidades para validar las invariantes del dominio. */
public final class ValidationUtils {
    private ValidationUtils() {}

    /** Permite nombres sin caracteres de control. */
    private static final Pattern TEXT_PATTERN = Pattern.compile("[^\\p{Cntrl}]+");

    public static void requireNotNull(Object value, String message) {
        if (value == null) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requireNotBlank(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requireMaxLength(String value, int max, String message) {
        if (value != null && value.length() > max) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requirePositive(BigDecimal value, String message) {
        if (value == null || value.compareTo(BigDecimal.ZERO) <= 0) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requirePositive(Integer value, String message) {
        if (value == null || value <= 0) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requireNonNegative(BigDecimal value, String message) {
        if (value == null || value.compareTo(BigDecimal.ZERO) < 0) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requireNonNegative(Integer value, String message) {
        if (value == null || value < 0) {
            throw new BusinessRuleViolationException(message);
        }
    }

    public static void requirePrecision(BigDecimal value, int precision,
                                        int scale, String message) {
        if (value == null) return;
        int integerDigits = value.precision() - value.scale();
        int maxInteger = precision - scale;
        if (integerDigits > maxInteger || value.scale() > scale) {
            throw new BusinessRuleViolationException(message);
        }
    }

    /**
     * Verifica que un identificador no haya sido asignado previamente. Si el id
     * actual no es {@code null} y difiere del nuevo, se lanza
     * {@link BusinessRuleViolationException}.
     *
     * @param currentId valor actual del identificador
     * @param newId     nuevo identificador a asignar
     * @param message   mensaje de excepción en caso de estar asignado
     */
    public static void requireIdNotSet(Object currentId, Object newId, String message) {
        if (currentId != null && !java.util.Objects.equals(currentId, newId)) {
            throw new BusinessRuleViolationException(message);
        }
    }

    /** Valida un texto obligatorio con longitud máxima. */
    public static void validateRequiredLength(String value, int maxLength, String message) {
        requireNotBlank(value, message);
        requireMaxLength(value, maxLength, message);
    }

    /** Valida nombres usados entre entidades. */
    public static void validateNombre(String nombre, int maxLength, String descriptor) {
        String msg = String.format(ValidationMessages.NAME_REQUIRED_MAX_LENGTH, descriptor, maxLength);
        validateRequiredLength(nombre, maxLength, msg);
        if (!TEXT_PATTERN.matcher(nombre).matches()) {
            throw new BusinessRuleViolationException(ValidationMessages.NAME_CHARS_ONLY);
        }
    }

    /** Valida el campo módulo de Estado. */
    public static void validateModulo(String modulo) {
        String msg = String.format(ValidationMessages.FIELD_REQUIRED_MAX_LENGTH,
                "El módulo", DbConstraints.LEN_MODULO);
        validateRequiredLength(modulo, DbConstraints.LEN_MODULO, msg);
        if (!TEXT_PATTERN.matcher(modulo).matches()) {
            throw new BusinessRuleViolationException(ValidationMessages.MODULE_CHARS_ONLY);
        }
    }
}