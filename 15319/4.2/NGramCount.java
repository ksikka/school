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
        
public class NGramCount {
        
 public static class Map extends Mapper<LongWritable, Text, Text, IntWritable> {

    private final static IntWritable one = new IntWritable(1);

    private Text word = new Text();

    public static String[] nGrams(String[] tokens, int n) {
        if (n > tokens.length)
            return new String[0];
        int nglength = tokens.length - n + 1;
        String[] ngrams = new String[nglength];
        for (int i = 0; i < nglength; i++) {
            String ngs = ""; //ngram string
            for (int j = 0; j < n; j++) {
                ngs += tokens[i + j];
                if (j != n - 1)
                    ngs += " ";
            }
            ngrams[i] = ngs;
        }
        return ngrams;
    }

    public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String line = value.toString();

        String[] wordStrs = line.replaceAll("[^A-Za-z]", " ").toLowerCase().split("\\s+");
        String[] twoGrams = nGrams(wordStrs, 2);
        String[] threeGrams = nGrams(wordStrs, 3);
        String[] fourGrams = nGrams(wordStrs, 4);
        String[] fiveGrams = nGrams(wordStrs, 5);


        for (int i = 0; i < wordStrs.length; i ++) {
            String wordStr = wordStrs[i];
            word.set(wordStr);
            context.write(word, this.one);
        }
        for (int i = 0; i < twoGrams.length; i ++) {
            String wordStr = twoGrams[i];
            word.set(wordStr);
            context.write(word, this.one);
        }
        for (int i = 0; i < threeGrams.length; i ++) {
            String wordStr = threeGrams[i];
            word.set(wordStr);
            context.write(word, this.one);
        }
        for (int i = 0; i < fourGrams.length; i ++) {
            String wordStr = fourGrams[i];
            word.set(wordStr);
            context.write(word, this.one);
        }
        for (int i = 0; i < fiveGrams.length; i ++) {
            String wordStr = fiveGrams[i];
            word.set(wordStr);
            context.write(word, this.one);
        }
    }
 }

 public static class Reduce extends Reducer<Text, IntWritable, Text, IntWritable> {

    public void reduce(Text key, Iterable<IntWritable> values, Context context) 
      throws IOException, InterruptedException {

        int ngcount = 0;

        // create one space separated string
        for (IntWritable cnt : values) {
            ngcount += cnt.get();
        }

        context.write(key, new IntWritable(ngcount));
    }
 }
        
 public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
        
    Job job = new Job(conf, "ngcount");
    
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
        
    job.setMapperClass(Map.class);
    job.setCombinerClass(Reduce.class);
    job.setReducerClass(Reduce.class);
        
    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(TextOutputFormat.class);
        
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
        
    job.setJarByClass(NGramCount.class);

    job.waitForCompletion(true);
 }
        
}
