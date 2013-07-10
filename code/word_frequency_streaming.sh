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
jar /usr/local/Cellar/hadoop/1.0.4/libexec/contrib/streaming/hadoop-streaming-1.0.4.jar \
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

hadoop jar /usr/local/Cellar/hadoop/1.0.4/libexec/contrib/streaming/hadoop-streaming-1.0.4.jar \
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

#-mapper org.apache.hadoop.mapred.lib.IdentityMapper \
#Reference: http://stackoverflow.com/questions/7576985/hadoop-streaming-example-failed-to-run-type-mismatch-in-key-from-map
#-reducer org.apache.hadoop.mapred.lib.IdentityReducer

