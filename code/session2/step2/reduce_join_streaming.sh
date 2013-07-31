#Use the following command to find location of streaming jar
# find /usr/ -name "*streaming*.jar"
streaming=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-1.2.0.1.3.0.0-107.jar

#Streaming jobs fails if output directory exists. 
#Hence remove them first
hadoop dfs -rmr data/frequency
hadoop dfs -rmr data/output

#
#STEP 1: Calculate frequency
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
#STEP 1: Join titles
#
hadoop \
jar $streaming \
-D mapred.map.tasks=2 \
-D mapred.reduce.tasks=2 \
-input data/frequency \
-input data/movies/item \
-output data/output \
-mapper "python reduce_join_mapper.py" \
-reducer "python reduce_join_reducer.py" \
-file code/session2/step2/reduce_join_mapper.py \
-file code/session2/step2/reduce_join_reducer.py

