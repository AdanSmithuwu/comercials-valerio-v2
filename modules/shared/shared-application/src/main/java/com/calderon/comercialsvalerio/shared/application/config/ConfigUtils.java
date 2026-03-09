package com.calderon.comercialsvalerio.shared.application.config;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Properties;

import com.calderon.comercialsvalerio.shared.domain.exception.ConfigException;

/** Utilidades para cargar archivos de configuración aplicando
 *  sobreescrituras por variables de entorno y propiedades del sistema. */
public final class ConfigUtils {
    private ConfigUtils() {}

    /** Carga propiedades desde el recurso indicado en el classpath. */
    public static Properties load(String resource) {
        try (InputStream in = ConfigUtils.class.getClassLoader()
                .getResourceAsStream(resource)) {
            if (in == null) {
                throw new ConfigException("No se encontró " + resource + " en el classpath");
            }
            Properties props = new Properties();
            try (InputStreamReader reader = new InputStreamReader(in, StandardCharsets.UTF_8)) {
                props.load(reader);
            }
            return props;
        } catch (IOException e) {
            throw new ConfigException("Error cargando " + resource, e);
        }
    }

    /**
     * Carga propiedades de forma opcional.
     * Retorna {@code null} si el recurso no existe.
     */
    public static Properties loadOptional(String resource) {
        InputStream in = null;
        ClassLoader ctx = Thread.currentThread().getContextClassLoader();
        if (ctx != null) {
            in = ctx.getResourceAsStream(resource);
        }
        if (in == null) {
            in = ConfigUtils.class.getClassLoader().getResourceAsStream(resource);
        }
        if (in == null) {
            return null;
        }
        try (InputStream autoClose = in;
             InputStreamReader reader = new InputStreamReader(autoClose, StandardCharsets.UTF_8)) {
            Properties props = new Properties();
            props.load(reader);
            return props;
        } catch (IOException e) {
            throw new ConfigException("Error cargando " + resource, e);
        }
    }

    /** Devuelve el valor configurado para la clave aplicando sobreescrituras. */
    public static String get(Properties props, String key) {
        return get(props, key, null);
    }

    /**
     * Devuelve el valor configurado para la clave aplicando sobreescrituras.
     * @param source fuente de configuración opcional usada en mensajes de error
     */
    public static String get(Properties props, String key, String source) {
        String envName = key.toUpperCase(Locale.ROOT).replace('.', '_');
        String env = System.getenv(envName);
        if (env != null && !env.isBlank()) {
            return env;
        }
        String sys = System.getProperty(key);
        if (sys != null && !sys.isBlank()) {
            return sys;
        }
        String val = props.getProperty(key);
        if (val == null) {
            String src = source == null ? "" : " en " + source;
            throw new ConfigException("Falta property `" + key + "`" + src);
        }
        return val;
    }
}