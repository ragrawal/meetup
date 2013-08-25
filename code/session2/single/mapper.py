import sys
import os

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
# process each line of rating
# and generate count and id
#
for line in sys.stdin:
    tokens = line.strip().split("\t")
    movie = int(tokens[1])
    print "========="
    print line
    print tokens
    print "%d\t%s\t%d" % (movie, movies_titles[movie], 1)
    