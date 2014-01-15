#!/usr/bin/env python

import sys
import os
import random
import time
import pexpect


def nhosts(n):
    """
    Return a list of n valid hosts to use.
    """
    host_ids = range(33,47) # unix3 -> unix16
    random.shuffle(host_ids)
    host_ids = ["ghc%d.ghc.andrew.cmu.edu" % i for i in host_ids]
    return host_ids[:n]

MASTER =True

def ssh_pexpect(host, command, username, password, cwd=None):
    ssh_new_key = "Are you sure you want to"
    ssh_new_key2 = "be established"

    if cwd is None:
        cwd_prefix = ""
    else:
        cwd_prefix = "cd %s && " % cwd
    cmd_connect = "ssh -p22 %s@%s '%s'" % (username, host, cwd_prefix + command)

    try:
        print "Running %r in a pty" % cmd_connect
        global MASTER
        if MASTER:
            p = pexpect.spawn(cmd_connect)
            p.logfile_read=sys.stdout
            MASTER = False
        else:
            p = pexpect.spawn(cmd_connect)
        sys.stdout.write("Waiting for output... ")
        i = p.expect([ssh_new_key, ssh_new_key2, 'assword:'])
        if i == 0 or i == 1:
            print "(You've never sshed into this server before)"
            p.send('yes\n\r')
            print "waiting for password"
            i = 2 + p.expect(['assword:'])
        if i == 2:
            p.send(password+'\n\r')
    except Exception:
        print "Could not connect to %s@%s" % (username, host)
        print "Debug info:"
        #print p
        print "The ssh connections are flaky... Please don't be discouraged - try again!"
        raise

    print "Success!"

    return p


def test(n, username, password):
    n = int(n)
    assert n > 0 and n < 15
    servers = nhosts(n+1)
    master_host, slave_hosts = servers[0], servers[1:]

    master = ssh_pexpect(master_host, "java ProcessManager", username, password, cwd="/afs/andrew.cmu.edu/usr18/ksikka/private/15440/nomadtask")


    slave_ps = []
    for slave_host in slave_hosts:
        time.sleep(1)
        slave = ssh_pexpect(slave_host, "java ProcessManager -c %s -p 9090" % master_host, username, password, cwd="~/private/15440/nomadtask")
        slave_ps.append(slave)
        time.sleep(1)
        master.send("GrepProcess hello test.txt output.txt\r")
        time.sleep(1)
        for i in xrange(4):
            print slave.readline()

    print master.read()
    master.send("SleepProcess 100\r")
    print "waiting 5s..."; time.sleep(5)
    master.send("sendProcess 0 1 0\r")
    print "waiting 5s..."; time.sleep(5)
    master.send("sendProcess 1 0 0\r")
    print "waiting 5s..."; time.sleep(5)
    slave_ps[0].read()
    slave_ps[1].read()


if __name__ == "__main__":

    try:
        username = os.environ['CMU_USERNAME']
        password = os.environ['CMU_PASSWORD']
    except KeyError:
        print "Please enter your username and password in $CMU_USERNAME and $CMU_PASSWORD."
        sys.exit(1)

    n = int(sys.argv[1])
    test(n, username, password)
