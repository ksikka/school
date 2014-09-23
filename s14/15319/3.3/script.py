#!/usr/bin/env python
"""
@ksikka

Set these environment variables:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
MYSQL_HOST

"""

import os
import sys
import boto
if boto.__version__ != '2.27.0':
  print "Detected boto version %s. Please use version 2.27.0 instead." % boto.__version__
  sys.exit(1)

from boto.ec2.cloudwatch import MetricAlarm
from boto.exception import BotoServerError

import MySQLdb as mdb
import time


# Configuration
key = "cc"
instance_type = "m1.small"
host = os.environ['MYSQL_HOST']



# Create connections to Auto Scaling and CloudWatch
cw_conn = boto.ec2.cloudwatch.connect_to_region("us-east-1")

#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb as mdb

con = mdb.connect(host, 'sysbench', 'project3', 'sbtest');

def get_query_count():
    """ write up says this counts as 3 queries but I'm only seeing 2 """
    cur = con.cursor()
    cur.execute("show status like 'Queries';")

    row = cur.fetchone()
    """
    >>> print row[0], row[1]
    Queries 699209
    """

    queries = int(row[1])
    return queries

def get_uptime():
    cur = con.cursor()
    cur.execute("show status like 'Uptime';")

    row = cur.fetchone()
    """
    >>> print row[0], row[1]
    Queries 699209
    """

    uptime = int(row[1])
    return uptime


def get_mysql_data():
    with con:
        m_uptime = get_uptime()
        m_queries = get_query_count()
    return (m_queries, m_uptime)


if __name__ == "__main__":

    # get the initial counts
    queries, uptime = get_mysql_data()
    iteration = 1

    # now calculate tps every 60 seconds.
    while True:
        print "Sleeping for 1 minute"
        time.sleep(60)

        old_q, old_upt = (queries, uptime)
        queries, uptime = get_mysql_data()
        iteration += 1

        """
        This minus 3 can be tested by:
            changine delay=1s
            commenting out the cw_conn put_metric_data
            running and verifying that qps is 0 when db is idle
        """
        qps = float(queries - old_q - 3) / (uptime - old_upt)

        tps = qps / 16.0 # each sysbench transcation is 16 queries
        MAX_TPS = 135
        utilization = tps / MAX_TPS * 100 # it's a percent

        print "TPS: " + str(tps)
        print "Util: " + str(utilization)
        cw_conn.put_metric_data('EC2', 'TPS Utilization', value=utilization, unit='Percent')

