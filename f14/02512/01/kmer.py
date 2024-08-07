def kmer_help(s,k):
    return s[:k]

def kmer(s,k):
    mers = []
    for i in xrange(len(s)):
        if len(s[i:]) < k:
            break
        mers.append(kmer_help(s[i:], k))
    return mers

k = 4

kmers = set([])
repeated = set([])
kminusonemers = []
for s in "AATGTGCGCT CGTTGTAATGT GTACGTTG CGCTAATG".split():
    print ', '.join(kmer(s, k))
    print ', '.join(kmer(s, k - 1))

    for kmr in kmer(s, k):
        if kmr in kmers:
            repeated.add(kmr)
        else:
            kmers.add(kmr)
    kminusonemers.extend(kmer(s, k - 1))

kminusonemers = set(kminusonemers)

print "Nodes:"
print ', '.join(sorted(kminusonemers))

from collections import defaultdict

out_edges = defaultdict(list)# vertex -> list of out-edges
in_edges = defaultdict(list) # vertex -> list of in-edges

print "\nEdges:"
for kmer in sorted(kmers):
    prefix = kmer[:k - 1]
    suffix = kmer[1:]
    if prefix in kminusonemers and suffix in kminusonemers:
        out_edges[prefix].append(kmer)
        in_edges[suffix].append(kmer)
        print prefix+" -> "+suffix+" (" + kmer + ")"

print "Repeated Nodes:"
print ', '.join(sorted(repeated))

for v in sorted(kminusonemers):
    print "d(%s) = %d" % (v, len(out_edges[v]) + len(in_edges[v]))
