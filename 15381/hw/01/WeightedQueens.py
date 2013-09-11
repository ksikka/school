#!/usr/bin/env python
# Crappy weighted n-queens solver
#  by @ksikka

import sys
import re
import math
import random

"""
Note: chessboard is 8x8, and positions are 0-indexed
"""

class Board(object):
    """
    Board.nqueens to get a board initialized with n queens

    then call:
        b.min_loss
        b.get_queen

    """
    def __init__(self, queens):
        self.queens = queens

    def get_queen(self, x, y):
        """
        Finds the queen or returns None.
        """
        possibilities = [q for q in self.queens if q.x == x and q.y == y]
        #assert len(possibilities) <= 1, "Found queens on top of each other at %r" % ((x, y),)
        if possibilities != []:
            return possibilities[0]

        return None

    @classmethod
    def nqueens(cls, n, weight_fn_id):
        queens = Queen.nqueens(n, weight_fn_id)
        b = cls(queens)
        return b

    def get_random_open_position(self):
        x, y = random.randint(0,7), random.randint(0,7)
        while self.get_queen(x, y) is not None:
            x, y = random.randint(0,7), random.randint(0,7)
        return (x, y)

    def randomly_arrange(self):
        for q in self.queens:
            q.x, q.y = self.get_random_open_position()

    def loss(self):
        queens = self.queens
        weight_sum = 0
        for q in queens:
            weight_sum += q.weight()

        collisions = 0
        for q1 in queens:
            for q2 in [q for q in queens if q != q1]:
                if queens_collide(q1, q2):
                    collisions += 1

        return weight_sum + collisions

    def moving_positions(self, q):
        positions = []
        for x in xrange(8):
            for y in xrange(8):
                q2 = Queen(x, y, 0, 1) # a hypothetical queen
                if not queens_collide(q, q2):
                    positions.append((x,y))
        return positions

    def minimize_loss(self):
        queens = self.queens
        while True:
            l = self.loss()
            if l == 0:
                break
            #print l
            for q in queens:
                # move q to a lower loss position
                oldx, oldy = q.x, q.y
                loss_position_pairs = [(l, (oldx, oldy))]
                for x, y in self.moving_positions(q):
                    q.x = x
                    q.y = y
                    l = self.loss()
                    loss_position_pairs.append((l, (x,y)))
                min_loss, pos = sorted(loss_position_pairs, key=lambda x: x[0])[0]
                q.x = pos[0]
                q.y = pos[1]


class Queen(object):
    """
    Use Queen.queens to get a list of queens.

    Then you can call
        .weight()

    to get a queen's weight.
    """

    def __init__(self, x, y, n, weight_fn_id):
        self.x = x
        self.y = y
        self.n = n
        self.weight_fn_id = weight_fn_id

    @classmethod
    def nqueens(cls, n, weight_fn_id):
        assert weight_fn_id in (1, 2, 3)

        queens = []
        for i in xrange(n):
            q = cls(0, 0, n, weight_fn_id)
            queens.append(q)

        return queens

    def _weight_fn_1(self, x, y):
        return math.fabs(x-y)/4

    def _weight_fn_2(self, x, y):
        if x == y:
            return 0.5
        return 0

    def _weight_fn_3(self, x, y):
        return x*y/(self.n*self.n)

    def weight(self):
        if self.weight_fn_id == 1:
            return self._weight_fn_1(self.x, self.y)
        if self.weight_fn_id == 2:
            return self._weight_fn_2(self.x, self.y)
        if self.weight_fn_id == 3:
            return self._weight_fn_3(self.x, self.y)


def queens_collide(q1, q2):
    vert = q1.y == q2.y
    horz = q1.x == q2.x
    diag = math.fabs(q1.x - q2.x) == math.fabs(q1.y - q2.y)
    return vert or horz or diag


def main(num_queens, weight_fn_id):
    b = Board.nqueens(num_queens, weight_fn_id)
    b.randomly_arrange()
    b.minimize_loss()
    for q in b.queens:
        print "(%d,%d)" % (q.x, q.y)
    return b



if __name__ == "__main__":
    arg_string = ' '.join(sys.argv[1:])
    m = re.search(r'^-N (\d+) -W (\d+)$', arg_string)
    n = int(m.group(1))
    w = int(m.group(2))
    print "N=%d" % n
    print "W=%d" % w
    main(n, w)
