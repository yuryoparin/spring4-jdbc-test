package com.yuryoparin.util;

import org.apache.commons.codec.binary.Hex;
import org.postgresql.util.PGobject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.lang.reflect.Field;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

/**
 * User: Yury Oparin
 * Date: 09/01/15
 * Time: 18:49
 */
public final class PGobjectAdapter {
    private static final Logger logger = LoggerFactory.getLogger(PGobjectAdapter.class);
    private static final Set<Class> primitiveClasses = new HashSet<Class>(9);

    static {
        primitiveClasses.add(String.class);
        primitiveClasses.add(int.class);
        primitiveClasses.add(long.class);
        primitiveClasses.add(Timestamp.class);
        primitiveClasses.add(boolean.class);
    }

    public static PGobject getPGobject(Object model) {
        if (model == null)
            throw new NullPointerException("Model cannot be null");
        if (!model.getClass().isAnnotationPresent(Table.class))
            throw new IllegalArgumentException("Model must have @Table annotation, which points to its database table.");

        Table table = model.getClass().getAnnotation(Table.class);
        PGobject pgObject = new PGobject();
        pgObject.setType(table.value());

        StringBuilder sb = new StringBuilder("(");
        boolean first = true;
        for (Field field : model.getClass().getDeclaredFields()) {
            if (field.isAnnotationPresent(Ignore.class)) continue;

            try {
                if (!first) sb.append(","); else first = false;
                sb.append(fieldValue(field, model));
            } catch (IllegalAccessException e) {
                logger.error(e.getMessage(), e);
            }
        }

        try {
            pgObject.setValue(sb.append(")").toString());
        } catch (SQLException e) {
            logger.error(e.getMessage(), e);
        }

        return pgObject;
    }

    private static String fieldValue(Field field, Object object) throws IllegalAccessException {
        if (!field.isAnnotationPresent(Ignore.class)) {
            if (primitiveClasses.contains(field.getType())) {
                field.setAccessible(true);
                return object == null ? escape(null) : escape(field.get(object));
            }
            else if ((byte[].class).equals(field.getType())) {
                field.setAccessible(true);
                // handle the checksum field
                // TODO: check literal syntax
                if (object == null) return escape(null);

                byte[] bytes = (byte[]) field.get(object);
                return bytes == null ? escape(null) : "\"\\\\x" + Hex.encodeHexString(bytes) + "\"";
            }
            else {
                for (Field f : field.getType().getDeclaredFields()) {
                    if (f.isAnnotationPresent(Id.class) || "id".equals(f.getName())) {
                        field.setAccessible(true);
                        return fieldValue(f, field.get(object));
                    }
                }
            }
        }
        return null;
    }

    private static String escape(Object object) {
        if (object == null) return "";

        String result;
        Class type = object.getClass();

        if (String.class.equals(type)) {
            String val = (String) object;
            StringBuilder sb = new StringBuilder("\"");

            for (int i = 0; i < val.length(); i++) {
                char c = val.charAt(i);
                if (c == '\"' || c == '\\')
                    sb.append('\\');
                sb.append(c);
            }
            result = sb.append("\"").toString();
        }
        else {
            result = object.toString();
        }
        return result;
    }
}