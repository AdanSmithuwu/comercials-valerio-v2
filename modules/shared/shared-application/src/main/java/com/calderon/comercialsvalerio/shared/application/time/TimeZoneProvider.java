package com.calderon.comercialsvalerio.shared.application.time;

import com.calderon.comercialsvalerio.shared.application.config.ConfigUtils;
import com.calderon.comercialsvalerio.shared.domain.exception.ConfigException;

import java.time.DateTimeException;
import java.time.ZoneId;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Provee un {@link ZoneId} compartido para todos los módulos. */
public final class TimeZoneProvider {
    private static final Logger LOG = Logger.getLogger(TimeZoneProvider.class.getName());

    private static final Properties APP_PROPS = loadProps("application.properties");
    private static final Properties UI_PROPS = loadProps("ui.properties");

    private TimeZoneProvider() {
    }

    /** Devuelve el {@link ZoneId} configurado. */
    public static ZoneId zone() {
        return ZoneHolder.ZONE;
    }

    private static ZoneId load() {
        String tz = loadFrom(APP_PROPS);
        if (tz == null) {
            tz = loadFrom(UI_PROPS);
        }

        if (tz == null || tz.isBlank()) {
            return ZoneId.systemDefault();
        }
        try {
            return ZoneId.of(tz);
        } catch (DateTimeException ex) {
            LOG.log(Level.WARNING, "Invalid time zone: {0}", tz);
            return ZoneId.systemDefault();
        }
    }

    private static Properties loadProps(String res) {
        try {
            return ConfigUtils.loadOptional(res);
        } catch (ConfigException ex) {
            LOG.log(Level.WARNING, "Failed to load " + res, ex);
            return null;
        }
    }

    private static String loadFrom(Properties props) {
        if (props == null) {
            return null;
        }
        try {
            return ConfigUtils.get(props, "app.timezone");
        } catch (ConfigException ex) {
            LOG.log(Level.WARNING, ex.getMessage(), ex);
            return null;
        }
    }

    private static class ZoneHolder {
        static final ZoneId ZONE;

        static {
            ZONE = load();
        }
    }
}