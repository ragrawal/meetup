import sys
import os

last_movie = None
last_name = None

def output(frequency):
    if last_movie and last_name:
        print "\t".join([last_movie, last_name, frequency])

for line in sys.stdin:
    key, value = line.strip().split("\t")
    id, rtype = key.strip().split("|")
    rtype = int(rtype)
    
    if id != last_movie:
        last_movie = id
        last_name = None
    
    if rtype == 0: last_name = value.strip()
    else: output(value)
