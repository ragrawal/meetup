import random
import hashlib
import sys
import math

class MinHash(object):
    def __init__(self, k):
        if k < 1: 
            raise Exception("Invalid K: number of hash function can't be less than 1")
        self.k = k
        self.salts = [random.getrandbits(32) for i in range(self.k)]

    def similarity(self, A, B):
        sigA = self.__signatures(A)
        sigB = self.__signatures(B)
        return sum(map(lambda x: int(sigA[x] == sigB[x]), range(self.k)))/float(self.k)

    def __signatures(self, A):
        signature = []
        for salt in self.salts:
            sig = []
            for x in A:
                sig.append(self.__h(x, salt))
            signature.append(min(sig))
        return signature


    def __h(self, value, salt):
        m = hashlib.md5() #or hashlib.sha1()
        m.update(str(value))
        m.update(str(salt))
        return m.digest()


if __name__ == "__main__":
    A = [3,6,9]
    B = [2,4,6,8]
    for i in range(10, 1000):
        score = MinHash(i).similarity(A,B)
        if abs(score - 0.142) < 0.0001:
            print i, score
