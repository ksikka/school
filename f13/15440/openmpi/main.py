#!/usr/bin/env python
import sys
import random
import math

from mpi4py import MPI

comm = MPI.COMM_WORLD

size = comm.Get_size()
rank = comm.Get_rank()

usage = """
Usage:

  Data generator:

      mpirun -np 1 python $PWD/main.py gendata 2d 100000 input2d.txt
      mpirun -np 1 python $PWD/main.py gendata dna 100000 inputdna.txt

        ( the params are command, 2d vs dna, number of points, output data file )

  K-means Sequential (where k=6):

      mpirun -np 1 python $PWD/main.py kmseq 4 2d input2d.txt
      mpirun -np 1 python $PWD/main.py kmseq 4 dna inputdna.txt

        ( the params are command, k, 2d vs dna, input data file )

  K-means Parallel (where k=6):

      mpirun --hostfile hostfile.txt python $PWD/main.py kmpar 4 2d input2d.txt
      mpirun --hostfile hostfile.txt python $PWD/main.py kmpar 4 dna inputdna.txt

        ( the params are command, k, 2d vs dna, input data file )


"""

#VARIABLES
DNA_STRAND_LENGTH = 20
UPDATE_THRESHOLD = 0

def gensoftdata(typeofdata, numpoints):
    if typeofdata == '2d':
        lines = []
        for i in xrange(numpoints):
            x = 20 * random.random() - 10
            y = 20 * random.random() - 10
            lines.append((x,y))
        return lines

    elif typeofdata == 'dna':
        # DNA HAS A - 0, C - 1, G - 2, T - 3
        lines = []
        for i in xrange(numpoints):
            dna = []
            for j in xrange(DNA_STRAND_LENGTH):
                x = random.randint(0,3)
                dna.append(str(x))
            lines.append(''.join(dna))
        return lines

    else:
        print usage
        sys.exit(0)

def string_datapoint(typeofdata, data):
    if typeofdata == '2d':
        x, y = data
        return "%f %f" % (x,y)
    elif typeofdata == 'dna':
        return data

def gendata(typeofdata, numpoints, outputfile):
    lines = gensoftdata(typeofdata, numpoints)

    if typeofdata not in ['2d', 'dna']:
        print usage
        sys.exit(0)

    with open(outputfile, 'w') as f:
        for item in lines:
            f.write("%s\n" % string_datapoint(typeofdata, item))


def eucdist(p1, p2):
    x1, y1 = p1
    x2, y2 = p2
    return math.sqrt(math.pow(x1 - x2,2) + math.pow(y1 - y2,2))

def dnadist(s1, s2):
    count = 0
    for c1, c2 in zip(s1, s2):
        if c1 != c2:
            count+=1
    return count


def readData(problem, datafile):
    data = []
    if problem == '2d':
        with open(datafile) as f:
            lines = f.readlines()
            for line in lines:
                line = line.strip()
                x, y = line.split(' ')
                data.append((float(x), float(y)))
        return data

    elif problem == 'dna':
        with open(datafile) as f:
            lines = f.readlines()
            for line in lines:
                line = line.strip()
                if line != '':
                    data.append(line)
        return data

def chooseDistFn(problem):
    if problem == '2d':
        return eucdist
    elif problem == 'dna':
        return dnadist

def mean2d(points):
    sumx = 0
    sumy = 0
    for point in points:
         x, y = point
         sumx += x
         sumy += y
    mean = (sumx/len(points), sumy/len(points))
    return mean

def meandna(strands):
    # each strand is a string of 0-3
    # the mean is a dna strand with the minimum aggregate distance to all the other dna strands.
    # in other words, it has the maximum aggregate similarity to all the other dna strands

    # for each position, choose the most frequently occuring base in all the strands, break ties arbitrarily.

    def most_frequently_occuring_of(bases):
        base_freqs = [0, 0, 0, 0]
        for b in bases:
            base_freqs[int(b)] += 1
        potential_bases = [i for i, freq in enumerate(base_freqs) if freq == max(base_freqs)]
        return str(random.choice(potential_bases))

    mean_strand = [ most_frequently_occuring_of(bases) for bases in zip(*strands) ]

    return ''.join(mean_strand)

def chooseMeanFn(problem):
    if problem == '2d':
        return mean2d
    elif problem == 'dna':
        return meandna

def kmseq(k, problem, datafile):

    if problem not in ['2d', 'dna']:
        print usage
        sys.exit(0)

    distFunc = chooseDistFn(problem)
    meanFunc = chooseMeanFn(problem)
    data = readData(problem, datafile)

    currCentroids = gensoftdata(problem, k)

    isDone = False

    while (not isDone):

        ## ASSIGNMENT STEP: Assign points to cluster centroids ##
        # map from centroid of cluster to the list of data points in the cluster
        clusters = dict()
        for centroid in currCentroids:
            clusters[centroid] = []

        # for each point, add to the cluster of nearest centroid
        for point in data:
            # linear search the centroids for minimum dist to point
            closestCentroid = currCentroids[0]
            smallestDist = float("inf")
            for centroid in currCentroids:
                dist = distFunc(point, centroid)
                if(dist <= smallestDist):
                    closestCentroid = centroid
                    smallestDist = dist

            clusters[closestCentroid].append(point)


        ## UPDATE STEP: For each cluster update its centroid location to be the mean of its points. ##
        newCentroids = []
        centroidChangeIsSmall = True
        for centroid in currCentroids:
            cluster = clusters[centroid]

            if(not (len(cluster) == 0)):
                newcentroid = meanFunc(cluster)
                newCentroids.append(newcentroid)

                #this centroid is not accurate enough
                if(distFunc(newcentroid,centroid) > UPDATE_THRESHOLD):
                    centroidChangeIsSmall = False
            else:
                #move the centroids without a cluster
                newCentroids.append(gensoftdata(problem, 1)[0])
                centroidChangeIsSmall = False

        currCentroids = newCentroids
        if(centroidChangeIsSmall):
            isDone = True

    return clusters


def kmpar(k, problem, datafile):


    if problem not in ['2d', 'dna']:
        print usage
        sys.exit(0)

    distFunc = chooseDistFn(problem)
    meanFunc = chooseMeanFn(problem)

    if rank == 0:
        data = readData(problem, datafile)
        currCentroids = gensoftdata(problem, k)
    else:
        currCentroids = None

    isDone = False

    while (not isDone):

        currCentroids = comm.bcast(currCentroids, root=0)

        ## ASSIGNMENT STEP: Assign points to cluster centroids ##
        # map from centroid of cluster to the list of data points in the cluster

        my_clusters = dict()
        for centroid in currCentroids:
            my_clusters[centroid] = []

        # partition the data

        if rank == 0:
            partitions = [[] for i in xrange(size)]
            for i, datapoint in enumerate(data):
                partitions[ i % (len(partitions)) ].append(datapoint)
        else:
            partitions = None

        my_points = comm.scatter(partitions, root=0)

        # for each point in subdata, add to my cluster of nearest centroid

        for point in my_points:
            # linear search the centroids for minimum dist to point
            closestCentroid = currCentroids[0]
            smallestDist = float("inf")
            for centroid in currCentroids:
                dist = distFunc(point, centroid)
                if(dist <= smallestDist):
                    closestCentroid = centroid
                    smallestDist = dist

            my_clusters[closestCentroid].append(point)

        all_clusters = comm.gather(my_clusters, root=0)

        if rank == 0:
            # mash the results from all nodes into clusters dict
            clusters = dict()

            for centroid in currCentroids:
                clusters[centroid] = []

            for partial_result in all_clusters:
                for k, v in partial_result.iteritems():
                    clusters[k].extend(v)

        else:
            clusters = None

        ## UPDATE STEP: For each cluster update its centroid location to be the mean of its points. ##

        # partition the centroids among the nodes
        if rank == 0:
            clusters_partitions = [[] for i in xrange(size)]
            for i, centroid in enumerate(currCentroids):
                clusters_partitions[ i % (len(clusters_partitions)) ].append((centroid, clusters[centroid]))
        else:
            clusters_partitions = None

        myCentroidClusters = comm.scatter(clusters_partitions, root=0)

        # update centroids for a subset of original centroids
        new_my_centroids = []
        myCentroidChangeIsSmall = True

        for centroid, cluster in myCentroidClusters:

            if not len(cluster) == 0:
                # TODO meanFunc is parallelizable but i'm not sure if it's worth it.
                newcentroid = meanFunc(cluster)
                new_my_centroids.append(newcentroid)

                #this centroid is not accurate enough
                if(distFunc(newcentroid,centroid) > UPDATE_THRESHOLD):
                    myCentroidChangeIsSmall = False
            else:
                #move the centroids without a cluster
                new_my_centroids.append(gensoftdata(problem, 1)[0])
                myCentroidChangeIsSmall = False

        gathered = comm.gather(new_my_centroids) # COLLECT THE UPDATED CENTROIDS
        allCentroidChanges = comm.gather(myCentroidChangeIsSmall)
        if rank == 0:
            newCentroids = []
            for mini_centroids in gathered:
                newCentroids.extend(mini_centroids)
            currCentroids = newCentroids

            isDone = True
            for b in allCentroidChanges:
                if not b:
                    isDone = False
                    break
        else:
            isDone = None

        isDone = comm.bcast(isDone)

    if rank == 0:
        return clusters
    else:
        return None

def print_clusters(typeofdata, clusters):
    if clusters == None:
        pass

    for centroid, points in clusters:
        sys.stdout.write("CENTROID: %s\n" % string_datapoint(typeofdata, centroid))

        for p in points:
            sys.stdout.write("%s\n" % string_datapoint(typeofdata, p))

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print usage
        sys.exit(0)
    command = sys.argv[1]
    params = sys.argv[2:]

    if command == 'gendata':
        if len(sys.argv) < 5:
            print usage
            sys.exit(0)

        gendata(params[0], int(params[1]), params[2])


    elif command == 'kmseq':
        if len(sys.argv) < 5:
            print usage
            sys.exit(0)

        clusters = kmseq(int(params[0]), params[1], params[2])
        print_clusters(params[1], clusters)

    elif command == 'kmpar':
        if len(sys.argv) < 5:
            print usage
            sys.exit(0)

        clusters = kmpar(int(params[0]), params[1], params[2])
        print_clusters(params[1], clusters)

    MPI.Finalize()

