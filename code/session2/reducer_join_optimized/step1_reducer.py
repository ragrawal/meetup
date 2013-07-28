import os
import sys

last_user = None
last_gender = None

def output(value):
    if not last_user or not last_gender: return
    print "\t".join([value, last_user, last_gender])
    
for line in sys.stdin:
    key, value = line.strip().split("\t")
    userid, record = key.split("|")
    record = int(record)
    
    if userid != last_user:
        last_user = None
        last_gender = None        
    
    if record == 0:
        last_user = userid
        last_gender = value
    elif record == 1:
        output(value)

    