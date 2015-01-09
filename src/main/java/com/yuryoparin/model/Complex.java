package com.yuryoparin.model;

import com.yuryoparin.util.Table;

/**
 * User: Yury Oparin
 * Date: 09/01/15
 * Time: 18:41
 */
@Table("complex")
public class Complex {
    private int real;
    private int imaginary;

    public Complex(int real, int imaginary) {
        this.real = real;
        this.imaginary = imaginary;
    }

    @Override
    public String toString() {
        return "Complex{" +
                "real=" + real +
                ", imaginary=" + imaginary +
                '}';
    }

    public int getReal() {
        return real;
    }

    public void setReal(int real) {
        this.real = real;
    }

    public int getImaginary() {
        return imaginary;
    }

    public void setImaginary(int imaginary) {
        this.imaginary = imaginary;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Complex complex = (Complex) o;

        return imaginary == complex.imaginary && real == complex.real;
    }

    @Override
    public int hashCode() {
        int result = real;
        result = 31 * result + imaginary;
        return result;
    }
}
