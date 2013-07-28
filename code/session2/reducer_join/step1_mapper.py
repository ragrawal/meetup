import os
import sys

filepath = os.environ["map_input_file"].split('/')
#filename = os.path.split(filepath)[-1]

for line in sys.stdin:
    if "rating" in filepath:
        #PRINT USER_ID  ITEM_ID
        tokens = line.split("\t")
        print "%d\tRATING\t%d" % (int(tokens[0]), int(tokens[1]))
    elif "user" in filepath:
        tokens = line.split("|")
        print "%d\tUSER\t%s" % (int(tokens[0]), tokens[2].strip())
    
    
        
        
        
    
    
    
    