package com.yuryoparin.repository.jdbc;

import com.yuryoparin.model.Complex;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import static  org.testng.Assert.*;

/**
 * User: Yury Oparin
 * Date: 09/01/15
 * Time: 19:00
 */
@ContextConfiguration("classpath:context.xml")
@TransactionConfiguration(defaultRollback = false)
public class ComplexRepositoryTest extends AbstractTransactionalTestNGSpringContextTests {
    @Autowired
    private ComplexRepository complexRepository;

    private Complex[] numbers;

    @BeforeMethod
    public void setUp() throws Exception {
        numbers = new Complex[5];
        for (int i = 0; i < numbers.length; i++) {
            numbers[i] = new Complex(i, i);
        }
    }

    @Test
    public void testSummate() throws Exception {
        long result = complexRepository.summate(numbers);
        assertEquals(result, 10);

        result = complexRepository.summate(numbers);
        assertEquals(result, 10);
    }

    @AfterMethod
    public void tearDown() throws Exception {
        numbers = null;
    }
}
