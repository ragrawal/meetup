import os
import sys

for line in sys.stdin:
    tokens = line.strip().split("\t")
    print "%s\t1" % (tokens[1])
    