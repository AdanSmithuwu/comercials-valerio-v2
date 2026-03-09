package com.calderon.comercialsvalerio.shared.domain.util;

import java.util.regex.Pattern;

public final class PhoneUtils {
    private static final Pattern NON_DIGITS = Pattern.compile("\\D+");

    private PhoneUtils() {}

    /**
     * Elimina todos los caracteres que no sean dígitos de la cadena dada.
     *
     * @param phone el número de teléfono de entrada, puede ser {@code null}
     * @return una cadena que contenga solo dígitos o {@code null} si la entrada era null
     */

    public static String stripToDigits(String phone) {
        if (phone == null) return null;
        return NON_DIGITS.matcher(phone).replaceAll("");
    }
}
