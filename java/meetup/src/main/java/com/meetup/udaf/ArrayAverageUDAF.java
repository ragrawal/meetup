package com.meetup.udaf;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

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
            ArrayList<Double> total_value = new ArrayList<Double>();
            int cnt = 0;
            
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
            LOG.debug("======== init ========");
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
            LOG.debug("======== iterate ========");
            
            if(item == null) item = new Item();
            
            int inputLength = value.size();
            
            if(item.cnt == 0){
            	for(Double d: value){
            		item.total_value.add(d);
            	}
            }
            else{
            	for(int i=0; i<inputLength; i++){
            		Double d = item.total_value.get(i);
            		item.total_value.set(i, d + value.get(i));
            	}
            }
            item.cnt = item.cnt + 1;
            return true;
        }
         
        /**
         * function: terminate
         * this function is called after the last record of the group has been streamed
         * @return
         */
        public List<Double> terminate(){
            LOG.debug("======== terminate ========");
            return item.total_value;
        }
         
        /**
         * function: terminatePartial
         * this function is called on the mapper side and 
         * returns partially aggregated results. 
         * @return
         */
        public Item terminatePartial(){
            LOG.debug("======== terminatePartial ========");            
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
            LOG.debug("======== merge ========");           
            
            if(another == null || another.total_value.size() == 0)  return true;
            
            if(item.total_value.size() == 0){
            	item.total_value = another.total_value;
            	item.cnt = another.cnt;
            }
            else if(item.total_value.size() == another.total_value.size()){
            	for(int i=0; i<item.total_value.size(); i++){
            		Double d = item.total_value.get(i);
            		Double b = another.total_value.get(i);
            		item.total_value.set(i, d + b);
            	}
            	item.cnt += another.cnt;
            	
            }
            
            return true;
        }
    }
}