import sys
import os

for line in sys.stdin:
    print "%s\t1" % (line.strip().split("\t")[2],)
    
    