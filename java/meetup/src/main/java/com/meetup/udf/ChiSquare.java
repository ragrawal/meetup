package com.meetup.udf;

import org.apache.commons.math.stat.inference.ChiSquareTestImpl;
import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;

@Description(
		name = "ChiSquare Test",
		value = "_FUNC_(str) - Conducts chi square test for two category and returns significance level (pvalue)",
		extended = "Example:\n" +
		"  > SELECT ChiSquare(expected1, expected2, observed1, observed2 ) FROM test a;\n" +
		"  "
		)
public class ChiSquare extends UDF {
	
	public double evaluate(double e1, double e2, long o1, long o2) throws Exception {
		//sanity check
		if ((e1 + e2) != 1.0){
			throw new Exception("Expected values should sum exactly to 1.0");
		}
		
		long[] observed = new long[]{o1, o2};
		
		//calculate total size 
		long total_observed = o1 + o2;
		
		//calculate expected size
		double[] expected = new double[] { e1 * total_observed, e2 * total_observed };
		
		//conduct ChiSquare test
		ChiSquareTestImpl csi = new ChiSquareTestImpl();
		double pvalue = csi.chiSquareTest(expected, observed);
		
		//return pvalue upto 3 decimal places
		return (double)Math.round(pvalue * 1000)/1000;

	}
	

}
