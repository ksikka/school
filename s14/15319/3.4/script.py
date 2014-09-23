#!/usr/bin/env python
"""
@ksikka

Set these environment variables:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

"""

import os
import sys

if not os.environ.get('AWS_ACCESS_KEY_ID', ''):
  print "Missing environment var "
  sys.exit(1)
elif not os.environ.get('AWS_SECRET_ACCESS_KEY', ''):
  print "Missing environment var"
  sys.exit(1)


import boto
from boto.dynamodb2.table import Table
if boto.__version__ != '2.27.0':
  print "Detected boto version %s. Please use version 2.27.0 instead." % boto.__version__
  sys.exit(1)

db = Table('Proj34')

# Configuration
DATA_PATH = "/home/ubuntu/caltech-256.csv"
FRESH_START = True
R_THRPT = 50
W_THRPT = 50


from itertools import islice, chain
# Batch code source: http://code.activestate.com/recipes/303279-getting-items-in-batches/
def batch(iterable, size):
    sourceiter = iter(iterable)
    while True:
        batchiter = islice(sourceiter, size)
        yield chain([batchiter.next()], batchiter)


data = []
print "Reading data"
## READ DATA
with open(DATA_PATH) as f:
  for line in f.readlines()[1:]:
    line = line.strip()
    category, picture, s3url = line.split(',')
    picture = int(picture)
    data.append((category, picture, s3url))

  print "Done"

if FRESH_START:
  print "Starting afresh, this will delete stale items, you sure? Type 'yes' to continue:"
  conf = raw_input()
  if conf != 'yes':
    print "OK, skipping"
    FRESH_START = False

if FRESH_START:
  for bi, data_batch in enumerate(batch(data, R_THRPT)):
    with db.batch_write() as batch:
      print "Start batch %d" % bi
      for category, picture, s3url in data_batch:
        batch.delete_item(Category=category, Picture=picture)
        #print "Deleting old item %s:%s" % (category, picture)

  print "Done"

print "Storing %d items in the Table. Are you sure? Type 'yes' to continue:" % len(data)
conf = raw_input()

if conf != 'yes':
  print "Goodbye"
  sys.exit(0)

## STORE DATA
for bi, data_batch in enumerate(batch(data, R_THRPT)):
  with db.batch_write() as batch:
    print "Start batch %d" % bi
    for category, picture, s3url in data_batch:
      batch.put_item(data={ 'Category': category,
                            'Picture': picture,
                            'S3URL': s3url,
                           })

