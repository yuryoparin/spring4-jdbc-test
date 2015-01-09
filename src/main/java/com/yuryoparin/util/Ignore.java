package com.yuryoparin.util;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.FIELD;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

/**
 * User: Yury Oparin
 * Date: 09/01/15
 * Time: 18:51
 */
@Target(FIELD)
@Retention(RUNTIME)
public @interface Ignore {
}
