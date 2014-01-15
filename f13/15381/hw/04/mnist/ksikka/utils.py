import os, math, sys, numpy, matplotlib.pyplot as plt
# Please do *not* add additional module imports beyond these.

# You should not need to modify any of the code in this file.
# You may wish to use show_img for debugging purposes, however.

def show_img(img, binarized=False):
    """ Displays a single image instance from mnist. """
    if binarized:
        arr = map(lambda x: int(x >= 128), img) * 255
    else:
        arr = img
    img_size = math.sqrt(len(arr))
    plt.imshow(arr.reshape((img_size, img_size)), cmap=plt.cm.gray, interpolation='nearest')
    plt.show()


def dataset_split(instances, labels, part1_percentage):
    """
    Partitions the dataset into two sub-datasets.
    @param instances: array of feature vectors for the dataset to split (numpy array).
    @param labels: array of labels for the dataset to split (numpy array).
    @param part1_percentage: The fraction of the dataset to include in the first part of the split.
    @return: tuple(part1_instances, part1_labels, part2_instances, part2_labels),
             where part1 contains about part1_percentage of the data, and part2 contains the remainder.
    """
    assert len(instances) == len(labels)
    part1_size = int(len(instances) * part1_percentage)
    perm = numpy.random.permutation(len(instances))
    part1_perm = perm[:part1_size]
    part2_perm = perm[part1_size:]
    assert len(part1_perm) + len(part2_perm) == len(instances)

    return (instances[part1_perm], labels[part1_perm],
            instances[part2_perm], labels[part2_perm])

def load_data(filename):
    arrs = numpy.load(filename)
    x_train = arrs['X'].astype(numpy.int32)
    y_train = arrs['Y'][:,0].astype(numpy.int32)
    x_test = arrs['Xtest'].astype(numpy.int32)
    y_test = arrs['Ytest'][:,0].astype(numpy.int32)
    assert(len(x_train) == len(y_train) and len(x_test) == len(y_test))
    return (x_train, y_train, x_test, y_test)

class ImageCollage(object):
    img = numpy.array([[]])
    max_width = 0
    unit_size = 0
    next_img_x = 0
    next_img_y = 0

    def __init__(self, unit_size, max_width):
        self.unit_size = unit_size
        self.max_width = max_width
        self.img = numpy.array([[]])
        self.next_img_x = 0
        self.next_img_y = 0

    def add_image(self, img):
        arr = numpy.reshape(numpy.array(img[0:self.unit_size * self.unit_size]),
                            (self.unit_size, self.unit_size))
        if (self.next_img_x + self.unit_size > self.img.shape[0] or
                        self.next_img_y + self.unit_size > self.img.shape[1]):
            new_height = max(self.img.shape[0], self.next_img_x + self.unit_size)
            new_width = max(self.img.shape[1], self.next_img_y + self.unit_size)
            new_img = numpy.zeros((new_height, new_width))
            new_img[0:self.img.shape[0], 0:self.img.shape[1]] = self.img
            self.img = new_img
        self.img[self.next_img_x:(self.next_img_x + self.unit_size),
        self.next_img_y:(self.next_img_y + self.unit_size)] = arr
        self.next_img_y = self.next_img_y + self.unit_size
        if (self.next_img_y >= self.max_width):
            self.next_img_y = 0
            self.next_img_x = self.next_img_x + self.unit_size

    def draw(self):
        fig = plt.figure()
        plt.imshow(self.img.copy(), cmap=plt.cm.gray, interpolation='nearest')
        plt.show()
