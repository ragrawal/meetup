#Store this in a file called myudfs.py
import operator
import org.apache.pig.data.DataType as DataType
import org.apache.pig.impl.logicalLayer.schema.SchemaUtil as SchemaUtil


@outputSchemaFunction("ModeSchema")
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


@schemaFunction("ModeSchema")
def ModeSchema(input):


    #The input schema is a bag of tuples. But the bag is passed as 
    # a tuple having only field -- bag 
    inputBag = input.getField(0)
    print "==== BAG: ", inputBag
    inputTuple = inputBag.schema.getField(0)
    print "==== Tuple: ", inputTuple
    field = inputTuple.schema.getField(0)
    print "==== Field: ", field
    

    outFields = [field.alias, 'cnt']
    outSchema = [field.type, DataType.LONG]

    return SchemaUtil.newBagSchema(outFields, outSchema);
    