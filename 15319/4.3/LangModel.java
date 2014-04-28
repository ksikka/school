/*


<input files path> <table name> <n> <t>


 * INPUT NGram - Count pairs
 * OUTPUT NGram - Word - Probability
 *
 * <NGram, Count> -> <phrase, <word, count>>
 *
 * <phrase, <word, count>> -> <phrase, [<word, p>]
 *
 * */


package org.ksikka;

import java.io.IOException;
import java.util.*;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.*;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;

import org.apache.hadoop.hbase.mapreduce.TableReducer;
import org.apache.hadoop.hbase.mapreduce.TableOutputFormat;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;

public class LangModel {

 public static class Map extends Mapper<LongWritable, Text, Text, Text> {

    private Text phrase = new Text();
    private Text wordCountPair = new Text();

    public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // Assumes the input is clean since it's coming from my own files

        /* "how to dougie\t15" => { phrase: "how to", wordCountPair: "dougie\t15" } */

        String line = value.toString();

        String[] wordStrs = line.split(" ");

        // ignore phrases below t
        if (Integer.parseInt(wordStrs[wordStrs.length - 1].split("\t")[1]) < Integer.parseInt(context.getConfiguration().get("ksikka-t")))
            return;

        if (wordStrs.length > 1) {

            // ["how", "to", "dougie\t15"]

            String phraseStr = "";
            for (int i = 0; i < wordStrs.length; i++) {
                if ( i == (wordStrs.length - 1) ) {
                    wordCountPair.set(wordStrs[i]);
                } else if ( i == (wordStrs.length - 2) ) {
                    phraseStr = phraseStr + wordStrs[i];
                } else {
                    phraseStr = phraseStr + wordStrs[i] + " ";
                }
            }
            phrase.set(phraseStr);

            context.write(phrase, wordCountPair);
        }

        /* "how to dougie\t15" => { phrase: "how to dougie", wordCountPair: "NULL\t15" } */
        wordStrs = line.split("\t");
        phrase.set(wordStrs[0]);
        wordCountPair.set("NULL" + "\t" + wordStrs[0]);

        context.write(phrase, wordCountPair);
    }
 }

 public static class WordCount {
    public String word;
    public int count;
    public float prob;

    public static WordCount fromStr(String str) {
        String[] tokens = str.split("\t");
        // assert len(tokens) == 2
        if (tokens.length != 2) {
            return null;
        }
        WordCount wc = new WordCount();
        wc.word = tokens[0];
        try {
            wc.count = Integer.parseInt(tokens[1]);
        } catch (NumberFormatException e) {
            return null;
        }
	return wc;
    }
    public String toString() {
        if (prob == 0.0f) // the default value, ie uninitialized
            return word + " " + Integer.toString(count);
        else
            return word + " " + Float.toString(prob);
    }
 }

 public static class TopWCComputer {
    ArrayList<WordCount> topWCs;
    public int limit;

    public TopWCComputer(int limit) {
        this.limit = limit;
        this.topWCs = new ArrayList<WordCount>(limit);
    }

    public void add(WordCount wc) {
        if (topWCs.size() < limit) {
            topWCs.add(wc);
        } else {
            for (WordCount wc2 : topWCs) {
                if (wc2.count < wc.count) {
                    topWCs.remove(wc2);
                    topWCs.add(wc);
                    break;
                }
                // ensures length of topWCs is unchanged.
            }
        }
    }


 }

 public static class Reduce extends TableReducer<Text, Text, ImmutableBytesWritable> {


    public void reduce(Text key, Iterable<Text> values, Context context)
      throws IOException, InterruptedException {

        int n = Integer.parseInt(context.getConfiguration().get("ksikka-n"));
        TopWCComputer topWCs = new TopWCComputer(n);

        int sumCnt = 0; // manual calculation
        int realCnt = 0; // the NULL was seen, meaning we have the real phrase count

        for (Text s : values) {
            WordCount wc = WordCount.fromStr(s.toString());
            if (wc != null) {
                if (wc.word.equals("NULL")) {
                     realCnt = wc.count;
                } else
                    topWCs.add(wc);
                if (realCnt == 0) {
                    sumCnt += wc.count;
                }
            }
        }

        if (realCnt == 0) realCnt = sumCnt;

        Put putObj = new Put(key.toString().getBytes());
        String encodedVal = "";
        int cnt = 0;
        for (WordCount wc : topWCs.topWCs) {
            cnt += 1; // one-indexed count.

            wc.prob = (float)wc.count / realCnt;

            encodedVal = encodedVal + wc.toString();

            if (cnt != topWCs.topWCs.size())
                encodedVal = encodedVal + "\n";
        }
        putObj.add("datacol".getBytes(), new byte[0], encodedVal.getBytes());

        context.write(null, putObj);
    }
 }

 public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();

    String INPUTPATH = args[0];
    String OUTPUT_TABLE = args[1];
    String N = args[2];
    String T = args[3];

    conf.set("ksikka-n", N);
    conf.set("ksikka-t", T);
    conf.set(TableOutputFormat.OUTPUT_TABLE, OUTPUT_TABLE);

    Job job = new Job(conf, "ngcount");

    job.setMapOutputKeyClass(Text.class);
    job.setMapOutputValueClass(Text.class);

    job.setOutputKeyClass(ImmutableBytesWritable.class);
    job.setOutputValueClass(Put.class);

    job.setMapperClass(Map.class);
    //job.setCombinerClass(Combiner.class);
    job.setReducerClass(Reduce.class);

    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(TableOutputFormat.class);

    FileInputFormat.addInputPath(job, new Path(INPUTPATH));

    job.setJarByClass(LangModel.class);

    job.waitForCompletion(true);
 }

}
