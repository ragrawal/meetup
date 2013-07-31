import sys
import os

last_movie = None
last_frequency = None
last_name = None

def output():
    if last_movie and last_name and last_frequency:
        print "\t".join([last_movie, last_name, str(last_frequency)])

for line in sys.stdin:
    id, rtype, value = line.strip().split("\t")
    
    if id != last_movie:
        output()
        last_movie = id
        last_frequency = None
        last_name = None
    
    if rtype == 'frequency':
        last_frequency = int(value)
    elif rtype == "name":
        last_name = value.strip()

output()
