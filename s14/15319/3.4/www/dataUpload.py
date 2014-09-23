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
if boto.__version__ != '2.27.0':
  print "Detected boto version %s. Please use version 2.27.0 instead." % boto.__version__
  sys.exit(1)
from boto.dynamodb2.table import Table

db = Table('Proj34Cats')

cats = {
    '_root': ['Animate', 'Inanimate'], 
    'Animate': ['extinct', 'human', 'insects'],
    'Inanimate': ['apparel', 'sports', 'religious'],
    'extinct': ['trilobite', 'triceratops'],
    'human': ['brain', 'faces-easy', 'human-skeleton', 'people'],
    'insects': ['butterfly', 'centipede', 'grasshopper'],
    'apparel': ['backpack', 'cowboy-hat'],
    'sports': ['baseball', 'bowling', 'exercise'],
    'religious': ['buddha','coffin','jesus-christ'],
    'baseball': ['baseball-bat', 'baseball-glove'],
    'bowling': ['bowling-ball', 'bowling-pin'],
    'exercise': ['dumb-bell', 'treadmill']
}

print "Deleting old categories"
with db.batch_write() as batch:
  for category in cats.keys():
    batch.delete_item(hashKey='lolol', category=category)
print "Done"

## STORE DATA
with db.batch_write() as batch:
  for category, subcats in cats.iteritems():
    batch.put_item(data={ 'hashKey': 'lolol',
                          'category': category,
                          'subcategories': set(subcats),
                         })

