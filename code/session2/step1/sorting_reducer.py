import sys
import os

for line in sys.stdin:
    freq, movie = line.strip().split("\t")
    print "%s\t%d" % (movie, int(freq))