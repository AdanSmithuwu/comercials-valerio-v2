package com.calderon.comercialsvalerio.shared.domain.exception;

/* Regla de negocio incumplida (invariante roto, transición ilegal…) */
public class BusinessRuleViolationException extends RuntimeException {
    public BusinessRuleViolationException(String mensaje) {
        super(mensaje);
    }

    public BusinessRuleViolationException(String mensaje, Throwable causa) {
        super(mensaje, causa);
    }
}