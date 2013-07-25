#Use the following command to find location of streaming jar
# find /usr/ -name "*streaming*.jar"
streaming=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-1.2.0.1.3.0.0-107.jar

#Streaming jobs fails if output directory exists. 
#Hence remove them first
hadoop dfs -rmr data/output
hadoop dfs -rmr data/frequency

#
#1. MapReduce Job
#Mapper -- splits queries into tokens and print token as key and value as 1
#Reducer -- aggregates keys and sum value
#
hadoop \
jar $streaming \
-D mapred.map.tasks=10 \
-D mapred.reduce.tasks=10 \
-D mapred.output.compress=true \
-D stream.recordreader.compression=gzip \
-D mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec \
-D mapred.task.timeout=1800000 \
-input data/queries \
-output data/output \
-mapper "python word_frequency_mapper.py" \
-reducer "python word_frequency_reducer.py" \
-file code/word_frequency_mapper.py \
-file code/word_frequency_reducer.py 
# -cacheArchive hdfs://hadoop.cluster:9000/user/easyhadoop/lib/easyhadoop.zip#easyhadoop

#
# 2. Map Reduce
# Sorts tokens by frequency in descending order. 
# 

hadoop jar $streaming \
-D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
-D map.output.key.field.separator=. \
-D mapred.text.key.comparator.options=-k1,1nr \
-D mapred.map.tasks=10 \
-D mapred.reduce.tasks=1 \
-D mapred.output.compress=true \
-D stream.recordreader.compression=gzip \
-D mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec \
-D mapred.task.timeout=1800000 \
-input data/output \
-output data/frequency \
-mapper "python Identity.py" \
-reducer "python Identity.py" \
-file code/Identity.py


#=================================================
#NOTES ABOUT OPTIONAL CONFIGURATION PARAMETERS
#=================================================

#-mapper org.apache.hadoop.mapred.lib.IdentityMapper \
#Reference: http://stackoverflow.com/questions/7576985/hadoop-streaming-example-failed-to-run-type-mismatch-in-key-from-map
#-reducer org.apache.hadoop.mapred.lib.IdentityReducer


#Using something else as key/value separator
#Reference: http://hadoop.apache.org/docs/stable/streaming.html (section: Customizing How Lines are Split into Key/Value Pairs)
#-D stream.map.output.field.separator=. \
#-D stream.num.map.output.key.fields=4 \
