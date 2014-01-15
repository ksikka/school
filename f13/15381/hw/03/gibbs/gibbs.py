#!/usr/bin/env python

from collections import defaultdict
import itertools, random
from optparse import OptionParser, OptionValueError, BadOptionError
from pprint import pprint

class BayesNet(object):
    """ A BayesNet object contains four useful attributes characterizing the net:
          nodes: a list of the names of the nodes in the graph
          children: a dictionary mapping each node to a list of its children
          parents: a dictionary mapping each node to a list of its parents
          cpts: a dictionary mapping each node to its CPT. Each value is itself a
                dictionary, with each entry representing a row in the CPT: the
                key is a tuple of the values of the parents  (in the same order
                as in the parents dictionary), and the value is the probability
                of the variable being 1.

        It also has a filename attribute, which is the file from which it was loaded."""

    def __init__(self, filename=None, env={}):
        """ Args:
              filename: the name of a text file containing a Bayes net description.
                        If filename is None, an empty net is created.
              env: a dictionary specifying the values for any variables given in the
                   file."""

        nodes = []
        children = defaultdict(list)
        parents = defaultdict(list)
        cpts = defaultdict(dict)

        if filename is not None:
            lines = open(filename).readlines()
            if len(lines) % 2:
                raise Exception("File does not contain an even number of lines")

            for i in range(0, len(lines), 2):
                vs = lines[i].split()
                try:
                    ps = [eval(p, env) for p in lines[i+1].split()]
                except NameError, e:
                    name = e.message.split("'")[1]
                    raise NameError("Variable '%s' used in Bayes net file "
                                    "but not defined in env" % name)

                v = vs[0]
                pars = vs[1:]

                nodes.append(v)
                parents[v] = pars
                for p in pars:
                    children[p].append(v)

                for inds, p in zip(itertools.product(range(2), repeat=len(pars)), ps):
                    cpts[v][inds] = p

        self.filename = filename
        self.nodes = nodes
        self.children = dict(children)
        self.parents = dict(parents)
        self.cpts = dict(cpts)

""" Uncomment the lines below if you want to get a feel for what the net's
    attributes are. """

# net = BayesNet('small_graph.txt', env={'eps': .1})
# print 'nodes:', net.nodes
# print 'parents:', net.parents
# print 'children:', net.children
# print 'cpts:', net.cpts


def stop_after_n(n):
    """ Stopping criterion that stops the sampler after n iterations. """
    def should_stop(sampler):
        return sum(sampler.counts.values()) > n
    return should_stop

def stop_small_graph_almost_true(epsilon):
    """ Hacky stopping criterion to stop the sampler once the empirical probability
        of every outcome for the tiny Bayes net A->B is within 5% of the true
        probability."""
    def should_stop(sampler):
        expected_v1 = 0.5*(1-epsilon)
        expected_v2 = 0.5*(1-epsilon)
        expected_v3 = 0.5*epsilon
        expected_v4 = 0.5*epsilon
        cpt = sampler.get_estimated_cpt({"A":None, "B": None})
        v1 = cpt.get((0,0), 0)
        v2 = cpt.get((0,1), 0)
        v3 = cpt.get((1,0), 0)
        v4 = cpt.get((1,1), 0)
        def within_five(a,b):
            "True iff a is within 5% of b"
            import math
            return (math.fabs(a-b) / float(b)) <= 0.05
        return within_five(v1, expected_v1) and within_five(v2, expected_v2) and within_five(v3, expected_v3) and within_five(v4, expected_v4)
    return should_stop

class GibbsSampler(object):
    def __init__(self, net, stopping_criterion, evidence={}):
        """ Args:
              net: a BayesNet object.
              stopping_criterion: a function that takes the GibbsSampler as an
                                  argument and returns whether it should stop
                                  sampling.
              evidence: a dictionary mapping evidence variables to their observed
                        values. """
        self.net = net
        self.stopping_criterion = stopping_criterion
        self.evidence = evidence
        self.mutable_vars = [node for node in net.nodes if node not in evidence]
        self.vars_state = {}
        for node in self.mutable_vars:
            self.vars_state[node] = random.randrange(2)
        self.vars_state.update(evidence)
        self.counts = defaultdict(int)

        self._iterations = 0

    def get_parent_values(self, var_name):
        """ Returns a tuple of the current values of the specified node's parents. """
        return tuple(self.vars_state[parent]
                     for parent in self.net.parents[var_name])

    def get_child_values(self, var_name):
        """ Returns a tuple of the current values of the specified node's children. """
        return tuple(self.vars_state[child]
                     for child in self.net.children[var_name])

    def get_values(self):
        """ Returns a tuple of the values of all nodes, in the order in which
            they were introduced in the graph description. """
        return tuple(self.vars_state[n] for n in self.net.nodes)

    def update_var(self, var_name, value):
        """ Reassigns the variable var_name to value in the current variable
            assignment (self.vars_state). """
        self.vars_state[var_name] = value

    def record_sample(self):
        """ Records a sample in self.counts. """
        self.counts[self.get_values()] += 1
        self._iterations += 1

    def get_estimated_cpt(self, variables):
        """ Uses self.counts to compute a CPT for the variables specified.
            Args:
              variables: a dictionary mapping variables to the value they are to
                         be fixed at in the CPT. A value of None indicates that
                         both possible values for the variable should be included
                         in the CPT.
            Returns: a CPT in the same format as BayesNet.cpts. """

        # joint distribution table, which is a map from sample to probability
        jdt = {}
        for sample, count in self.counts.iteritems():
            jdt[sample] = float(count) / self._iterations

        def get_index_of_var(var_name):
            """ Given a var name, return its index in the sample vector """
            return self.net.nodes.index(var_name)

        def matches_query(sample, variables):
            """ True iff a sample matches the conditions required by the input variables """
            for var_name, expected_value in variables.iteritems():
                if expected_value is None:
                    continue
                idx = get_index_of_var(var_name)
                if sample[idx] != expected_value:
                    return False
            return True

        def get_new_key(sample, variables):
            """ Filter the sample tuple to only give the values required by the input variables """
            indexes_we_like = [get_index_of_var(v) for v in variables]
            filtered_tuple = (s_val for idx, s_val in enumerate(sample) if idx in indexes_we_like)
            return tuple(filtered_tuple)

        # first get all the samples in the joint distribution that match the query
        # then relabel the keys to match the query
        filtered_jdt = {}
        for sample, prob in jdt.iteritems():
            if matches_query(sample, variables):
                new_key = get_new_key(sample, variables)
                filtered_jdt[new_key] = prob

        return filtered_jdt


    def prob_true_given_mb(self, var_name):
        """ Gets the probability that var_name would be set to true given its markov blanket"""

        def get_mb_alpha_product(var_name):
            probability_given_parents = self.net.cpts[var_name].get(self.get_parent_values(var_name), None)
            children_product_prob = 1
            try:
                children_var_names = self.net.children[var_name]
            # I hope this means no children
            except KeyError:
                children_var_names = ()
            for child_var_name in children_var_names:
                pprob = self.net.cpts[child_var_name][self.get_parent_values(child_var_name)]
                children_product_prob *= pprob
            return probability_given_parents * children_product_prob

        old_value = self.vars_state[var_name]

        self.update_var(var_name, 1)
        c1 = get_mb_alpha_product(var_name)
        self.update_var(var_name, 0)
        c2 = get_mb_alpha_product(var_name)
        prob_var_name_true = c1 / (c1 + c2)

        self.vars_state[var_name] = old_value

        return prob_var_name_true

    def sample_var_given_mb(self, var_name):
        """ Samples a value for var_name at random, given its markov blanket """
        p = self.prob_true_given_mb(var_name)
        r = random.random()
        if r < p:
            new_value = 1
        else:
            new_value = 0

        self.update_var(var_name, new_value)

    def estimate_joint(self):
        """ Runs Gibbs sampling and populates self.counts with the observed
            variable values. """
        while not self.stopping_criterion(self):
            for var_name in self.mutable_vars:
                self.sample_var_given_mb(var_name)
                self.record_sample()


# Utility functions to help with parsing command line options

def str_to_binary_int(num_str):
    value = int(num_str)
    if value not in (0, 1):
        raise OptionValueError("Invalid variable value: " + num_str)
    return value

def var_list_to_dict(var_list, allow_undefined=True, conversion_fn=str_to_binary_int):
    variables = var_list.split(',')
    var_dict = {}

    for var in variables:
        if len(var) == 0:
            continue
        var_pieces = var.split('=')
        if len(var_pieces) > 2:
            raise OptionValueError("Invalid variable specification: '%s'" % var)
        var_name = var_pieces[0]
        if len(var_pieces) == 1:
            if not allow_undefined:
                raise OptionValueError("Variable %s must be assigned a value" % var_name)
            var_dict[var_name] = None
        else: # len == 2
            var_dict[var_name] = conversion_fn(var_pieces[1])

    return var_dict


def main():
    usage = "Usage: %prog [options] filename"
    parser = OptionParser(usage)
    parser.add_option("-q", "--query", dest="query", default="",
                      help="comma-separated list of variables to query (e.g., 'A,B=1,C'). " +
                           "If present, the program prints the queried CPT; otherwise it " +
                           "prints the full joint table.")
    parser.add_option("-e", "--evidence", dest="evidence", default="",
                      help="comma-separated list of evidence variables (e.g., 'A=0,B=1')")
    parser.add_option("-n", "--net-vars", dest="net_vars", default="",
                      help="comma-separated list of variable definitions to use when parsing " +
                           "the Bayes net (e.g., 'eps=0.1,alpha=0.3')")
    parser.add_option("-l", "--limit", dest="iter_limit", type="int", default=100000,
                      help="number of iterations to use as the stopping criterion")
    parser.add_option("-t", "--stop-small-true", dest="iter_limit", action="store_const", const=None,
                      help="sets the stopping criterion to be the hacky function that stops " +
                           "when the probability distribution is close to the true " +
                           "distribution for the small graph specified in the assignment")
    parser.add_option("-d", "--dummy", dest="dummy", action="store_true",
                      help="run a dummy joint estimation, producing random results, instead " +
                           "of actually doing Gibbs sampling")
    (options, args) = parser.parse_args()

    query_vars = var_list_to_dict(options.query)
    evidence_vars = var_list_to_dict(options.evidence, False)
    net_named_vars = var_list_to_dict(options.net_vars, False, float)

    if len(args) == 0:
        raise OptionValueError("Required positional argument for Bayes net filename not provided")
    elif len(args) > 1:
        raise BadOptionError("Too many positional arguments")
    filename = args[0]

    if options.iter_limit is not None:
        stopping_criterion = stop_after_n(options.iter_limit)
    else:
        stopping_criterion = stop_small_graph_almost_true(net_named_vars["eps"])

    net = BayesNet(filename, net_named_vars)
    sampler = GibbsSampler(net, stopping_criterion, evidence_vars)
    if options.dummy:
        for _ in range(10):
            values = tuple(random.randrange(2) for _ in range(len(sampler.net.nodes)))
            sampler.counts[values] += random.randrange(1000)
    else:
        sampler.estimate_joint()

    if len(query_vars) > 0:
        cpt = sampler.get_estimated_cpt(query_vars)
        row_format = "{:<2}" * len(query_vars) + " {:<8}"
        print row_format.format(*(query_vars.keys() +
                                  ["P(" + ','.join(query_vars.keys()) + ")"]))
        for values, prob in cpt.iteritems():
            print row_format.format(*(values + ("%.4f" % prob, "%.4f" % (1-prob))))
    else:
        total = float(sum(sampler.counts.values()))
        if total > 0:
            row_format = "{:<2}" * len(net.nodes) + " {:<8}"
            print row_format.format(*(net.nodes + ["P(" + ','.join(net.nodes) + ")"]))
            for values, count in sampler.counts.iteritems():
                print row_format.format(*(values + ('%.4f' % (count/total),)))

if __name__ == '__main__':
    main()
