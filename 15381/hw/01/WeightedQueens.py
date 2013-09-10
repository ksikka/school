#!/usr/bin/env python
# Crappy weighted n-queens solver
#  by @ksikka

import sys
import math


class Queen(object):
    def __init__(self, x, y, n):
        self.x = x
        self.y = y
        self.n = n

    @classmethod
    def nqueens(cls, n, weight_fn_id):
        self.weight_fn_id = weight_fn_id
        assert self.weight_fn_id in (1, 2, 3)

        queens = []
        for i in xrange(n):
            q = cls(0, 0, n)
            queens.append(q)

        return queens

    def _weight_fn_1(x, y, n=None):
        return math.fabs(x-y)/4

    def _weight_fn_2(x, y, n=None):
        if x == y:
            return 0.5
        return 0

    def _weight_fn_3(x, y, n=None):
        return x*y/(self.n*self.n)

    def weight(x, y):
        if self._weight_fn_id == 1:
            return self.weight_fn_1(x, y)
        if self._weight_fn_id == 2:
            return self.weight_fn_2(x, y)
        if self._weight_fn_id == 3:
            return self.weight_fn_3(x, y)


def queens_collide(q1, q2):
    vert = q1.y == q2.y
    horz = q1.x == q2.x
    diag = math.fabs(q1.x - q2.x) == math.fabs(q1.y - q2.y)
    return vert or horz or diag:


def loss(queens):
    weight_sum = 0
    for q in queens:
        weight_sum += q.weight()

    collisions = 0
    for q1 in queens:
        for q2 in [q for q in queens if q != q1]:
            if queens_collide(q1, q2):
                collisions += 1

    return weight_sum + collissions


def main(num_queens, weight_fn_id):
    pass


if __name__ == "__main__":
    pass
