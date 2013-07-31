#Use the following command to find location of streaming jar
# find /usr/ -name "*streaming*.jar"
streaming=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-1.2.0.1.3.0.0-107.jar

#Streaming jobs fails if output directory exists. 
#Hence remove them first
hadoop dfs -rmr data/frequency
hadoop dfs -rmr data/sorted

#
#Stage 1: Frequency computation
#
hadoop \
jar $streaming \
-D mapred.map.tasks=2 \
-D mapred.reduce.tasks=2 \
-input data/movies/rating \
-output data/frequency \
-mapper "python simple_mapper.py" \
-combiner "python simple_reducer.py" \
-reducer "python simple_reducer.py" \
-file code/session2/step1/simple_mapper.py \
-file code/session2/step1/simple_reducer.py

#
# Stage 2: Sorting
#
hadoop \
jar $streaming \
-D mapred.map.tasks=2 \
-D mapred.reduce.tasks=1 \
-D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
-D map.output.key.field.separator=. \
-D mapred.text.key.comparator.options=-k1nr,1 \
-input data/frequency \
-output data/sorted \
-mapper "python sorting_mapper.py" \
-reducer "python sorting_reducer.py" \
-file code/session2/step1/sorting_mapper.py \
-file code/session2/step1/sorting_reducer.py