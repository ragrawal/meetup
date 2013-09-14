import os
import sys

for line in sys.stdin:
    filepath = os.environ["map_input_file"]
    
    if "data/movies/rating" in filepath:
        tokens = line.strip().split("\t")
        #print user|1   movie
        print "%s|1\t%s" % (tokens[0], tokens[1])
    elif "data/movies/user" in filepath:
        tokens = line.strip().split("|")
        #print user|0   gender
        print "%s|0\t%s" % (tokens[0], tokens[2])
        
