import os
import sys

filepath = os.environ["map_input_file"].split('/')
#filename = os.path.split(filepath)[-1]

for line in sys.stdin:
    tokens = line.split("\t")
    
    if "rating" in filepath:
        #PRINT USER_ID  ITEM_ID
        print "%s|1\t%s" % (int(tokens[0]), int(tokens[1]))
    else if "user" in filepath:
        print "%s|0\t%s" % (int(tokens[0]), tokens[2].strip())
    
    
        
        
        
    
    
    
    