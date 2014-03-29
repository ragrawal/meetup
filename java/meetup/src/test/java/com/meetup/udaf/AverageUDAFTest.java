package com.meetup.udaf;

import org.apache.hadoop.hive.ql.metadata.HiveException;
import java.util.Random;

import junit.framework.TestCase;

public class AverageUDAFTest extends TestCase {
	
	public void testReducer() throws HiveException{
		double[] values = new double[]{100.0, 200.0, 300.0};
		AverageUDAF.AverageUDAFEvaluator evaluator = new AverageUDAF.AverageUDAFEvaluator();
		for(double d: values){
			evaluator.iterate(d);
		}
		double result = evaluator.terminate();
		assertEquals(200.0, result);
	}
	
	public void testCombiner() throws HiveException{
		double[] values = new double[]{100.0, 200.0, 300.0, 400.0, 500.0, 600.0, 700.0};
		
		//initialize three separate evaluator
		int numMapper = 3;
		AverageUDAF.AverageUDAFEvaluator[] evaluator = new AverageUDAF.AverageUDAFEvaluator[numMapper];
		for(int i=0; i< numMapper; i++){
			evaluator[i] = new AverageUDAF.AverageUDAFEvaluator();
		}
		
		//randomly send values to the three evaluator 
		Random indexGenerator = new Random();
		for(double d: values){
			int idx = indexGenerator.nextInt(numMapper);
			evaluator[idx].iterate(d);
		}
		
		//On the reducer side the three evaluator will be joined together
		//by calling terminatePartial and merge
		for(int i=1; i<numMapper; i++){
			evaluator[i].merge(evaluator[i-1].terminatePartial());
		}
		
		//finally grab the final result
		double result = evaluator[numMapper-1].terminate();
		
		assertEquals(400.0, result);
		 
	}

}
