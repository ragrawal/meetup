package com.meetup.udf;

import org.apache.commons.math.MathException;
import org.apache.commons.math.special.Erf;
import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;

@Description(
		name = "TwoProportionTest",
		value = "_FUNC_(str) - Conducts two proportion test and returns p value",
		extended = "Example:\n" +
		"  > SELECT toupper(p1, n1, p2, n2) FROM test a;\n" +
		"  "
		)
public class TwoProportionTest extends UDF {

	public double evaluate(double p1, int n1, double p2, int n2) throws MathException {
		double p = (p1 * n1 + p2 * n2)/(n1 + n2);
		double aZValue = (p1 - p2)/(Math.sqrt(p * (1-p) * (1.0/n1 + 1.0/n2)));
		
		aZValue = aZValue / Math.sqrt(2.0);
        return Erf.erf(aZValue);
           
		
	}
}
