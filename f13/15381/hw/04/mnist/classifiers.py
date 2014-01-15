import os, math, sys, numpy, matplotlib.pyplot as plt
from utils import *
# Please do *not* add additional module imports beyond these.

class Classifier(object):
    def train(self, instances, labels):
        """
        Train the classifier.
        @param instances: Array of feature vectors, a numpy array with shape
                          (number of instances, dimension of each instance).
        @param labels: Vector of training labels for instances, a numpy array with shape
                       (number of instances,).
        @return: None.
        """
        raise NotImplementedError

    def classify(self, instance):
        """
        Classify a new instance.
        @param instance: A feature vector, a numpy array of shape (dimension of instance,).
        @return: A number indicating the class of the instance.
        """
        raise NotImplementedError

    def test(self, test_instances, test_labels, draw=False, collage_width=20):
        """
        Tests a classifier against a dataset returns two objects an accuracy score and a collage.
        @param test_instances: Array of feature vectors to test, a numpy array with shape
                               (number of instances, dimension of each instance).
        @param test_labels: Vector of correct labels for test_instances to compare classifier results
                            against, a numpy array of shape (number of instances,).
        @param collage_width: Number of images to show in a row in the collage (int).
        @return: tuple of (accuracy as a float, ImageCollage of misclassified examples). You can
                 call draw() on the ImageCollage to display the collage.
        """

        ctr = 0
        success = 0
        # make a collage of failed images
        img_size = int(math.sqrt(len(test_instances[0])))
        collage = ImageCollage(img_size, img_size * collage_width)
        # iterate through each element in the test set and evaluate it
        # against the trained classifier
        for (test_instance, test_label) in zip(test_instances, test_labels):
            ctr += 1
            if ctr % collage_width == 0:
                sys.stdout.write('\r%d / %d' % (ctr, len(test_instances)))
                sys.stdout.flush()
            predicted_class = self.classify(test_instance)

            if predicted_class == test_label:
                success += 1
            elif draw:
                collage.add_image(test_instance)
        sys.stdout.write('\n')
        return (success / float(len(test_instances)), collage)


class KNNClassifier(Classifier):
    """ K-nearest neighbors classifier. """
    def __init__(self, k):
        self.k = k
        self.training_instances = []
        self.training_labels = []
        from collections import defaultdict
        import time
        self.defaultdict = defaultdict
        self.time = time

        self.memo_dict = {}

    def train(self, instances, labels):
        """ See Classifier.train. """
        # nearest_neighbor will use all the data as training
        self.training_instances = instances
        self.training_labels = labels

    def classify(self, instance):
        """ See Classifier.classify. """

        # Compute distances from instance to all training instances, sort, and take majority
        # vote from the top self.K training instances' labels. Break ties arbitrarily. You
        # may implement any kind of distance function (Manhattan/Euclidean/something cleverer).

        instance_dists = []
        for neighbor in self.training_instances:
            d = numpy.sum(numpy.square(neighbor-instance))
            instance_dists.append(d)

        ksmallest = sorted(enumerate(instance_dists), key=lambda x: x[1])[:self.k]

        label_votes = self.defaultdict(int)
        for i, dist in ksmallest:
            label_votes[self.training_labels[i]] += 1

        m = max(label_votes, key=lambda x: label_votes[x])
        return m

class LRClassifier(Classifier):
    """ Linear regression classifier. """
    def train(self, instances, labels):
        """ See Classifier.train. """

        class Regressor(object):
            """ Implements linear regression for multivariate linear system """
            def __init__(self):
                self.w0 = None
                self.wv = numpy.array([])

            def train(self, input_vects, targets):
                # insert ones in the first column to form matrix X
                X = numpy.insert(input_vects, 0, 1, axis=1)
                XT = numpy.transpose(X)

                # we will add a small lambda to the diagonal of XT*X in order to make it invertible
                l = .2
                lmat = numpy.dot(l, numpy.identity(len(XT)))

                xx = numpy.dot # for brevity
                i = numpy.linalg.inv(xx(XT, X) + lmat)
                weight_vect = xx(xx(i, XT), targets)
                self.w0, self.wv = weight_vect[0], weight_vect[1:]

            def estimate(self, input_vect):
                return self.w0 + numpy.dot(self.wv, input_vect)

        # create a linear regressor for each label
        regressors = []
        actual_labels = range(0,10)
        for lbl in actual_labels:
            targets = numpy.array([True if labels[i] == lbl else False for i in xrange(len(labels))])
            r = Regressor()
            r.train(instances, targets)
            regressors.append(r)

        self.labels = labels
        self.regressors = regressors

        self.actual_labels = actual_labels

    def classify(self, instance):
        """ See Classifier.classify. """

        # input the instance on each regressor, get out the label 1 or 0
        # take the argmax over the label, value of label's regressor pairs
        predicted_values = [r.estimate(instance) for r in self.regressors]
        index_of_label = numpy.argmax(predicted_values)
        return self.actual_labels[index_of_label]

class AlwaysZeroClassifier(Classifier):
    """ Always outputs Label as one """

    def train(self, instances, labels):
        """ Does Nothing """
        pass

    def classify(self, instance):
        """ Always returns zero class"""

        return 0

