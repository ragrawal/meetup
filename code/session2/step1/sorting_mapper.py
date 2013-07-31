import sys
import os

for line in sys.stdin:
    movie, freq = line.strip().split("\t")
    print "%d\t%s" % (int(freq), movie)
    