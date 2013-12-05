#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# Created by Subhodeep Moitra(smoitra@cs.cmu.edu)

"""
main.py : Do *not* modify this file.

You are required to make the test cases pass by implementing the weighted
majority algorithm for finding the Nash equilibrium mixed-strategy profile of a
zero-sum game.


main.py is the driver for the zero-sum game test cases.

To run all the test cases, run

    $ python main.py --test all

or simply

    $ python main.py

To see all the options available to you, run

    $ python main.py --help

"""
import unittest
import sys
import tests
import pprint
from optparse import OptionParser

def default(str):
    return str + ' [Default: %(default)s]'


def parse_args():
    """ Processes command line options """
    parser = OptionParser()
    # TODO : Add options
    parser.add_option('-l', '--list', dest='list', action='store_true',
                      help='Display the names of the available test matrices')
    parser.add_option('-v', '--view', dest='view', type=str, default=None,
                        help=default('View the payoff matrix'))
    parser.add_option('-t', '--test', dest='tests', type=str,
                        help=default('Run tests (can be comma-separated list). Options: all,' +
                                     ",".join(tests.matrices)), default='all')

    return parser.parse_args()


if __name__ == '__main__':
    (options, args) = parse_args()

    if options.list:
        print
        print("Available games are: ")
        print("\n".join(tests.matrices.keys()))
        sys.exit(0)

    if options.view:
        view = options.view
        print
        if view not in tests.matrices:
            raise ValueError(view+' not a valid test case')
        print "Matrix for game %s:" % view
        pprint.pprint(tests.matrices[view])
        sys.exit(0)

    suite = tests.create_suite(options.tests.split(','))
    unittest.TextTestRunner(verbosity=2).run(suite)
