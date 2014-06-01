import math
import mmh3  #murmur hash function library

class BloomFilter(object):
    """Base Bloom Filter Class"""

    def __init__(self, m=None, k=None, n=None, fp=None):
        if not m == None and not k == None:
            self._k = k
            self._m = m
        elif not n == None and not fp == None:
            self._m, self._k = self._get_size(fp, n)
        else:
            raise Exception("Missing required parameters. Expecting either m and k or n and fp")

    def indexes(self, item):
        """Return Hash indexes for the given item"""
        values = []
        for i in range(self._k):
            itemStr = str(item) + str(i)
            value = mmh3.hash(itemStr) % self._m
            values.append(value)
        return values
        #return [int(mmh3.hash(str(item) + str(i)) 
        # % self._m) for i in range(self._k)]

    @property
    def count(self):
        #actual number of set bits
        t = float(self.set_bit_count)
        num = math.log(1 - t/self._m)
        deno = self._k * math.log(1 - 1.0/self._m)
        return round(num/deno)

    def _get_size(self, fp, n):
        """Returns bit size and number of hash functions to use for given n and fp"""

        m = int(math.ceil(-1 * (n * math.log(fp))/math.pow(math.log(2.0), 2.0)))
        k = int(math.ceil(m/n*math.log(2)))
        return [m, k]

    @property
    def container(self):
        return self._container

    @property
    def number_of_hashes(self):
        return self._k

    @property
    def bit_size(self):
        return self._m   

    @property
    def set_bit_count(self):
        pass     


class VectorBasedBloomFilter(BloomFilter):
    """Bloom Filter implementation where each bit is represented by vector index. Easier to understand what's going on but takes much more space"""

    def __init__(self, *args, **kwargs):
        super(VectorBasedBloomFilter, self).__init__(*args, **kwargs)
        self._container = [0] * self._m
        
    def add(self, item):
        for idx in self.indexes(item): 
            self._container[idx] = 1

    def contains(self, item):
        for idx in self.indexes(item): 
            if self._container[idx] == 0: 
                return  False
        return True

    def merge(self, other):
        if other == None: return
        
        if self.number_of_hashes != other.number_of_hashes:
            raise Exception("Number of hash function should be same in order to merge two bloom filters")
        if self.bit_size != other.bit_size:
            raise Exception("Bit size should be same in order to merge two bloom filters")

        for idx, value in enumerate(other.container):
            if value == 1:
                self._container[idx] = 1

    @property
    def set_bit_count(self):
        return sum(self._container)



class BitSetBasedBloomFilter(BloomFilter):
    """Bloom Filter implementation using Bitset -- much more space efficient as compared to VectorBasedBloomFilter"""

    def __init__(self, *args, **kwargs):
        super(BitSetBasedBloomFilter, self).__init__(*args, **kwargs)
        self._container = 0 << self._m+1
        

    def add(self, item):
        for idx in self.indexes(item): 
            self._container |= (1 << idx)

    def contains(self, item):
        for idx in self.indexes(item):
            if self._container & (1 << idx) == 0: return False
        return True

    def merge(self, other):
        if other == None: return
        
        if self.number_of_hashes != other.number_of_hashes:
            raise Exception("Number of hash function should be same in order to merge two bloom filters")
        if self.bit_size != other.bit_size:
            raise Exception("Bit size should be same in order to merge two bloom filters")

        self._container |= other.container


    @property
    def set_bit_count(self):
        return sum([1 for x in bin(self._container)[3:] if int(x)==1])


# class CountingBloomFilter(object):
#     def __init__(self, *args, **kwargs):
#         super(CountingBloomFilter, self).__init__(*args, **kwargs)

#         # build two dimensional structure for counting bloom filter
#         self._container = [[0] * self._m] * self._k   

#     def add(self, item):
#         for hashIdx, hashVal in enumerate(self.indexes(item)):
#             self._container[hashIdx][hashVal] += 1

#     def delete(self, item):
#         for hashIdx, hashVal in enumerate(self.indexes(item)):
#             if self._container[hashIdx][hashVal] > 0:
#                 self._container[hashIdx][hashVal] -= 1        

#     def item_count(self, item):
#         cnts = []
#         for hashIdx, hashVal in enumerate(self.indexes(item)):
#             cnts.append(self._container[hashIdx][hashVal])
#         return min(cnts)

#     @property
#     def count(self):





if __name__ == '__main__':
    bf1 = VectorBasedBloomFilter(fp=1E-4, n=10)
    bf1.add(2)
    bf1.add(6)
    bf1.add(3)
    bf1.add(2)
    print bf1.contains(3)
    print bf1.contains(10)
    print bf1.count

    # bf2 = VectorBasedBloomFilter(fp=1E-4, n=10)
    # bf2.add(5)
    # bf2.add(10)
    # bf2.add(2)
    # bf2.add(3)
    # print bf2.count

    # bf3 = VectorBasedBloomFilter(fp=1E-4, n=10)
    # bf3.merge(bf1)
    # bf3.merge(bf2)
    # print bf3.count

