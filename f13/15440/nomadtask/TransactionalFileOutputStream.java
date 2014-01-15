
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.io.Serializable;

public class TransactionalFileOutputStream extends OutputStream implements Serializable{

    String name;
    private long seekPosition;

    public TransactionalFileOutputStream(String name, Boolean append) throws FileNotFoundException {
        new RandomAccessFile(name, "rw");

        this.name = name;
        this.seekPosition = 0;
    }

    /*public void write() throws IOException {
        RandomAccessFile f = new RandomAccessFile(this.name, "rw");
    
        if (this.seekPosition > 0)
            f.seek(this.seekPosition);
        int b = f.write();
        f.close();
        this.seekPosition ++;
    }*/

    public void write(byte[] b) throws IOException {
        RandomAccessFile f = new RandomAccessFile(this.name, "rw");

        System.out.println("Writing " + b);
        System.out.println("START barray: " + this.seekPosition);

        f.seek(this.seekPosition);
        f.write(b);
        this.seekPosition = f.getFilePointer();
        f.close();
        System.out.println("END barray: " + this.seekPosition);

    }

    public void write(int b) throws IOException { 
        RandomAccessFile f = new RandomAccessFile(this.name, "rw");

        System.out.println("START: " + this.seekPosition);
        System.out.println("Writing " + b);
        f.seek(this.seekPosition);
        f.write(b);
        this.seekPosition = f.getFilePointer();
        f.close();
        System.out.println("END: " + this.seekPosition);
    }

}
