import sys

lines = sys.stdin.readlines()[1:]

"1 1 1 1 0 0 1  0.0023"

summ=0
for l in lines:
    toks = l.split()
    summ += float(toks[4])

print summ

