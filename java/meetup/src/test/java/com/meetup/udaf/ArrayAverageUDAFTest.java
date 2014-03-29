package com.meetup.udaf;

import java.util.ArrayList;
import java.util.Random;

import org.apache.hadoop.hive.ql.metadata.HiveException;

import junit.framework.TestCase;

public class ArrayAverageUDAFTest extends TestCase {
	
	private ArrayList<ArrayList<Double>> getRows(){
		ArrayList<ArrayList<Double>> list = new ArrayList<ArrayList<Double>>();
		
		ArrayList<Double> d = new ArrayList<Double>();
		d.add(11.0);
		
		ArrayList<Double> e = new ArrayList<Double>();
		e.add(11.0);
		
		list.add(d);
		list.add(e);
		return list;
		
		
	}
	
	public void Reducer() throws HiveException{
		ArrayList<ArrayList<Double>> values = getRows();
		
		ArrayAverageUDAF.AverageUDAFEvaluator evaluator = new ArrayAverageUDAF.AverageUDAFEvaluator();
		for(ArrayList<Double> d: values){
			evaluator.iterate(d);
		}
		ArrayList<Double> result = (ArrayList<Double>) evaluator.terminate();
		//assertEquals(22.0, result.get(0));
	}
	
	public void testCombiner() throws HiveException{
		ArrayList<ArrayList<Double>> values = getRows();
		
		//initialize three separate evaluator
		int numMapper = 3;
		ArrayAverageUDAF.AverageUDAFEvaluator[] evaluator = new ArrayAverageUDAF.AverageUDAFEvaluator[3];
		for(int i=0; i< numMapper; i++){
			evaluator[i] = new ArrayAverageUDAF.AverageUDAFEvaluator();
		}
		
		//randomly send values to the three evaluator 
		Random indexGenerator = new Random();
		for(ArrayList<Double> d: values){
			int idx = indexGenerator.nextInt(numMapper);
			evaluator[idx].iterate(d);
		}
		
		//On the reducer side the three evaluator will be joined together
		//by calling terminatePartial and merge
		for(int i=1; i<numMapper; i++){
			evaluator[i].merge(evaluator[i-1].terminatePartial());
		}
		
		//finally grab the final result
		ArrayList<Double> result = (ArrayList<Double>) evaluator[numMapper-1].terminate();
		
		//assertEquals(22.0, result.get(0));
		 
	}
}
