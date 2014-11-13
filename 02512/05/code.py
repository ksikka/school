import math

k = 4
d_x = 0.2


class Problem4DiffEqSystem(object):
    def __init__(self, A_0, B_0, d_t, T, d, v):
        self.A_0 = A_0
        self.B_0 = B_0
        self.d_t = d_t
        self.T = T
        self.d = d
        self.v = v

        self.initialize_tables()

    def initialize_tables(self):
        # First index is the time, second is the space.
        self.A_table = []
        self.B_table = []
        self.C_table = []

        initial_values = [0 for i in xrange(math.ceil(2 / d_x))]
        initial_values[0] = self.A_0
        self.A_table.append(initial_values)

        initial_values = [0 for i in xrange(math.ceil(2 / d_x))]
        initial_values[-1] = self.B_0
        self.B_table.append(initial_values)

        initial_values = [0 for i in xrange(math.ceil(2 / d_x))]
        self.C_table.append(initial_values)

    def _simulate_one_iteration_time_space(self, n, i):
        kAB = k * self.A_table[n-1][i] * self.B_table[n-1][i]
        x = i * d_x - 1 #shift a 0,2 range to -1,1
        A = self.A_table[n-1][i] + d_t * (
                    -1 * kAB
                  + d * ((self.A_table[n-1][i+1] + self.A_table[n-1][i-1] - 2 * self.A_table[n-1][i])/(d_x^2))
                  + self.v * x * ((self.A_table[n-1][i+1] - self.A_table[n-1][i-1])/(2*d_x))
                )
        B = self.B_table[n-1][i] + d_t * (
                    -1 * kAB
                  + d * ((self.B_table[n-1][i+1] + self.B_table[n-1][i-1] - 2 * self.B_table[n-1][i])/(d_x^2))
                  + self.v * x * ((self.B_table[n-1][i+1] - self.B_table[n-1][i-1])/(2*d_x))
                )
        C = self.C_table[n-1][i] + d_t * (
                         kAB
                  + d * ((self.C_table[n-1][i+1] + self.C_table[n-1][i-1] - 2 * self.C_table[n-1][i])/(d_x^2))
                  + self.v * x * ((self.C_table[n-1][i+1] - self.C_table[n-1][i-1])/(2*d_x))
                )

        return (A, B, C)

    def _simulate_one_iteration_time(self, n):
        "Simulate the nth iteration at time n * delta_t"
        A_values = [0 for i in xrange(math.ceil(2 / d_x))]
        B_values = [0 for i in xrange(math.ceil(2 / d_x))]
        C_values = [0 for i in xrange(math.ceil(2 / d_x))]

        for i in xrange(math.ceil(2 / d_x)):
            ## TODO handle boundary conditions
            A_values[i], B_values[i], C_values[i] = self._simulate_one_iteration_time_space(n, i)

        return (A_values, B_values, C_values)

    def simulate():
        for n in xrange(math.ceil(T / self.d_t)):
            As, Bs, Cs = self._simulate_one_iteration_time(n)
            self.A_table.append(As)
            self.B_table.append(Bs)
            self.C_table.append(Cs)


if __name__ == "__main__":
    A_0 = 1
    B_0 = 1
    d_t = 0.01
    T = 10
    d = 1
    v = 0

    p = Problem4DiffEqSystem(A_0, B_0, d_t, T, d, v)
    p.simulate()

