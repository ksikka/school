"""
Numerical Integration
of a system of PDEs.

@author ksikka

To test with different parameters, change the values in input.json.
"""
import math


class Problem4DiffEqSystem(object):
    def __init__(self, k, A_0, B_0, d_t, d_x, T, d, v):
        self.k = k
        self.A_0 = A_0
        self.B_0 = B_0
        self.d_t = d_t
        self.d_x = d_x
        self.T = T
        self.d = d
        self.v = v

        self.initialize_tables()

    def initialize_tables(self):
        # First index is the time, second is the space.
        self.A_table = []
        self.B_table = []
        self.C_table = []

        initial_values = [0 for i in xrange(int(math.ceil(2 / self.d_x)))]
        initial_values[0] = self.A_0
        self.A_table.append(initial_values)

        initial_values = [0 for i in xrange(int(math.ceil(2 / self.d_x)))]
        initial_values[-1] = self.B_0
        self.B_table.append(initial_values)

        initial_values = [0 for i in xrange(int(math.ceil(2 / self.d_x)))]
        self.C_table.append(initial_values)


    def _simulate_one_iteration_time_space(self, n, i):
        "Computes concentrations of A, B, C at timestep n and spatial index i"
        kAB = self.k * self.A_table[n-1][i] * self.B_table[n-1][i]
        x = i * self.d_x - 1 #shift a 0,2 range to -1,1

        # left boundary
        if i == 0:
            approx_da_dx = approx_db_dx = approx_dc_dx = 0
            # assumes delta x < .6666
            approx_da_dx2 = -7 * self.A_table[n-1][0] + 8 * self.A_table[n-1][1] - self.A_table[n-1][2]
            approx_db_dx2 = -7 * self.B_table[n-1][0] + 8 * self.B_table[n-1][1] - self.B_table[n-1][2]
            approx_dc_dx2 = -7 * self.C_table[n-1][0] + 8 * self.C_table[n-1][1] - self.C_table[n-1][2]

        # right boundary
        elif i == int(math.ceil(2 / self.d_x) - 1):
            approx_da_dx = approx_db_dx = approx_dc_dx = 0
            # assumes delta x < .6666
            approx_da_dx2 = -7 * self.A_table[n-1][i] + 8 * self.A_table[n-1][i-1] - self.A_table[n-1][i-2]
            approx_db_dx2 = -7 * self.B_table[n-1][i] + 8 * self.B_table[n-1][i-1] - self.B_table[n-1][i-2]
            approx_dc_dx2 = -7 * self.C_table[n-1][i] + 8 * self.C_table[n-1][i-1] - self.C_table[n-1][i-2]

        else:
            approx_da_dx = (self.A_table[n-1][i+1] - self.A_table[n-1][i-1]) / (2*self.d_x)
            approx_db_dx = (self.B_table[n-1][i+1] - self.B_table[n-1][i-1]) / (2*self.d_x)
            approx_dc_dx = (self.C_table[n-1][i+1] - self.C_table[n-1][i-1]) / (2*self.d_x)
            approx_da_dx2 = ((self.A_table[n-1][i+1] + self.A_table[n-1][i-1] - 2 * self.A_table[n-1][i])/(self.d_x**2))
            approx_db_dx2 = ((self.B_table[n-1][i+1] + self.B_table[n-1][i-1] - 2 * self.B_table[n-1][i])/(self.d_x**2))
            approx_dc_dx2 = ((self.C_table[n-1][i+1] + self.C_table[n-1][i-1] - 2 * self.C_table[n-1][i])/(self.d_x**2))

        A = self.A_table[n-1][i] + self.d_t * (
                    -1 * kAB
                  + self.d * approx_da_dx2
                  + self.v * x * approx_da_dx
                )
        B = self.B_table[n-1][i] + self.d_t * (
                    -1 * kAB
                  + self.d * approx_db_dx2
                  + self.v * x * approx_db_dx
                )
        C = self.C_table[n-1][i] + self.d_t * (
                         kAB
                  + self.d * approx_dc_dx2
                  + self.v * x * approx_dc_dx
                )

        return (A, B, C)

    def _simulate_one_iteration_time(self, n):
        "Simulate the nth iteration at timestep n"
        A_values = [0 for i in xrange(int(math.ceil(2 / self.d_x)))]
        B_values = [0 for i in xrange(int(math.ceil(2 / self.d_x)))]
        C_values = [0 for i in xrange(int(math.ceil(2 / self.d_x)))]

        for i in xrange(int(math.ceil(2 / self.d_x))):
            A_values[i], B_values[i], C_values[i] = self._simulate_one_iteration_time_space(n, i)

        return (A_values, B_values, C_values)

    def simulate(self):
        print "Time,[C]"
        print "%f\t%f" % (0.0, 0.0)
        for n in xrange(int(math.ceil(self.T / self.d_t))):
            As, Bs, Cs = self._simulate_one_iteration_time(n+1)
            self.A_table.append(As)
            self.B_table.append(Bs)
            self.C_table.append(Cs)

            print "%f\t%f" % ((n+1)*self.d_t, sum(Cs) / len(Cs))


if __name__ == "__main__":
    import json
    with open('input.json') as f:
        conf = json.load(f)

    p = Problem4DiffEqSystem(conf['k'], conf['A_0'], conf['B_0'],
                             conf['d_t'], conf['d_x'], conf['T'],
                             conf['d'], conf['v'])
    p.simulate()

