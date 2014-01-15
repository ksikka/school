/*Tests File IO*/

import java.io.PrintStream;
import java.io.EOFException;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.IOException;
import java.lang.Thread;
import java.lang.InterruptedException;

public class FileCopy implements MigratableProcess
{
  private TransactionalFileInputStream  inFile;
  private TransactionalFileOutputStream outFile;
  private int totalLines;
  private int i;

  private volatile boolean suspending;

  public FileCopy(String args[]) throws Exception
  {
    if (args.length != 3) {
      System.out.println("usage:  FileCopy <int> <inputFile> <outputFile>");
      throw new Exception("Invalid Arguments");
    }
    
    this.totalLines = Integer.parseInt(args[0]);
    this.i =0;
    inFile = new TransactionalFileInputStream(args[1]);
    outFile = new TransactionalFileOutputStream(args[2], false);
  }

  public void run()
  {
    PrintStream out = new PrintStream(outFile);
    DataInputStream in = new DataInputStream(inFile);

    try {
      while (!suspending) {
        if(i < totalLines){
          String line = in.readLine();

          System.out.println(line);

          if (line == null) break;
          out.println(line);
          this.i++;
        }
        try {
          Thread.sleep(500);
        } catch (InterruptedException e) {
          // ignore it
        }
      }
    } catch (EOFException e) {
      //End of File
      System.out.println("WTF");
    } catch (IOException e) {
      System.out.println ("FileCopy: Error: " + e);
    }


    suspending = false;
  }

  public void suspend()
  {
    suspending = true;
    while (suspending);
  }

}