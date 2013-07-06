hadoop \
jar /usr/local/Cellar/hadoop/1.0.4/libexec/contrib/streaming/hadoop-streaming-1.0.4.jar \
-input data/queries \
-output data/output \
-mapper "python word_frequency_mapper.py" \
-reducer "python word_frequency_reducer.py" \
-jobconf mapred.map.tasks=50 \
-jobconf mapred.reduce.tasks=50 \
-jobconf mapred.output.compress=true \
-jobconf stream.recordreader.compression=gzip \
-jobconf mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec \
-jobconf mapred.task.timeout=1800000 \
-file code/word_frequency_mapper.py \
-file code/word_frequency_reducer.py 
# -cacheArchive hdfs://hadoop.cluster:9000/user/easyhadoop/lib/easyhadoop.zip#easyhadoop