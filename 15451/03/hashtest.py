

"""


aaaaa
=> h


aaaab


"""







M = 6

x = 20 # alphabet size

# strings are going to represented as lists of ints, each int from 0 - (n-1)

class Table(object):
    def __init__(self, index):
        """
        This is going to be the index^{th} Table (from 0 to M^{x} - 1)
            It represents a base M number of x digits.
        """
        self.index = index
        self.digits = []
        lastmult = index
        for i in xrange(x):
            if lastmult == 0:
                self.digits.append(0)
            (mults, rem) = divmod(lastmult, M)
            self.digits.append(rem)
            lastmult = mults


    def __getitem__(self, key):
        """
            Gets the i^th digit 
        """
        return self.digits[key]



def h(T, string):
    s = 0
    for i in string:
        s += T[i]
        s %= M
    return s % M

from collections import Counter
dist1 = Counter()
dist2 = Counter()


for i in xrange(M^x):
    T = Table(i)
    hval =  h(T, [0,1,0,0,0,0,0,0,0,0])
    dist1[hval] += 1

for i in xrange(M^x):
    T = Table(i)
    hval =  h(T, [1,1,0,0,0,0,0,0,0,0])
    dist2[hval] += 1

print dist1
print dist2
