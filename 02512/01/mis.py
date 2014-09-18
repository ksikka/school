"""
Karan Sikka
andrew id = ksikka

Input: (via STDIN)
6
7
0 1
0 2
1 2
2 3
3 4
4 5
5 1

Output: (via STDOUT)
0 3 5

"""
import sys
sys.setrecursionlimit(1500)

pairs = []
all_drugs = set([])

def interact(d1, d2):
    return (d1,d2) in pairs or (d2,d1) in pairs

def getMaxIndSet(drugs):
    max_set = set([])
    if len(drugs) == 0:
        return set([])
    for d1 in drugs:
        drugs_which_interact_with_d1 = set([d2 for d2 in drugs if interact(d1, d2)])
        ind_set_with_d1    = set([d1]) | getMaxIndSet(drugs - set([d1]) - drugs_which_interact_with_d1)
        ind_set_without_d1 = getMaxIndSet(drugs - set([d1]))

        if len(ind_set_with_d1) > len(max_set):
            max_set = ind_set_with_d1

        if len(ind_set_without_d1) > len(max_set):
            max_set = ind_set_without_d1
    return max_set

def parseInput():
    global all_drugs
    global pairs
    lineno = 0
    while True:
        line = sys.stdin.readline()
        lineno += 1

        if lineno == 1:
            n = int(line)
            all_drugs = set(range(n))
            continue

        elif lineno == 2:
            num_pairs = int(line)
            continue

        elif lineno == num_pairs + 2:
            break

        else:
            pairs.append((int(line.split()[0]), int(line.split()[1])))

def main():
    parseInput()
    print ' '.join([str(i) for i in getMaxIndSet(all_drugs)])

main()

