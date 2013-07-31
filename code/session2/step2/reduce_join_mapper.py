import sys
import os

filepath = os.environ["map_input_file"]

for line in sys.stdin:
    if 'data/frequency' in filepath:
        movieid, frequency = line.strip().split("\t")
        print "\t".join([movieid, "frequency", frequency])
    else:
        tokens = line.strip().split('|')
        print "\t".join([tokens[0], "name", tokens[1]])
    
