package com.meetup.udf;

import org.apache.commons.math.MathException;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

public class ChiSquareTest extends TestCase{
	
    public void testApp() throws Exception
    {
        ChiSquare cs = new ChiSquare();
        System.out.println(cs.evaluate(0.72, 0.28, 2611, 995));
    }

}
