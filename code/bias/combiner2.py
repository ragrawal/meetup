import sys
import os

last_movie = None
gender_count = {'M':0, 'F':0}

for line in sys.stdin:
    key, value = line.strip().split("\t", 1)
    movie, record = key.strip().split("|")
    
    if movie != last_movie:
            if last_movie:
                for gender in gender_count:
                    print "{movie}|0\t{gender}\t{cnt}".format(
                        movie=last_movie,
                        gender=gender,
                        cnt=gender_count[gender]
                    )
            
            last_movie = movie
            gender_count = {'M': 0, 'F': 0}
    
    if 0 == int(record):
        gender, cnt = value.strip().split("\t")
        if not gender in ['M','F']: 
            raise Exception("Unknown gender type: {gender}".format(gender=gender))
        gender_count[gender] = gender_count[gender] + int(cnt)
        
    elif 1 == int(record): 
        print line.strip()
