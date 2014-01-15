#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# Created by Subhodeep Moitra(smoitra@cs.cmu.edu)

"""
game.py: Implements a weighted-majority game solver.

You are required to make the test cases pass by implementing the weighted
majority algorithm for finding the Nash equilibrium mixed-strategy profile of a
zero-sum game.

You may add any functions you need in this file.

You may change the default values of the arguments to weighted_majority if you find
that there are better values for your implementation. The tester will use the default 
values specified here.

"""

import math



def weighted_majority(matrix, penalty_eps=0.15, stopping_eps=0.01):
    """
    Run weighted majority to find mixed strategies

    Args:
        matrix: payoff matrix, as a list of lists. Each element in matrix is a row of
                the payoff matrix. Values indicate the payoff for the Row player.
        penalty_eps: epsilon to use when downweighting bad strategies.
        stopping_eps: epsilon to use to determine when the algorithm has converged.

    Returns: A tuple (row_profile, col_profile, game_value). Each profile
        represents a mixed strategy as a list of probabilities, such that
        row_profile[i] represents the probability that Row player plays move i,
        and similarly for col_profile. game_value is the expected value for the
        Row player of the Nash equilibrium (i.e., the expected value if Row
        plays row_profile and Column plays col_profile).
    """

    num_rows = len(matrix)
    num_cols = len(matrix[0])

    weights = [1] * num_cols # weight vector

    # a map from row num to number of times that move was picked.
    row_move_counter = { i: 0 for i in xrange(num_rows) }

    def compute_row_profile():
        sum_counter = sum(row_move_counter.values())
        row_profile = [ float(row_move_counter[i]) / sum_counter for i in xrange(num_rows) ]
        return row_profile

    while True:
        # col profile based on weights
        sum_weights = sum(weights)
        col_profile = [ (w / float(sum_weights)) for w in weights ]

        # adversarial row pure strategy
        row_expected_values_of_moves = [ sum([ p * payoff for p, payoff in zip(row, col_profile)]) for row in matrix ]
        best_move_index, best_move_value = max(enumerate(row_expected_values_of_moves), key=lambda x: x[1])
        row_move_counter[best_move_index] += 1

        row_players_row = matrix[best_move_index]

        # compute losses to column player
        minM = min([min(row) for row in matrix])
        maxM = max([max(row) for row in matrix])
        col_losses = [ (loss - minM) / float(maxM - minM) for loss in row_players_row ]

        # update weights
        new_weights = [ w * (1 - (penalty_eps * l)) for w, l in zip(weights, col_losses) ]
        weights = new_weights

        # check terminating condition
        #                          ======  NOTE THIS IS NOT WORKING  ======
        sum_weights = sum(weights)
        col_profile = [ (w / float(sum_weights)) for w in weights ]
        row_profile = compute_row_profile()

        row_expected_gain = sum([ p * min(row) for p, row in zip(row_profile, matrix) ])
        col_expected_loss = sum([ p * max([matrix[i][j] for i in xrange(num_rows)]) for p, j in zip(col_profile, xrange(num_cols)) ])

        """
        print (row_expected_gain,col_expected_loss)
        if abs(row_expected_gain + col_expected_loss) < stopping_eps:
            break
        """
        #                                   ======  END NOTE  ======
        # TENTATIVE HACK:
        if sum(row_move_counter.values()) > 2000:
            break

    row_profile = compute_row_profile()
    sum_weights = sum(weights)
    col_profile = [ (w / float(sum_weights)) for w in weights ]
    game_value = sum([ row_profile[i] * matrix[i][j] * col_profile[j] for i in xrange(num_rows) for j in xrange(num_cols) ])

    return (row_profile, col_profile, game_value)

