#!/bin/bash

rm -f /tmp/cookiemonster/*
rm -rf /tmp/cookiemonster/Master
mkdir /tmp/cookiemonster/Master

killall -u ksikka rmiregistry
killall -u ksikka java
sleep 1

rmiregistry -J-Djava.rmi.server.useCodebaseOnly=false 6666 &
sleep 1
java -cp bin cookiemonster.dfs.FSManagerImpl config 127.0.0.1 6666 &
sleep 1
java -cp bin cookiemonster.dfs.FSNodeImpl Master 127.0.0.1 6666 &
sleep 1
java -cp bin cookiemonster.mapreduce.JobManagerImpl config 127.0.0.1 6666 &
sleep 1
java -cp bin cookiemonster.mapreduce.TaskManagerImpl Master 127.0.0.1 6666 &
