# search.py
# ---------
# Licensing Information: Please do not distribute or publish solutions to this
# project. You are free to use and extend these projects for educational
# purposes. The Pacman AI projects were developed at UC Berkeley, primarily by
# John DeNero (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# For more info, see http://inst.eecs.berkeley.edu/~cs188/sp09/pacman.html

"""
In search.py, you will implement generic search algorithms which are called
by Pacman agents (in searchAgents.py).
"""

import copy
import util

class SearchProblem:
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def getStartState(self):
      """
      Returns the start state for the search problem
      """
      util.raiseNotDefined()

    def isGoalState(self, state):
      """
      state: Search state

      Returns True if and only if the state is a valid goal state
      """
      util.raiseNotDefined()

    def getSuccessors(self, state):
      """
      state: Search state

      For a given state, this should return a list of triples,
      (successor, action, stepCost), where 'successor' is a
      successor to the current state, 'action' is the action
      required to get there, and 'stepCost' is the incremental
      cost of expanding to that successor
      """
      util.raiseNotDefined()

    def getCostOfActions(self, actions):
      """
      actions: A list of actions to take

      This method returns the total cost of a particular sequence of actions.  The sequence must
      be composed of legal moves
      """
      util.raiseNotDefined()


def tinyMazeSearch(problem):
    """
    Returns a sequence of moves that solves tinyMaze.  For any other
    maze, the sequence of moves will be incorrect, so only use this for tinyMaze
    """
    from game import Directions
    s = Directions.SOUTH
    w = Directions.WEST
    return  [s,s,w,s,w,w,s,w]

def depthFirstSearch(problem):
    """
    Search the deepest nodes in the search tree first [p 85].

    Your search algorithm needs to return a list of actions that reaches
    the goal.  Make sure to implement a graph search algorithm [Fig. 3.7].
    """

    visited = {} # map from dest state to src state
    fringe = util.Stack()
    # manage state as triples: position_State, action to get here, cost to get here
    curr_state, src_state = ((problem.getStartState(), None, None), (None, None, None))
    visited[curr_state] = src_state
    fringe.push((curr_state, src_state))

    while True:
        if fringe.isEmpty():
            raise Exception("Not found")
        (curr_state, src_state) = fringe.pop()
        if problem.isGoalState(curr_state[0]):
            break
        for neighbor_state in problem.getSuccessors(curr_state[0]):
            if neighbor_state not in visited:
                fringe.push((neighbor_state, curr_state))
                visited[neighbor_state] = curr_state

    # end condition: curr_state is goal state
    # go backwards from the end to get the path
    r_soln = []
    while curr_state[1] is not None:
        r_soln.append(curr_state[1])
        curr_state = visited[curr_state]
    r_soln.reverse()
    return r_soln



def breadthFirstSearch(problem):

    visited = {} # map from dest state to src state
    fringe = util.Queue()
    # manage state as triples: position_State, action to get here, cost to get here
    curr_state, src_state = ((problem.getStartState(), None, None), (None, None, None))
    visited[curr_state] = src_state
    fringe.push((curr_state, src_state))

    while True:
        if fringe.isEmpty():
            raise Exception("Not found")
        (curr_state, src_state) = fringe.pop()
        if problem.isGoalState(curr_state[0]):
            break
        for neighbor_state in problem.getSuccessors(curr_state[0]):
            if neighbor_state not in visited:
                fringe.push((neighbor_state, curr_state))
                visited[neighbor_state] = curr_state

    # end condition: curr_state is goal state
    # go backwards from the end to get the path
    r_soln = []
    while curr_state[1] is not None:
        r_soln.append(curr_state[1])
        curr_state = visited[curr_state]
    r_soln.reverse()
    return r_soln


def uniformCostSearch(problem):
    visited = {} # map from dest state to path

    def get_action_path(curr_state):
        r_soln = []
        cons_path = visited[curr_state]
        while cons_path[1] is not None:
            fringe_item = cons_path[0]
            if fringe_item[1] is not None:
                r_soln.append(fringe_item[1])
            cons_path = cons_path[1]
        r_soln.reverse()
        return r_soln

    def cost_fn(state):
        actions = get_action_path(state)
        cost = problem.getCostOfActions(actions)
        return cost

    fringe = util.PriorityQueueWithFunction(cost_fn)
    # manage state as triples: position_State, action to get here, cost to get here
    curr_state, src_state = ((problem.getStartState(), None, None), (None, None, None))
    visited[curr_state] = (curr_state, None)
    fringe.push(curr_state)

    while True:
        if fringe.isEmpty():
            raise Exception("Not found")
        curr_state = fringe.pop()
        if problem.isGoalState(curr_state[0]):
            break
        for neighbor_state in problem.getSuccessors(curr_state[0]):
            if neighbor_state not in visited:
                visited[neighbor_state] = (curr_state, visited[curr_state])
                fringe.push(neighbor_state)
            else:
                old_cost = cost_fn(neighbor_state)
                this_cost = problem.getCostOfActions( get_action_path(curr_state) + [neighbor_state[1]] )
                if this_cost < old_cost:
                    print "damson"

    # end condition: curr_state is goal state
    actions = get_action_path(curr_state)
    return actions

def nullHeuristic(state, problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0

def aStarSearch(problem, heuristic=nullHeuristic):
    "Search the node that has the lowest combined cost and heuristic first."
    visited = {} # map from dest state to src state

    def get_action_path(curr_state):
        # go backwards from the end to get the path
        r_soln = []
        while curr_state[1] is not None:
            r_soln.append(curr_state[1])
            curr_state = visited[curr_state]
        r_soln.reverse()
        return r_soln

    def cost_fn(fringe_item):
        state = fringe_item
        actions = get_action_path(state)
        cost = problem.getCostOfActions(actions)
        h = heuristic(state[0], problem=problem)
        return cost + h

    fringe = util.PriorityQueueWithFunction(cost_fn)
    # manage state as triples: position_State, action to get here, cost to get here
    curr_state, src_state = ((problem.getStartState(), None, None), (None, None, None))
    visited[curr_state] = src_state
    fringe.push(curr_state)

    while True:
        if fringe.isEmpty():
            raise Exception("Not found")
        curr_state = fringe.pop()
        if problem.isGoalState(curr_state[0]):
            break
        for neighbor_state in problem.getSuccessors(curr_state[0]):
            if neighbor_state not in visited:
                visited[neighbor_state] = curr_state
                fringe.push(neighbor_state)

    # end condition: curr_state is goal state
    actions = get_action_path(curr_state)
    return actions


# Abbreviations
bfs = breadthFirstSearch
dfs = depthFirstSearch
astar = aStarSearch
ucs = uniformCostSearch
