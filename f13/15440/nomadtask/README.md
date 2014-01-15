nomadtask
=========

Processes that you can suspend, migrate, and resume.

By Karan Sikka and Samaan Ghani

@ksikka
@sghani

Table of Contents
----------------

1. Overview
2. Testing

3. Master/Slave architecture
4. PMServer (Slave) and Messages
5. MasterRepl

5. MigratableProcess
6. Transactional File Input and Output Stream
7. Network requests


Overview
--------

The ProcessManager is a system for running processes on multiple nodes.

Run
    java ProcessManager

to run on a node as Master. Then you'll see an interactive shell where you can:

* run one of a prewritten set of migratable process
* list the running processes
* send a process from one node to another once you've started running it 

MigratableProcesses may perform File IO using the TransactionalFileInputStream and TransactionalFileOutputStream utilities,
which don't leave file descriptors open.

MigratableProcesses may also perform Network IO. All IO is mutexed with the ProcessManager suspend method,
so suspending will wait for IO to complete.

You can also attach slaves using:
    java ProcessManager -c [master server address] -p [master server port]
    example:
    java ProcessManager -c 127.0.0.1 -p 9090

The slaves will print the processes running on them.


Testing
-------

Automated:

Testing works on Andrew AFS only. Copy the source files to:

~/private/15440/nomadtask/

Then to spawn some nodes and run tests:

jar -xf jsoup-1.7.2.jar (dependency for one of the sample migratable processes from http://jsoup.org/)

python run\_tests.py [n]

Replace n with the number of slaves you want to run, where n is an integer between 0 and 14.
Fabric will use ssh to run one slave per CMU server, on the unixN CMU servers.:

Manual:

Run: (dependency for one of the sample migratable processes from http://jsoup.org/)

jar -xf jsoup-1.7.2.jar

Start master:
java ProcessManager 

Start some slaves: (repeat for as many slaves as desired)
java ProcessManager -c [ip address of master] -p 9090

You can also test it by hand by entering different commands in the repl. For instance after starting the master and several slaves you can start a process by entering into the repl:

GrepProcess query input.txt output.txt
FileCopy lines input.txt ouput.txt
SleepProcess 50
SiteCrawl cmu.edu

Then you can migrate that process by entering:

SendProcess 0 1 0

This notation comes from the fact that slaves are registered by an ID, the first slave has id 0, next is 1 and so on.So SendProcess takes the id of the node on which the process is currently running as the first argument, and then the id of the node on which the process should be transferred to as the second argument, and the PID of the process that needs to be moved as the final argument.



Master/Slave architecture
-------------------------

When you start ProcessManager in Master mode, you get a REPL which is capable of running/listing/sending processes.
The way this works is that the master also needs at least one slave started for it to delegate work to. The slave
also will not run properly if started when the master is not already present.

When you start ProcessManager in Slave mode, it sends a message to the master to register itself.
Then it waits for messages and executes messages from the master in a loop.

Every master is a registry server and process delegator, and every slave is a worker waiting for work.

The master round robins tasks, as in it delegates tasks to slaves in order that they registered, and if all of them have received tasks then it starts from the first slave again.


PMServer (Slave) and Messages
-----------------------------

PMServer is a tiny Inet socket based server. It waits on an ephemeral port for connections. When it receives a connection,
it tries to read the input stream as an object using Java output stream. It expects to receive an object of type Message, which
we created to encapsulate messages.

There are 3 types of messages the slave PMServer handles:

1. runProcess: Given a Migratable process, run the process.
2. sendProcess: Given a Migratable process id and an Inet address/port pair, migrate the associated process to the slave listening at that location.
3. getProcessStatus: Given a Migratable process id, return the status of the process (running or done)

MigratableProcess IDs are unique for a single session of the Master being alive.


When the PMServer is in Master mode, it only listens for one type of Message:

1. register

This is a message the slave will send to the master to register it as a capable worker.


MigratableProcess
-----------------

The MigratableProcess interface requires the run and suspend methods.
In the run method, you'd write the code that you want to run.
In the suspend method, you signal to the run thread that the process is stopping, to afford it a chance to save some state.
Then you wait for the run thread to be done suspending.



Transactional File Input and Output Stream
------------------------------------------

When writing MigratableProcesses, you should take advantage of the Transactional File Input/Output Streams.
They have a similar interface to normal File Input/Output Streams, but they will not be corrupted if the process is suspended,
since they open and close the file descriptors on every read/write.


Network requests
----------------

When making network requests in MigratableProcesses, you should acquire the suspend lock, make the request, get the response, and only then should you release the suspend lock.
In the suspend function, acquire the lock in the beginning and release it at the end.

Using this technique, the suspend method will wait for network requests to finish.
