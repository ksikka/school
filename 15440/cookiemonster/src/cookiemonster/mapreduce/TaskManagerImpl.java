package cookiemonster.mapreduce;

import java.io.IOException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.HashMap;
import java.util.logging.Logger;

import cookiemonster.Util;
import cookiemonster.dfs.FSNode;

public class TaskManagerImpl implements TaskManager {
	static String USAGE = "Please pass the nodename as the first argument.";
	TaskManagerConfig CONFIG;
	private static Logger LOGGER = Logger.getLogger(TaskManagerImpl.class.getName());

	
	static Registry registry;
	ExecutorService mapworkers;
	ExecutorService reduceworkers;

	// TODO Remember which map tasks I have to do...
	public ConcurrentHashMap<Job, ArrayList<MapTask>> jobTaskMap;
	public ConcurrentHashMap<Job, ReduceTask> jobTaskReduce;
	
	public ConcurrentHashMap<MapTask, Future<?>> mapTaskFutures;
	public ConcurrentHashMap<ReduceTask, Future<?>> reduceTaskFutures;
	private HashMap<Job, Combiner> jobCombiner;

	JobManager jman;
	TaskManager stub;

	String nodename;
	FSNode fsnode;
	
	public TaskManagerImpl(String nodename, JobManager jman, TaskManagerConfig config, FSNode fsnode) {
		this.nodename = nodename;
		this.CONFIG = config;
		this.mapworkers = Executors.newFixedThreadPool(this.CONFIG.NUM_MAP_SLOTS);
		this.reduceworkers = Executors.newFixedThreadPool(this.CONFIG.NUM_REDUCE_SLOTS) ;
		this.jobCombiner = new HashMap<Job, Combiner>();
    this.jobTaskMap = new ConcurrentHashMap<Job, ArrayList<MapTask>>();
    this.jobTaskReduce = new ConcurrentHashMap<Job, ReduceTask>();
    this.mapTaskFutures = new ConcurrentHashMap<MapTask, Future<?>>();
    this.reduceTaskFutures = new ConcurrentHashMap<ReduceTask, Future<?>>();
		this.jman = jman;
		this.fsnode = fsnode;
	}
	
	/* Get all map tasks on this Task Manager
	 * If a map task is completed and you get it, you wont see it next time. */
	public ArrayList<MapTask> getMapTasks(Job j) {
		ArrayList<MapTask> tasks = this.jobTaskMap.get(j);
		ArrayList<MapTask> returnTasks = new ArrayList<MapTask>();
		if(tasks == null){
			System.out.println("TASKS IS NULL ");
			return returnTasks;
		}
		returnTasks.addAll(tasks);
		
		boolean allWaitingToCombine = true;
		for (MapTask t : returnTasks) {
			if (t.status != MapTask.Status.WAITFORCOMBINE) {
				allWaitingToCombine = false;
				break;
			}
		}

		if (allWaitingToCombine) {
			this.combineMapOutputs(j);
			for (MapTask t : returnTasks) {
				t.status = MapTask.Status.COMBINING;
			}
		}
		
		boolean doneCombining = false;
		for (MapTask t : returnTasks) {
			if (t.status == MapTask.Status.COMBINING) {
				// if any one of them are combining, we know all of them are combining.
				Combiner c = this.jobCombiner.get(j);
				if (!c.thread.isAlive()) {
					LOGGER.info("FROM TASKMAN Combiner finished");
					// assume success for now
					try {
						c.thread.join();
            doneCombining = true;
            this.jobCombiner.remove(j);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				break;
			}
		}
		if (doneCombining) {
			for (MapTask t : returnTasks) {
				t.status = MapTask.Status.COMPLETE;
			}
		}
		
		
		return returnTasks;
	}

	/* Called once per job, assigns all the map tasks for this node. */
	public synchronized void AssignMapTask(ArrayList<MapTask> tasks) {
		if ((tasks == null) || (tasks.size() == 0))
			return;
		this.jobTaskMap.put(tasks.get(0).job, tasks);
		for (MapTask curTask : tasks) {
			curTask.status = MapTask.Status.INPROG;
			Future<?> x = this.mapworkers.submit(new MapWorker(this.nodename,curTask, this.fsnode));
			this.mapTaskFutures.put(curTask, x);
		}
	}
	
	public synchronized void AssignReduceTask(ArrayList<ReduceTask> t){
		if (t == null)
			return;
		for(ReduceTask task : t){
			this.jobTaskReduce.put(task.job, task);
			Future<?> x = this.reduceworkers.submit(new ReduceWorker(task, this.fsnode));
			this.reduceTaskFutures.put(task, x);	
		}	
	}
	
	public void combineMapOutputs(Job job) {
    LOGGER.info("We callin the combiner 'mon.");
		Combiner combiner = new Combiner(job, this);
		Thread t = new Thread(combiner);
		combiner.thread = t;
		t.start();
		
		this.jobCombiner.put(job, combiner);
	}
	
	public void run(String nodename){
		// Set up this VM to be able to use RMI
    	try {
			Util.preRMISetup(TaskManagerImpl.class);
		} catch (IOException e1) {
			System.out.println("Error while creating security/policy file:");
			e1.printStackTrace();
			System.exit(1);
		}

    	// Create a TaskManagerImpl object and expose via RMI
        TaskManager stub;
		try {
			stub = (TaskManager) UnicastRemoteObject.exportObject((TaskManager) this, 0);
		    this.stub = stub;  
			//TaskManagerImpl.registry.rebind("TaskManager " + nodename, stub);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			throw new RuntimeException("Registry fail - todo make this better");
		}
		try {
			this.jman.registerTaskManager(this.nodename, this.stub);
		} catch (RemoteException e) {
			e.printStackTrace();
			throw new RuntimeException("JobManager unreachable :(");
		}

	}


	public static void main(String[] args) {
		/* CHECK ARGS */
		if (args.length != 3) {
			System.out.println(TaskManagerImpl.USAGE);
    		System.exit(1);
		}
		
		String nodename = args[0];
		String reghost = args[1];
		int regport = Integer.parseInt(args[2]);

		try {
			Util.preRMISetup(TaskManagerImpl.class);
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}

		/* CONNECT TO RMI REGISTRY */
		try {
			TaskManagerImpl.registry = LocateRegistry.getRegistry(reghost, regport);
        } catch (RemoteException e) {
            System.out.println("Error connecting to RMI Registry. Is it on? Traceback:");
            e.printStackTrace();
            System.exit(1);
        }

        // Connect to the JobManager in the cluster and the FSNode on the current node
        JobManager jman = null;
        FSNode fsnode = null;
        try {
            jman = (JobManager) TaskManagerImpl.registry.lookup("JobManager");
            fsnode = (FSNode)  TaskManagerImpl.registry.lookup("FSNode " + nodename);
        } catch (Exception e) {
            System.out.println("Couldn't do a lookup in registry:");
            e.printStackTrace();
            System.exit(1);
        } assert jman != null; assert fsnode != null;

		TaskManagerConfig configObj = null;
		try {
			configObj = jman.getConfig();
		} catch (RemoteException e) {
			System.out.println("Master unreachable");
			System.exit(1);
		}
		TaskManagerImpl taskmanager = new TaskManagerImpl(nodename, jman, configObj, fsnode);	
		taskmanager.run(nodename);
	}
}
