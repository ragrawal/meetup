import os
import sys

last_token = None
last_frequency = 0
    
if __name__ == "__main__":
    """Aggregate token count. 
    Assumes 
        1. tokens are sorted
        2. first column contains search tokens and second column contains frequency
    """
    
    #iterate over input lines
    for line in sys.stdin:
        #get token and frequency
        token, freq = line.strip().split("\t",2)
        freq = int(freq)
        
        #if last token is not same as current token
        #then print its frequency and update last_token and last_frequency
        if token != last_token:
            
            if last_token: 
                print "%d\t%s" % (last_frequency, last_token)
            last_frequency = freq
            last_token = token
        #else increment frequency
        else:
            last_frequency = last_frequency + freq
