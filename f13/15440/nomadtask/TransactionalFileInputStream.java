
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Serializable;

public class TransactionalFileInputStream extends InputStream implements Serializable{

    String name;
    long seekPosition;

    public TransactionalFileInputStream(String name) throws FileNotFoundException {
        new FileInputStream(name); // goes through some security checks

        this.name = name;
        this.seekPosition = 0;
    }

    public int read() throws FileNotFoundException, IOException {
        FileInputStream f = new FileInputStream(this.name); // goes through some security checks
        if (this.seekPosition > 0)
            f.skip(this.seekPosition);
        int b = f.read();
        f.close();
        this.seekPosition ++;
        return b;
    }

    public int read(byte[] b) throws FileNotFoundException, IOException {
        FileInputStream f = new FileInputStream(this.name); // goes through some security checks
        f.skip(this.seekPosition);
        int bytesRead = f.read(b);
        f.close();
        this.seekPosition += bytesRead;
        return bytesRead;
    }

}
