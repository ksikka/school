
import java.lang.Runnable;
import java.io.Serializable;

public interface MigratableProcess extends Runnable, Serializable {
    public void suspend();
    public void run();
}
