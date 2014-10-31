"""
CTMM Simulator

To test, feed input into STDIN like the following:
50 25 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
-5 1 3 1
1 -5 1 3
3 1 -5 1
1 3 1 -5

Note that the matrix row/col ordering is A,C,G,T

"""

import random

A=0
C=1
G=2
T=3


class CTMM(object):
    def __init__(self, tmat):
        self.tmat = tmat

    def count_num_bases_of_each_type(self):
        self.k_A = sum([1 for b in self.cur_strand if b == 'A'])
        self.k_C = sum([1 for b in self.cur_strand if b == 'C'])
        self.k_G = sum([1 for b in self.cur_strand if b == 'G'])
        self.k_T = sum([1 for b in self.cur_strand if b == 'T'])

    def sample_time_to_next_mut(self):
        return random.expovariate(self.k_A * (self.tmat[A][A] + self.tmat[A][C] + self.tmat[A][G] + self.tmat[A][T])
                                + self.k_C * (self.tmat[C][A] + self.tmat[C][C] + self.tmat[C][G] + self.tmat[C][T])
                                + self.k_G * (self.tmat[G][A] + self.tmat[G][C] + self.tmat[G][G] + self.tmat[G][T])
                                + self.k_T * (self.tmat[T][A] + self.tmat[T][C] + self.tmat[T][G] + self.tmat[T][T]))

    def sample_whether_ACGT_mutated(self):
        """Follows the discrete distribution of one lambda over sum of lambda.
        Each lambda represents the rate of the exponential which represents the dist of times til that base mutates."""
        lambda_A = self.k_A * (self.tmat[A][A] + self.tmat[A][C] + self.tmat[A][G] + self.tmat[A][T])
        lambda_C = self.k_C * (self.tmat[C][A] + self.tmat[C][C] + self.tmat[C][G] + self.tmat[C][T])
        lambda_G = self.k_G * (self.tmat[G][A] + self.tmat[G][C] + self.tmat[G][G] + self.tmat[G][T])
        lambda_T = self.k_T * (self.tmat[T][A] + self.tmat[T][C] + self.tmat[T][G] + self.tmat[T][T])

        sum_of_them = lambda_A + lambda_C + lambda_G + lambda_T

        u = random.random()
        if u <= float(lambda_A) / sum_of_them:
            return 'A'

        u = u - float(lambda_A) / sum_of_them
        if u <= float(lambda_C) / sum_of_them:
            return 'C'

        u = u - float(lambda_C) / sum_of_them
        if u <= float(lambda_G) / sum_of_them:
            return 'G'

        return 'T'

    def sample_what_it_mutates_into(self, M):
        "Given M \in {A,G,C,T}, returns N in {A,G,C,T} such that M mutates into N."
        sum_of_lambda = self.tmat[M][A] + self.tmat[M][C] + self.tmat[M][G] + self.tmat[M][T]

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

    def sample_which_base_mutated(self, M):
        "Given M \in {A,G,C,T}, returns i from 0 to k_M - 1 where the ith nucleotide mutated."
        # equivalent to sampling a random variable.
        return random.choice([i for i,b in enumerate(self.cur_strand) if b == B])

    def change_ith_base_of_type_M(i, M, N):
        "Changes ith base of type M to base of type N"
        new_strand = []
        counter = 0 # counts the index of the base of type M
        for b in self.cur_strand:
            if b == M:
                if counter == i:
                    new_strand.append(N)
                else:
                    new_strand.append(M)
                counter += 1
            else:
                new_strand.append(M)
        return ''.join(new_strand)



    def simulate(self, start_strand, max_t):
        self.cur_t = 0.0
        self.cur_strand = start_strand

        while True:
            self.count_num_bases_of_each_type()
            t_next = sample_time_to_next_mut()

            if self.cur_t + t_next > max_t:
                break

            M = self.sample_whether_ACGT_mutated()
            N = self.sample_what_it_mutates_into(M)
            i = self.sample_which_base_mutated(M)

            self.cur_strand = self.change_ith_base_of_type_M(i, M, N)
            self.cur_t += t_next



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

    print matrix

