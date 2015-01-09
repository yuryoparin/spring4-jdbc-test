package com.yuryoparin.util;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.TYPE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

/**
 * User: Yury Oparin
 * Date: 09/01/15
 * Time: 18:42
 */
@Target(TYPE)
@Retention(RUNTIME)
public @interface Table {
    String value();
}