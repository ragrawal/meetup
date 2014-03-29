package com.meetup.udaf;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDAF;
import org.apache.hadoop.hive.ql.exec.UDAFEvaluator;
import org.apache.hadoop.hive.ql.metadata.HiveException;


@Description(
		name = "Average",
		value = "_FUNC_(double) - Computes mean",
		extended = "select attr1, CustomAverage(value) from tbl group by attr1;"
)


public class AverageUDAF extends UDAF{
	
	static final Log LOG = LogFactory.getLog(AverageUDAF.class.getName());
	
	public static class AverageUDAFEvaluator implements UDAFEvaluator{

		/**
		 * Use item class to serialize intermediate computation
		 */
		public static class Item{
			double total_value = 0;
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
		public boolean iterate(double value) throws HiveException{
			LOG.debug("======== iterate ========");
			if(item == null)
				throw new HiveException("Item is not initialized");
			item.total_value = item.total_value + value;
			item.cnt = item.cnt + 1;
			return true;
		}
		
		/**
		 * function: terminate
		 * this function is called after the last record of the group has been streamed
		 * @return
		 */
		public double terminate(){
			LOG.debug("======== terminate ========");			 
			return item.total_value/item.cnt;
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
		 */
		public boolean merge(Item another){
			LOG.debug("======== merge ========");			
			if(another == null) return true;
			item.total_value += another.total_value;
			item.cnt += another.cnt;
			return true;
		}
		

	}

}
