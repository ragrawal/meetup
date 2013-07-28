#Use the following command to find location of streaming jar
# find /usr/ -name "*streaming*.jar"
streaming=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-1.2.0.1.3.0.0-107.jar

#Streaming jobs fails if output directory exists. 
#Hence remove them first
hadoop dfs -rmr data/movies/step1
hadoop dfs -rmr data/movies/step2

#
#1. MapReduce Job
#Mapper -- extract relevant information from rating and user table
#
hadoop \
jar $streaming \
-D mapred.map.tasks=2 \
-D mapred.reduce.tasks=2 \
-D mapred.output.compress=true \
-D stream.recordreader.compression=gzip \
-D mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec \
-D mapred.task.timeout=1800000 \
-input data/movies/rating \
-input data/movies/user \
-output data/movies/step1 \
-mapper "python step1_mapper.py" \
-reducer "python step1_reducer.py" \
-file code/session2/reducer_join/step1_mapper.py \
-file code/session2/reducer_join/step1_reducer.py 

#
# 2. Map Reduce
# Sorts tokens by gender and count 
# 

hadoop \
jar $streaming \
-D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
-D map.output.key.field.separator=. \
-D mapred.text.key.comparator.options=-k1,1nr \
-D mapred.map.tasks=10 \
-D mapred.reduce.tasks=1 \
-D mapred.output.compress=true \
-D stream.recordreader.compression=gzip \
-D mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec \
-D mapred.task.timeout=1800000 \
-input data/movies/step1 \
-output data/movies/step2 \
-mapper "python step2_mapper.py" \
-reducer "python step2_reducer.py" \
-file code/session2/reducer_join/step2_mapper.py \
-file code/session2/reducer_join/step2_reducer.py

