#!/usr/bin/env python
from optparse import OptionParser, OptionValueError, BadOptionError

from classifiers import *
from utils import *


if __name__ == '__main__':
    usage = "Usage: %prog [options] filename"
    parser = OptionParser(usage)
    parser.add_option("-c", "--classifier", dest='classifier', type="choice", choices=["knn", "lr", "allzero"],
                      help="Type of classifier to use ('knn','lr','allzero'). Default: allzero.", default="allzero")
    parser.add_option("-k", "--k", dest="k", default=1, type="int",
                      help="Numbers of neighbors to try (ignored if not using kNN). Default: 1.")
    parser.add_option("-r", "--train", dest="training", default=1.0, type="float",
                      help="Fraction of training data to use, specified as a float. Default: 1.0.")
    parser.add_option("-e", "--test", dest="testing", default=1.0, type="float",
                      help="Fraction of testing data to use, specified as a float. Default: 1.0.")
    parser.add_option("-f", "--folds", dest="folds", default=1, type="int",
                      help="Number of folds to average results over. If not set, train and test are used as provided. "
                            "If set to anything other than 1, disables misclassified image collage. Default: 1.")
    parser.add_option("-d", "--draw", dest="draw", default=False, action="store_true",
                      help="Supply this option to display a collage of incorrectly-labeled images. Default: False.")

    (options, args) = parser.parse_args()
    if len(args) == 0:
        raise OptionValueError("Required positional argument for dataset file not provided")
    elif len(args) > 1:
        raise BadOptionError("Too many positional arguments")
    filename = args[0]

    if options.training < 0.0 or options.training > 1.0:
        raise BadOptionError("Invalid percentage of training data: %d" % options.training)

    if options.classifier == 'lr':
        algorithm = "linear regression"
        classifier = LRClassifier()
    elif options.classifier == 'knn':
        algorithm = "k-nearest neighbors (with k=%d)" % options.k
        classifier = KNNClassifier(options.k)
    else:
        algorithm = "always-zero"
        classifier = AlwaysZeroClassifier()

    print "Using %s for %d%% of training data and %d%% of test data" % (
        algorithm, int(options.training * 100), int(options.testing * 100))

    (x_train, y_train, x_test, y_test) = load_data(filename)
    (x_train, y_train, _, _) = dataset_split(x_train, y_train, options.training)
    (x_test, y_test, _, _) = dataset_split(x_test, y_test, options.testing)

    def run_fold(draw=True):
        classifier.train(x_train, y_train)
        (accuracy_train, _) = classifier.test(x_train, y_train, draw=False)
        (accuracy_test, missed_instances) = classifier.test(x_test, y_test, draw=draw)
        if draw:
            missed_instances.draw()
        return accuracy_train, accuracy_test

    if options.folds > 1:
        training_frac = len(y_train) / float(len(y_test) + len(y_train))
        x_combined = numpy.concatenate((x_train, x_test))
        y_combined = numpy.concatenate((y_train, y_test))
        train_accuracies = []
        test_accuracies = []
        for i in range(options.folds):
            print "Fold", i+1, "of", options.folds
            (x_train, y_train, x_test, y_test) = dataset_split(x_combined, y_combined, training_frac)
            accuracy_train, accuracy_test = run_fold(False)
            train_accuracies.append(accuracy_train)
            test_accuracies.append(accuracy_test)
        accuracy_train = numpy.mean(train_accuracies)
        accuracy_test = numpy.mean(test_accuracies)
        print "Using", options.folds, "folds"
        print "Average accuracy (train) =", accuracy_train
        print "Average accuracy (test)  =", accuracy_test
    else:
        accuracy_train, accuracy_test = run_fold(options.draw)
        print "Accuracy (train) =", accuracy_train
        print "Accuracy (test)  =", accuracy_test
