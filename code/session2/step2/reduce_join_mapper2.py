import sys
import os

filepath = os.environ["map_input_file"]

for line in sys.stdin:
    if 'data/frequency' in filepath:
        movieid, frequency = line.strip().split("\t")
        print "%s|1\t%s" % (movieid, frequency)
    else:
        tokens = line.strip().split('|')
        print "%s|0\t%s" % (tokens[0], tokens[1])
    
