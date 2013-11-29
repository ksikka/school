package cookiemonster.mapreduce;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.rmi.AccessException;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.logging.Logger;

import cookiemonster.ConfigSyntaxError;
import cookiemonster.Util;
import cookiemonster.dfs.FSManager;
import cookiemonster.dfs.FSManagerConfig;
import cookiemonster.dfs.FSManagerImpl;
import cookiemonster.dfs.FSNode;
import cookiemonster.dfs.FSNodeImpl;
import cookiemonster.dfs.Record;
import cookiemonster.dfs.exceptions.MasterUnreachableException;
import cookiemonster.mapreduce.MapTask.Status;

public class JobManagerImpl implements JobManager {

	static String USAGE = "1. path to the config file\n2. rmi host\n3. rmi port";

	static Registry registry;
	private JobManager stub;
	private static Logger LOGGER = Logger.getLogger(JobManagerImpl.class.getName());
	
	public TaskManagerConfig CONFIG;
	
	private FSNode fsnode; // this is the filesystem

	// used for generating unique IDs
	private int lastIndex;
	
	/* Connected Task Manager management */
	ArrayList<TaskManager> TaskManagers;
	
	
	/* Job Management */
	private ArrayList<Job> jobs;

	/* Running MapTask management */
	private ConcurrentHashMap<TaskManager, ArrayList<MapTask>> taskManMapTasks;
	private ConcurrentHashMap<Job, ArrayList<MapTask>> jobMapTasks;
	
	/* TODO Running ReduceTask management */
	
	public JobManagerImpl(FSNode fsnode, TaskManagerConfig configObj) {
		this.lastIndex = 0;
		this.fsnode = fsnode;

		this.TaskManagers = new ArrayList<TaskManager>();
		this.jobs = new ArrayList<Job>();

		this.taskManMapTasks = new ConcurrentHashMap<TaskManager, ArrayList<MapTask>>();
	    this.jobMapTasks = new ConcurrentHashMap<Job, ArrayList<MapTask>>();
	    
	    this.CONFIG = configObj;
	}
	
	@Override
	public TaskManagerConfig getConfig() {
		return this.CONFIG;
	}
	
	@Override
	public synchronized void startJob(Job job) throws RemoteException {
		this.lastIndex++;
		job.jid = this.lastIndex;
		job.numReduceGroups=CONFIG.NUM_REDUCE_SLOTS*this.TaskManagers.size();
		job.status = Job.Status.INPROGMAP;
		this.jobs.add(job);
		

		// For each input file, for each record, start a map task at that record's node
		// If the node is out of slots, then assign elsewhere
		// Note: We assume that the files are already in the distributed file system
		String[] inputFileArr = new String[job.inputFiles.size()];
		Record[] records;
		try {
			records = fsnode.recordsOfFiles(job.inputFiles.toArray(inputFileArr));
		} catch (MasterUnreachableException e) {
			throw new RuntimeException("Fatal: Filesystem master went down");
		}
		job.numMapTasks = records.length;
    LOGGER.info(String.format("Assigning %d maptasks to job %d", job.numMapTasks, job.jid));
		ArrayList<MapTask> maptasks = new ArrayList<MapTask>();
		for(Record record : records) {
			MapTask mtask = new MapTask(job.MapClass, record, job, MapTask.Status.NOTSTARTED, ++ this.lastIndex);
			maptasks.add(mtask);
		}

		int numTasksPerNode = (int) Math.floor(job.numMapTasks/this.TaskManagers.size());
		int taskManIndex = 0;
		for (TaskManager t : this.TaskManagers) {
			
			// add n tasks to each task manager where n is the above task
			// collect the tasks first in a list, then send them to the taskmanager at once using RMI
			ArrayList<MapTask> tasksAssigned = new ArrayList<MapTask>();
			
			// If it's the last task manager, empty out the queue entirely.
			if(taskManIndex == this.TaskManagers.size() - 1) {
				while(!maptasks.isEmpty()){
					tasksAssigned.add(maptasks.remove(0));
				}
			}
			// Else, assign floor( | maptasks | / | taskmans | )
			else {
				for (int j = 0; j < numTasksPerNode; j ++) {
					MapTask nextMapTask = maptasks.remove(0); // yes this is suboptimal, no idc.
					if (nextMapTask == null) continue;
					tasksAssigned.add(nextMapTask);
				}
			}
      LOGGER.info(String.format("Attempting to assign %d tasks to TaskManager %s", tasksAssigned.size(), t));
			try {
				if(this.jobMapTasks.get(job) == null){
					this.jobMapTasks.put(job, tasksAssigned);
				}
				else{
					this.jobMapTasks.get(job).addAll(tasksAssigned);
				}
				t.AssignMapTask(tasksAssigned);
				ArrayList<MapTask> officialTasksAssignedList = this.taskManMapTasks.get(t);
				if (officialTasksAssignedList == null) {
					officialTasksAssignedList = new ArrayList<MapTask>();
					this.taskManMapTasks.put(t, officialTasksAssignedList);
				}
				officialTasksAssignedList.addAll(tasksAssigned);
        LOGGER.info("Seems to have gone ok!");
			} catch (RemoteException e) {
				// TODO handle node failure
				throw new RuntimeException("Error - taskman unreachable");
			}
			taskManIndex ++;
		}
	
	}

	public void assignReduceTasks(Job job) {
		ArrayList<ReduceTask> reduceTasks = new ArrayList<ReduceTask>();
		for (int i = 0; i < this.TaskManagers.size(); i++){
			reduceTasks.clear();
			for(int j =0; j< this.CONFIG.NUM_REDUCE_SLOTS; j++){
				ReduceTask t = new ReduceTask(job.reduceClass, (i*this.CONFIG.NUM_REDUCE_SLOTS)+j, job);
				reduceTasks.add(t);
			}
			try {
				this.TaskManagers.get(i).AssignReduceTask(reduceTasks);
			} catch (RemoteException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void registerTaskManager(String nodename, TaskManager taskmanager) {
		try {
			JobManagerImpl.registry.rebind("TaskManager " + nodename, taskmanager);
		} catch (Exception e){
			throw new RuntimeException(e);
		}
		this.TaskManagers.add(taskmanager);
	}

	public void run(){

    	// Create a FSManagerImpl object and expose via RMI
        JobManager stub;
		try {
			stub = (JobManager) UnicastRemoteObject.exportObject((JobManager) this, 0);
		    this.stub = stub;
			JobManagerImpl.registry.rebind("JobManager", stub);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		System.out.println("JobManager Ready!");
		
		//poll all taskmanagers for their maptasks
		//update local state and check if all tasks are completed
		// when map task completes on a single node automatically merges
		// the results in Record Grouper
		while(true) {
			try { Thread.sleep(1000); } catch (InterruptedException e) { }
			for (Job job : this.jobs) {
				// TODO Case on job phase.
				
				if (job.status == Job.Status.INPROGMAP) {
					
					ArrayList<MapTask> currMapTasks = this.jobMapTasks.get(job);
					assert currMapTasks != null;
					
					// Update local MapTask state with the potentially updated MapTask state from each TaskMangaer
					for (TaskManager manager : this.TaskManagers) {	
						
						// Get fresh map task state from the manager
						ArrayList<MapTask> freshMapTasks = null;
						try {
							freshMapTasks = manager.getMapTasks(job);
						} catch (RemoteException e) {
							// TODO handle node failure, and note that freshMapTasks is null.
							throw new RuntimeException("Error - taskman unreachable");
						}
						// and update local map tasks.
						// for each new task, search for old task, and update w new task
						for (MapTask newTask : freshMapTasks) {
							MapTask matchingTask = null;
							for (MapTask oldTask : currMapTasks) {
								if (newTask.mapId == oldTask.mapId) {
									matchingTask = oldTask;
									break;
								}
							}
							assert matchingTask != null; // if old task couldn't be found, we have a serious problem.
							matchingTask.updateWithNewTask(newTask);
						}
					}

					// If all map tasks are completed, then start reduce phase.
					boolean completed = true;
					for (MapTask task : currMapTasks) {
            LOGGER.info("Yo checking.");
						if (task.status != Status.COMPLETE) {
                LOGGER.info(task.status.toString());
						    completed = false;
						    break;
						}
					}
					if (completed) {
						// create and dispatch reduce tasks
            this.assignReduceTasks(job);
            job.status = Job.Status.INPROGREDUCE;
					}
			 } else if (job.status == Job.Status.INPROGREDUCE) {
         // update local state with reducer state
         // check if finished, update job phase
			 }
				
			}
		}
	
	}
	public static void main(String[] args) {
		/* CHECK ARGS */
		if (args.length != 3) {
    		System.out.print(USAGE);
    		System.exit(1);
    	}
		
		String configpath = args[0];
		String reghost = args[1];
		int regport = Integer.parseInt(args[2]);

		/* READ + PARSE CONFIG */
		ArrayList<String> lines = new ArrayList<String>();
    	try {
	    	BufferedReader br = new BufferedReader(new FileReader(new File(configpath)));
	    	String l = br.readLine();
	    	while(l != null) {
	    		lines.add(l);
          l = br.readLine();
	    	}
	    	br.close();
    	} catch (IOException e) {
    		throw new RuntimeException("Error reading config file");
    	}
    	String[] lineArr = new String[lines.size()];
    	HashMap<String, String> configHash = null;
    	TaskManagerConfig configObj = null;
		try {
			configHash = Util.parseConfig(lines.toArray(lineArr));
			configObj = new TaskManagerConfig(configHash);
		} catch (ConfigSyntaxError e) {
			System.out.println(e.message);
			System.exit(1);
		} assert configHash != null; assert configObj != null;
		
		/* CONNECT TO RMI REGISTRY */
		try {
			// Set up this VM to be able to use RMI
			Util.preRMISetup(JobManagerImpl.class);
			JobManagerImpl.registry = LocateRegistry.getRegistry(reghost, regport);
        } catch (Exception e) {
            System.out.println("Error connecting to RMI Registry. Is it on? Traceback:");
            e.printStackTrace();
            System.exit(1);
        }

        /* CONNECT TO DFS (on localhost) */
        FSNode fsnode = null;
        try {
            fsnode = (FSNode) JobManagerImpl.registry.lookup("FSNode Master");
        } catch (Exception e) {
            System.out.println("Couldn't do a lookup in registry:");
            e.printStackTrace();
            System.exit(1);
        }
        
        /* We're ready to rock and roll */
		JobManagerImpl jbmanager = new JobManagerImpl(fsnode, configObj);
		jbmanager.run();
		
	}

	@Override
	public Job getJobStatus(Job job) throws RemoteException {
		// TODO Auto-generated method stub
		for (Job j : this.jobs){
			if(job ==j){
				return j;
			}
		}
		return null;
	}

	

}
