package com.meetup.udaf;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDAF;
import org.apache.hadoop.hive.ql.exec.UDAFEvaluator;
import org.apache.hadoop.hive.ql.metadata.HiveException;

 
@Description(
        name = "Average",
        value = "_FUNC_(array<double>) - Computes mean",
        extended = "select attr1, CustomAverage(value) from tbl group by attr1;"
)

public class ArrayAverageUDAF extends UDAF{
    static final Log LOG = LogFactory.getLog(ArrayAverageUDAF.class.getName());
    
    public static class AverageUDAFEvaluator implements UDAFEvaluator{
    	
        /**
         * Use item class to serialize intermediate computation
         */
        public static class Item{
            ArrayList<Double> total_value = null;
            int rows = 0;
            
            //no argument constructor 
            //--required so that hive can serialize and deserialize item
            public Item() {}
            
            //constructor
            public void reset(int cols) {
            	total_value = new ArrayList<Double>(cols);
            	for(int i=0; i<cols; i++) {
            		total_value.add(0.0);
            	}
            	rows = 0;
            }
            
            //merge
            public void iterate(ArrayList<Double> value) {
            	sum(value);
            	rows++;
            }
            
            public void merge(Item another) {
            	sum(another.total_value);
            	rows += another.rows;
            }
            
            private void sum(ArrayList<Double> value) {
            	if(total_value == null) {
            		this.reset(value.size());
            	}
            	
            	int cols = this.total_value.size();
            	
            	if(value.size() != cols) {
            		throw new RuntimeException("Expecting array of size " + cols  + ", but found array of size: " + value.size());
            	}
            	
            	
            	for(int i=0; i<cols; i++){
            		double previous = total_value.get(i).doubleValue();
            		double delta = value.get(i).doubleValue();
            		total_value.set(i, previous+delta);            		
            	}
            }
            
        }
         
        private Item item = null;
         
        /**
         * function: Constructor
         */
        public AverageUDAFEvaluator(){
            super();
            init();
        }
         
        /**
         * function: init()
         * Its called before records pertaining to a new group are streamed
         */
        public void init() {
            item = new Item();          
        }
         
        /**
         * function: iterate
         * This function is called for every individual record of a group
         * @param value
         * @return
         * @throws HiveException 
         */
        public boolean iterate(ArrayList<Double> value) throws HiveException{
        	LOG.info("===== ITERATE =====");
        	LOG.info(ArrayUtils.toString(value));
        	if(item == null) {
        		item = new Item();
        	}        	
        	item.iterate(value);
        	LOG.info(ArrayUtils.toString(item.total_value));
        	return true;
        }
         
        /**
         * function: terminate
         * this function is called after the last record of the group has been streamed
         * @return
         */
        public List<Double> terminate(){
        	LOG.info("===== TERMINATE =====");        	
        	int cols = item.total_value.size();        	
            for (int i=0; i< cols; i++) {
            	item.total_value.set(i, item.total_value.get(i)/item.rows);
            }
        	LOG.info(ArrayUtils.toString(item.total_value));

            return item.total_value;
        }
         
        /**
         * function: terminatePartial
         * this function is called on the mapper side and 
         * returns partially aggregated results. 
         * @return
         */
        public Item terminatePartial(){                   
            return item;
        }
         
         
        /**
         * function: merge
         * This function is called two merge two partially aggregated results
         * @param another
         * @return
         * @throws HiveException 
         */
        public boolean merge(Item another) throws HiveException{
        	LOG.info("===== MERGE =====");
        	LOG.info(ArrayUtils.toString(item.total_value));
        	LOG.info(ArrayUtils.toString(item.rows));
        	LOG.info(ArrayUtils.toString(another.total_value));
        	LOG.info(ArrayUtils.toString(another.rows));
        	
        	if(another == null || another.total_value == null || another.total_value.size() == 0)  
        		return true;
        	
        	if(item == null || item.total_value == null) {
        		item = new Item()
        		
        	}
    		else {
    			item.merge(another); 			
    		}
        	LOG.info(ArrayUtils.toString(item.total_value));
        	LOG.info(ArrayUtils.toString(item.rows));
        	
        	
            return true;
        }
    }
}