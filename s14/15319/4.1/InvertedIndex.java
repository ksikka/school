package org.ksikka;

import java.io.IOException;
import java.util.*;
        
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
        
public class InvertedIndex {
        
 public static class Map extends Mapper<LongWritable, Text, Text, Text> {

    private Text word = new Text();
    private Text filename = new Text();

    public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String line = value.toString();

        String[] wordStrs = line.replaceAll("\\p{P}", " ").toLowerCase().split("\\s+");

        HashSet<String> wordSet = new HashSet<String>();

        for (int i = 0; i < wordStrs.length; i ++) {
            String wordStr = wordStrs[i];
            wordSet.add(wordStr);
        }

        for (String wordStr : wordSet) {
            word.set(wordStr);
            // get the file name
            FileSplit fs = (FileSplit) context.getInputSplit();
            filename.set(fs.getPath().getName());
            context.write(word, filename);
        }
    }
 }

 public static class Reduce extends Reducer<Text, Text, Text, Text> {

    public void reduce(Text key, Iterable<Text> values, Context context) 
      throws IOException, InterruptedException {

        // deduplicate
        HashSet<String> filenames = new HashSet<String>();
        for (Text val : values) {
            filenames.add(val.toString());
        }

        // create one space separated string
        String filenamesCatted = "";
        for (String val : filenames) {
            if (filenamesCatted.length() > 0)
                filenamesCatted += " ";
            filenamesCatted += val;
        }

        context.write(key, new Text(filenamesCatted));
    }
 }
        
 public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
        
        Job job = new Job(conf, "wordcount");
    
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);
        
    job.setMapperClass(Map.class);
    job.setReducerClass(Reduce.class);
        
    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(TextOutputFormat.class);
        
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
        
    job.setJarByClass(InvertedIndex.class);

    job.waitForCompletion(true);
 }
        
}
