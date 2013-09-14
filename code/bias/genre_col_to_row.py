#script name: genre_col_to_row.py
import sys
import os
 
#since the mapper doesn't have access to hive schema, 
#we need to tell the python code what are different genre columns are
col_to_genre = {6:"action", 7:"adventure", 8:"animation",
9:"children", 10:"comedy", 11:"crime", 12:"documentary",
13:"drama", 14:"fantasy", 15:"film_noir", 16:"horror",
17:"musical", 18:"mystery", 19:"romance", 20:"scifi",
21:"thriller", 22:"war", 23:"western"}
 
if __name__ == "__main__":
    for line in sys.stdin:
        #B default Hive will use tab as a delimiter for columns
        tokens = line.split("\t")
        for column in range(6,24):
            if 1 == int(tokens[column]):
                print "\t".join([tokens[0], col_to_genre[column]])

