
public class SleepProcess implements MigratableProcess {
    int count;
    int i;
    private volatile boolean suspending;

    public SleepProcess(String[] args) {
        this.count = Integer.parseInt(args[0]);
        this.i = 0;
        this.suspending = false;
    }

    public void run() {
        // keep doing your thing until suspend is called
        while(!suspending) {
            if (i >= count)
                break;
            System.out.println("Sleeping "+i);
            try{
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                System.out.println("I'm dead :(");
                System.exit(1);
            }
            i++;
        }
        // suspend was called mid execution
        suspending = false; // this is for when run is called later.
    }
    public void suspend() {
        this.suspending = true;
        // wait until run is in a safe state
        while(suspending);
    }
}
