import os
import sys

def normalize(inWord):
    return inWord.strip().lower()
    
if __name__ == "__main__":
    """Separate each search token in a search query
    and write it in a new line"""
    
    #process each input line
    for line in sys.stdin:
        #get tokens
        tokens = line.strip().split()
        #iterate over tokens
        for token in tokens:
            #normalize token
            token = normalize(token)
            print "%s\t%d" % (token, 1)
        
