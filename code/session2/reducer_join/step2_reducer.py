import os
import sys

last_gender = None
total_cnt = 0

for line in sys.stdin:
    gender, cnt = line.strip().split("\t")
    
    if gender != last_gender:
        if last_gender: 
            print "%s\t%d" % (last_gender, total_cnt)
        last_gender = gender
        total_cnt = 0
    
    total_cnt = total_cnt + int(cnt)

if last_gender: 
    print "%s\t%d" % (last_gender, total_cnt)
            
        