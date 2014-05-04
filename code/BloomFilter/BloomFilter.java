import java.io.BufferedWriter;
import java.io.IOException;
import java.util.BitSet;

public class BloomFilter {
	/*
	 * m = Number of Bits
	 * Bit
	 */
	private int m = 0;
	private BitSet container;
	
	/*
	 * k = Number of Hash Functions
	 */
	private int k;
	
	public BloomFilter(){
		//Default Parameters will have false positive rate of 1.0E-4 or (1 in 10,000) 
		//and is good for counting about 1M distinct values. 
		this(19170117, 13);
	}
	
	
	public BloomFilter(int bitSize, int numHash){
		this.m = bitSize;
		this.container = new BitSet(this.m);
		this.k = numHash;
	}
	
	public void add(Object obj){
		for(int idx: this.getBitIndexes(obj)){
			this.container.set(idx);
		}
	}
	
	
	
	
	public boolean contains(Object obj){
		for(int idx: this.getBitIndexes(obj)){
			if(this.container.get(idx) == false){
				return false;
			}
		}
		return true;
	}
	
	public  long getCount(){
		double numZeroBits = (double) this.m - this.container.cardinality();
		return (long) Math.round(Math.log(numZeroBits/this.m) / ((this.k * Math.log(1-1.0/this.m))));
	}
	
	public void merge(BloomFilter that) throws Exception{
		if(this.m != that.m){
			throw new Exception("Incompatible Bloom Filters. Bit size should be same");
		}
		if(this.k != that.k){
			throw new Exception("Incompatible Bloom Filters. Number of hash function should be same");
		}
		this.container.or(that.container);
	}
	
	
	private int[] getBitIndexes(Object obj){
		int[] indexes =  new int[this.k];
		for(int i=0; i<this.k; i++){
			indexes[i] =  Math.abs(MurmurHash.hash32(obj.toString() + new Integer(i).toString())) % this.m;
		}
		return indexes;
	}
	
	public byte[] getBytArray(){
		return this.container.toByteArray();
	}
	
	public void setContainer(byte[] input){
		this.container = BitSet.valueOf(input);
	}
	/*
	 * Source: Source: http://hur.st/bloomfilter?n=10000000&p=1.0E-6		
	 */
	public static int[] recommnededSize(long expectedItems, double expectedFP, int incrementBy){
		double n = new Long(expectedItems).doubleValue();
		int numOfBits = (int) Math.ceil((n * Math.log(expectedFP)) / Math.log(1.0 / (Math.pow(2.0, Math.log(2.0)))));
		int numOfHash = (int) Math.round(Math.log(2.0) * numOfBits/n);
		return new int[]{numOfBits, numOfHash};
	}
	
	public void fromString(String input){
		for(int i=0; i<this.m; i++){
			char c = input.charAt(i);
			if(c=='1'){ this.container.set(i);}			
		}		
	}
	
	public String toString(){
		StringBuffer output = new StringBuffer();
		for(int i=0; i<this.m; i++){
			boolean isSet = this.container.get(i);
			String text = (isSet ? "1" : "0");
			output.append(text);
		}		
		return output.toString();
	}
	
	

}
