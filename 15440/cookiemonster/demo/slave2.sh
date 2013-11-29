#!/bin/bash

rm -rf /tmp/cookiemonster/*
mkdir -p /tmp/cookiemonster/slave2

killall -u ksikka rmiregistry
killall -u ksikka java
sleep 1

java -cp bin cookiemonster.dfs.FSNodeImpl slave2 unix1.andrew.cmu.edu 6666 &
sleep 1
java -cp bin cookiemonster.mapreduce.TaskManagerImpl slave2 unix1.andrew.cmu.edu 6666 &
