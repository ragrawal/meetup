import os

class CountItems(object):

    def __init__(self):
        self._items = set()
        self._counter = 0

    def add(self, item):
        if not item in self._items:
            self._items.add(item) 

    def merge(self, other):
        if other == None: return
        self._items.update(other.items)

    @property
    def count(self):
        return len(self._items)

    @property
    def items(self):
        return self._items





if __name__ == '__main__':
    #Replicating single reducer logic
    ci = CountItems()
    for i in [1, 10, 11, 1]:
        ci.add(i)
    print ci.count

    #============================
    #Replicating multiple mapper single reducer logic
    #============================
    #Mapper 1
    ci1 = CountItems()
    for i in [1, 10, 11, 1]: ci1.add(i)

    #Mapper 2
    ci2 = CountItems()
    for i in [1, 11, 13, 14]: ci2.add(i)

    #Reducer -- combine all the mapper CountItems Object
    ci3 = CountItems()
    ci3.merge(ci1)
    ci3.merge(ci2)
    print ci3.count
    

