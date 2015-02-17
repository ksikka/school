"""
@ksikka
11/27/14

To run code,

    `python boojum.py < input.txt`
"""


def run_em(f0, r, n, s, b):
    f_hat = f0
    for _ in xrange(r):
        y = [max(b_i, b_i * f_hat * s_i) for b_i, s_i in zip(b,s)]
        # print y
        f_hat = sum(y) / float(sum(s))
        # print f_hat

    return f_hat


if __name__ == "__main__":
    import sys

    f0 = None
    r = None
    n = None
    s = []
    b = []

    i=1
    for line in sys.stdin.readlines():
        if i == 1:
            f0 = float(line.strip())
        if i == 2:
            r = int(line.strip())
        if i == 3:
            n = int(line.strip())
        if i > 3 and i <= 3 + n:
            toks = line.strip().split()
            s_i = int(toks[0])
            b_i = int(toks[1])
            s.append(s_i)
            b.append(b_i)

        i += 1

    print run_em(f0, r, n, s, b)
