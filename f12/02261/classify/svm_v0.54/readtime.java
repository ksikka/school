/*
 * Copyright (C) 2006 Murphy Lab,Carnegie Mellon University
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 * 
 * For additional information visit http://murphylab.web.cmu.edu or
 * send email to murphy@cmu.edu
 */
import java.util.*;
import java.io.*;

public class readtime {

    private String fn1;
    private String fn2;
    
    public readtime(String s1, String s2) {

	fn1 = s1;
	fn2 = s2;

    }

    private void process() throws Exception {

	BufferedReader s1 = new BufferedReader(new FileReader(fn1));
	PrintWriter s2 = new PrintWriter(new FileOutputStream(fn2));
	
	String line1 = null;
	
	while((line1=s1.readLine())!=null)
	    {
		StringTokenizer st1 = new StringTokenizer(line1);
		
		String docid1 = "";
		if (st1.hasMoreElements())
		    docid1 = st1.nextToken();
		
		if (docid1.equals("elapsed_time"))
		    {
			line1=s1.readLine();
			line1=s1.readLine();
			st1 = new StringTokenizer(line1);
			float f1 = Float.parseFloat(st1.nextToken());
			line1=s1.readLine();
			line1=s1.readLine();
			line1=s1.readLine();
			line1=s1.readLine();
			line1=s1.readLine();
			st1 = new StringTokenizer(line1);
			float f2 = Float.parseFloat(st1.nextToken());
			System.out.println("train: "+f1+" test: "+f2);
			s2.println(f1+" "+f2);
		    }
		
	   }
	s1.close();
	s2.close();

    }

    public static void main(String[] args) throws Exception { 

	if (args.length != 2)
	{
	    System.err.println("Usage: java readtime [time_file] [outfile]");
	    System.exit(1);
	}

	readtime p = new readtime(args[0], args[1]);
	p.process();

    }

}
