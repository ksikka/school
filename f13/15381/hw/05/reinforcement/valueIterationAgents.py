# valueIterationAgents.py
# -----------------------
# Licensing Information: Please do not distribute or publish solutions to this
# project. You are free to use and extend these projects for educational
# purposes. The Pacman AI projects were developed at UC Berkeley, primarily by
# John DeNero (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# For more info, see http://inst.eecs.berkeley.edu/~cs188/sp09/pacman.html

import mdp, util

from learningAgents import ValueEstimationAgent

class ValueIterationAgent(ValueEstimationAgent):
  """
      A ValueIterationAgent takes a Markov decision process
      (see mdp.py) on initialization and runs value iteration
      for a given number of iterations using the supplied
      discount factor.
  """
  def __init__(self, mdp, discount = 0.9, iterations = 100):
    """
      Your value iteration agent should take an mdp on
      construction, run the indicated number of iterations
      and then act according to the resulting policy.
    
      Some useful mdp methods you will use:
          mdp.getStates()
          mdp.getPossibleActions(state)
          mdp.getTransitionStatesAndProbs(state, action)
          mdp.getReward(state, action, nextState)
    """
    self.mdp = mdp
    self.discount = discount
    self.iterations = iterations
    self.values = util.Counter() # A Counter is a dict with default 0
     
    for i in xrange(self.iterations):
      self.run_value_iteration()

  def run_value_iteration(self):
      new_values = []
      states = self.mdp.getStates()
      for state in states:
          possibleActions = self.mdp.getPossibleActions(state)
          if len(possibleActions) != 0:
              new_values.append(max([self.getQValue(state, action) for action in possibleActions]))
          else:
              new_values.append(None)
      for state, new_value in zip(states, new_values):
          if new_value is not None:
              self.values[state] = new_value

  def getValue(self, state):
    """
      Return the value of the state (computed in __init__).
    """
    return self.values[state]


  def getQValue(self, state, action):
    """
      The q-value of the state action pair
      (after the indicated number of value iteration
      passes).  Note that value iteration does not
      necessarily create this quantity and you may have
      to derive it on the fly.
    """
    s_i = state
    a = action
    r = lambda x: self.mdp.getReward(s_i, a, x)
    return sum([ p * (r(s_j) + (self.discount * self.values[s_j])) for s_j, p in self.mdp.getTransitionStatesAndProbs(state, action) ])

  def getPolicy(self, state):
    """
      The policy is the best action in the given state
      according to the values computed by value iteration.
      You may break ties any way you see fit.  Note that if
      there are no legal actions, which is the case at the
      terminal state, you should return None.
    """

    if self.mdp.getPossibleActions(state) == [] or self.mdp.isTerminal(state):
        return None

    first = lambda x: x[0]
    argmax = lambda keys, values: max(zip(keys, values), key=first)[1]

    qvalues, actions = zip(* [ (self.getQValue(state, action), action) for action in self.mdp.getPossibleActions(state) ])

    return argmax(qvalues, actions)


  def getAction(self, state):
    "Returns the policy at the state (no exploration)."
    return self.getPolicy(state)
  
