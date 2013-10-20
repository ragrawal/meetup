package com.meetup.udaf;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.hive.ql.exec.UDAF;
import org.apache.hadoop.hive.ql.exec.UDAFEvaluator;

public class MaxKeyByValue extends UDAF{
	
	static final Log LOG = LogFactory.getLog(MaxKeyByValue.class.getName());
	
	//Notes:
	//Make sure that you define the evaluator class as public
	
	public static class MaxKeyByValueEvaluator implements UDAFEvaluator{
		
		
		//Notes:
		//Make sure that you define inner class that is returned by terminatePartial function
		//to be static. 
		public static class Item{
			int key;
			long value;
			
			public void overwriteBy(Item another){
				this.key = another.key;
				this.value = another.value;
			}
		}

		private Item item;
		
		public MaxKeyByValueEvaluator(){
			super();
			init();
		}
		
		//Before sending records related to a new group
		//hive calls this method 
		public void init() {
			item = new Item();		
		}
		
		//Each record per group is passed 
		//through this function
		public boolean iterate(int key, long value){
			//if(key == null || value == null) return true;
			
			if(item.value < value){
				item.value = value;
				item.key = key;
			}
			
			return true;
		}
		
		//Once all the records related to a group are exhausted
		//hive calls this function
		public Integer terminate(){
			return item.key;			
		}
		
		//Below two are optimization functions 
		//that enables Hive to call the UDAF on map side 
		//and do partial aggregations of records. 
		public boolean merge(Item another){
			if(another == null) return true;
			if(another.value > item.value){
				item.overwriteBy(another);
			}
			else if (another.value == item.value && another.key > item.key ){
				item.overwriteBy(another);
			}
			return true;
			
		}
		
		public Item terminatePartial(){
			return item;
		}
		
	}

}
