"""
CTMM Simulator
@author ksikka

To test, feed input into STDIN like the following:
50 25 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
-5.0 1 3 1
1 -5 1 3
3 1 -5 1
1 3 1 -5

Or just run `python code.py < input.txt`

Note that the matrix row/col ordering is A,C,G,T

"""

import random
import pprint

A=0
C=1
G=2
T=3
M_to_int = {'A':A,'C':C,'G':G,'T':T}

class CTMM(object):
    def __init__(self, tmat):
        self.tmat = tmat
        self.kimura_plot = []

    def count_num_bases_of_each_type(self):
        self.k_A = sum([1 for b in self.cur_strand if b == 'A'])
        self.k_C = sum([1 for b in self.cur_strand if b == 'C'])
        self.k_G = sum([1 for b in self.cur_strand if b == 'G'])
        self.k_T = sum([1 for b in self.cur_strand if b == 'T'])

    def sample_time_to_next_mut(self):
        lamb  = (
                (self.k_A * (                  self.tmat[A][C] + self.tmat[A][G] + self.tmat[A][T]))+
                (self.k_C * (self.tmat[C][A] +                   self.tmat[C][G] + self.tmat[C][T]))+
                (self.k_G * (self.tmat[G][A] + self.tmat[G][C] +                   self.tmat[G][T]))+
                (self.k_T * (self.tmat[T][A] + self.tmat[T][C] + self.tmat[T][G]                  ))
                )
        return random.expovariate(lamb)

    def sample_which_base_mutated(self):
        """The Pr of which base mutates first, follows the discrete distribution of one lambda over sum of lambda.
        Each lambda represents the rate of the exponential which represents the dist of times til that base mutates."""
        lamb_map = {} # base => lamb
        lamb_map['A'] =                   self.tmat[A][C] + self.tmat[A][G] + self.tmat[A][T]
        lamb_map['C'] = self.tmat[C][A] +                   self.tmat[C][G] + self.tmat[C][T]
        lamb_map['G'] = self.tmat[G][A] + self.tmat[G][C] +                   self.tmat[G][T]
        lamb_map['T'] = self.tmat[T][A] + self.tmat[T][C] + self.tmat[T][G]

        sum_of_them = sum([ lamb_map[b] for b in self.cur_strand ])

        u = random.random()

        for i,b in enumerate(self.cur_strand):
            p = float(lamb_map[b]) / sum_of_them
            if u <= p:
                return i
            u = u - p

    def sample_what_it_mutates_into(self, M):
        "Given M \in {A,G,C,T}, returns N in {A,G,C,T} such that M mutates into N."
        M = M_to_int[M]

        # compact way of getting sum of lambdas where M != N
        sum_of_lambda = self.tmat[M][A] + self.tmat[M][C] + self.tmat[M][G] + self.tmat[M][T]\
                                                                            - self.tmat[M][M]

        u = random.random()
        if u <= float(self.tmat[M][A])/sum_of_lambda:
            return 'A'
        u = u - float(self.tmat[M][A])/sum_of_lambda
        if u <= float(self.tmat[M][C])/sum_of_lambda:
            return 'C'
        u = u - float(self.tmat[M][C])/sum_of_lambda
        if u <= float(self.tmat[M][G])/sum_of_lambda:
            return 'G'
        return 'T'

    def change_ith_base_to_N(self, i, N):
        new_strand = []
        for j, b in enumerate(self.cur_strand):
            if i == j:
                new_strand.append(N)
            else:
                new_strand.append(b)
        # makes sure exactly 1 character is changed
        assert (1 == sum([ 1 for b1, b2 in zip(self.cur_strand, new_strand) if b1 != b2 ]))
        return ''.join(new_strand)

    def simulate(self, start_strand, max_t):
        self.cur_t = 0.0
        self.cur_strand = start_strand
        self.count_num_bases_of_each_type()
        self.kimura_plot.append((self.cur_t, self.k_A, self.k_C, self.k_G, self.k_T))

        while True:
            t_next = self.sample_time_to_next_mut()

            if self.cur_t + t_next > max_t:
                break

            i = self.sample_which_base_mutated()
            M = self.cur_strand[i]
            N = self.sample_what_it_mutates_into(M)
            assert (M != N)

            self.cur_strand = self.change_ith_base_to_N(i, N)
            self.cur_t += t_next
            print self.cur_t, self.cur_strand

            self.count_num_bases_of_each_type()
            self.kimura_plot.append((self.cur_t, self.k_A, self.k_C, self.k_G, self.k_T))

def parse_matrix(lines):
    assert (len(lines) >= 4)
    rows = []
    for l in lines:
        tokens = l.split()
        assert (len(tokens) >= 4)

        row = []
        for i in xrange(4):
            try:
                row.append(int(tokens[i]))
            except ValueError, e:
                try:
                    row.append(float(tokens[i]))
                except ValueError, e:
                    print "Error parsing: " + repr(tokens[i])
                    raise e

        rows.append(row)
    return rows


if __name__ == "__main__":
    import sys
    lines = sys.stdin.readlines()

    tokens = lines[0].split()
    num_bases = int(tokens[0])
    max_t = float(tokens[1])
    start_strand = tokens[2]

    matrix = parse_matrix(lines[1:])

    assert (num_bases == len(start_strand))
    assert (max_t > 0)

    s = CTMM(matrix)
    s.simulate(start_strand, max_t)

    """ Outputs CSV for plotting in Excel
    for tup in s.kimura_plot:
        print ','.join([str(i) for i in tup])
    """


