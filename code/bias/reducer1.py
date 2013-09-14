import sys
import os

last_user = None
gender = None

for line in sys.stdin:
    key, value = line.strip().split("\t")
    user, record = key.strip().split("|")
    
    if user != last_user:
        if 0 == int(record):
            last_user = user
            gender = value.strip().upper()
        else:
            raise Exception("Missing gender information for user: {}".format(user))
            
    if 1 == int(record): 
        print "%s\t%s" % (value, gender)

        