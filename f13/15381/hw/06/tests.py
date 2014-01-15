#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# Created by Subhodeep Moitra (smoitra@cs.cmu.edu)

"""
tests.py : Do *not* modify this file.

You are required to make these test cases pass by implementing the weighted
majority algorithm for finding the Nash equilibrium mixed-strategy profile of a
zero-sum game.
"""

import random
import unittest
from operator import sub

from game import *

ALMOST_TOL = 0.05

matrices = {
    'rockSpock': [[0, -1, 1, 1, -1],
                  [1, 0, -1, -1, 1],
                  [-1, 1, 0, 1, -1],
                  [-1, 1, -1, 0, 1],
                  [1, -1, 1, -1, 0]],
    'small': [[1, -1],
              [-1, 1]],
    'nonsquare': [[30, -10, 20],
                  [10, 20, -20]]
}


class GameTestCase(unittest.TestCase):

    """ Defines all the test cases """

    def test_rockSpock(self):
        row_profile, col_profile, game_value = weighted_majority(matrices['rockSpock'])
        self.assertAlmostEqual(game_value, 0.0, delta=ALMOST_TOL)
        self.assertAlmostEqual(sum(map(abs, map(
                        sub, row_profile, [0.2]*5))), 0.0, delta=ALMOST_TOL)
        self.assertAlmostEqual(sum(map(abs, map(
                        sub, col_profile, [0.2]*5))), 0.0, delta=ALMOST_TOL)

    def test_small(self):
        row_profile, col_profile, game_value = weighted_majority(matrices['small'])
        self.assertAlmostEqual(game_value, 0.0, delta=ALMOST_TOL)
        self.assertAlmostEqual(sum(map(abs, map(
                        sub, row_profile, [0.5]*2))), 0.0, delta=ALMOST_TOL)
        self.assertAlmostEqual(sum(map(abs, map(
                        sub, col_profile, [0.5]*2))), 0.0, delta=ALMOST_TOL)

    def test_nonsquare(self):
        row_profile, col_profile, game_value = weighted_majority(matrices['nonsquare'])
        self.assertAlmostEqual(game_value, 20./7, delta=ALMOST_TOL)
        self.assertAlmostEqual(sum(map(abs, map(sub, row_profile, [
                            4./7, 3./7]))), 0.0, delta=ALMOST_TOL)
        self.assertAlmostEqual(sum(map(abs, map(sub, col_profile, [
                            0, 4./7, 3./7]))), 0.0, delta=ALMOST_TOL)


def create_suite(test_cases):
    """ Defines a suite of tests """
    game_test_suite = unittest.TestSuite()

    if 'all' in test_cases:
        for mat in matrices:
            game_test_suite.addTest(GameTestCase('test_'+mat))
    else:
        seen = set()
        for test_case in test_cases:
            if test_case not in matrices.keys()+['all']:
                raise ValueError('Unknown test: '+test_case)
            elif test_case not in seen:
                game_test_suite.addTest(GameTestCase('test_'+test_case))
                seen.add(test_case)

    return game_test_suite

if __name__ == '__main__':
    game_test_suite = create_suite(['test_rockSpock'])
    unittest.TextTestRunner(verbosity=2).run(game_test_suite)
