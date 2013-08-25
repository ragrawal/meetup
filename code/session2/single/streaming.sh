#Use the following command to find location of streaming jar
# find /usr/ -name "*streaming*.jar"
streaming=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-1.2.0.1.3.0.0-107.jar

#Streaming jobs fails if output directory exists. 
#Hence remove them first
hadoop dfs -rmr data/output

#
#STEP 1: Use map-join to join title to movie id and 
# Calculate frequency
#
hadoop \
jar $streaming \
-files hdfs://sandbox:8020/user/hue/data/movies/item/u.item#movieinfo \
-D mapred.map.tasks=2 \
-D mapred.reduce.tasks=2 \
-input data/movies/rating \
-output data/output \
-mapper "python mapper.py" \
-combiner "python reducer.py" \
-reducer "python reducer.py" \
-file code/session2/single/mapper.py \
-file code/session2/single/reducer.py


