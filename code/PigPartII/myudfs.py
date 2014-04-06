#Store this in a file called myudfs.py
import operator

def Mode(input):
    """Returns modal values and count"""

    keyCount = {}
    
    for idx, row in enumerate(input):
        key = row[0]
        keyCount[key] = keyCount.get(key, 0) + 1
    
    #Sort dictionary by value
    ordered = sorted(keyCount.iteritems(), key=operator.itemgetter(1), reverse=True)

    #extract keys with highest value
    max_val = ordered[0][1]
    mode_keys = [k for k,v in ordered if v == max_val]

    #Extract mode keys and count
    output = []
    for key, cnt in ordered:
        if cnt < max_val: break
        output.append(tuple([key, cnt]))

    return output

#Test the method:
if __name__ == "__main__":
    input = [tuple([10]),tuple([11]),tuple([10]),tuple([11]),tuple([12])]
    print Mode(input);