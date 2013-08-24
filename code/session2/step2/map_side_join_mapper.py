import os
import sys

movies_titles = {}

#
# Read movie titles and store 
# them in a dictionary
#
with open("movieinfo", 'r') as fp:
    for line in fp:
        tokens = line.strip().split('|')
        id = int(tokens[0])
        name = tokens[1].strip()
        movies_titles[id] = name

#
# process each line 
# and generate output
#
for line in sys.stdin:
    tokens = line.strip().split("\t")
    movie = int(tokens[0])
    freq = int(tokens[1])
    
    if not movie in movies_titles:
        raise Exception("Missing title for movie %d" % (movie))
    else:
        print "%d\t%s\t%d" % (movie, movies_titles[movie], freq)
    
        
    

        