#Use the following command to find location of streaming jar
# find /usr/ -name "*streaming*.jar"
streaming=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-1.2.0.1.3.0.0-107.jar

#Streaming jobs fails if output directory exists. 
#Hence remove them first
#hadoop dfs -rmr data/step1
#hadoop dfs -rmr data/step2
hadoop dfs -rmr data/output

# #
# #STEP 1: Calculate frequency
# #
# hadoop \
# jar $streaming \
# -D mapred.map.tasks=2 \
# -D mapred.reduce.tasks=2 \
# -D map.output.key.field.separator='|' \
# -D stream.num.map.output.key.fields=2 \
# -D mapred.text.key.partitioner.options="-k1,1" \
# -D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
# -D mapred.text.key.comparator.options="-k1,1 -k2n,2" \
# -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
# -input data/movies/rating \
# -input data/movies/user \
# -output data/step1 \
# -mapper "python mapper1.py" \
# -reducer "python reducer1.py" \
# -file code/bias/mapper1.py \
# -file code/bias/reducer1.py
# 
# #
# #STEP 2: Calculate Number of Male and Female raters per movie genre pair
# #
# hadoop \
# jar $streaming \
# -files hdfs://sandbox:8020/user/hue/data/movies/genre_mapping.tab#genre_mapping \
# -D mapred.map.tasks=2 \
# -D mapred.reduce.tasks=2 \
# -D map.output.key.field.separator='|' \
# -D stream.num.map.output.key.fields=2 \
# -D mapred.text.key.partitioner.options="-k1,1" \
# -D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
# -D mapred.text.key.comparator.options="-k1,1 -k2n,2" \
# -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
# -input data/step1 \
# -input data/movies/item \
# -output data/step2 \
# -mapper "python mapper2.py" \
# -combiner "python combiner2.py" \
# -reducer "python reducer2.py" \
# -file code/bias/mapper2.py \
# -file code/bias/combiner2.py \
# -file code/bias/reducer2.py

#
#STEP 3: Aggregate information at genre level
#
hadoop \
jar $streaming \
-files hdfs://sandbox:8020/user/hue/data/movies/genre_mapping.tab#genre_mapping \
-D mapred.map.tasks=2 \
-D mapred.reduce.tasks=2 \
-input data/step2 \
-output data/output \
-mapper "python mapper3.py" \
-combiner "python reducer3.py combiner" \
-reducer "python reducer3.py reducer" \
-file code/bias/mapper3.py \
-file code/bias/reducer3.py


