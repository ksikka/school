package examples.WordCount;

import java.util.ArrayList;
import java.util.Map.Entry;
import java.util.AbstractMap.SimpleEntry;

import cookiemonster.mapreduce.Mapper;

public class WordCountMapper extends Mapper {

	@Override
	public ArrayList<Entry<String, String>> map(String key, String value) {
		ArrayList<Entry<String, String>> result = new ArrayList<Entry<String, String>>();
		
		String[] splits = value.split(" ");
		for (int i = 0; i < splits.length; i++){
			SimpleEntry<String, String> entry = new SimpleEntry<String, String>(splits[i],"1");
			result.add(entry);
		}
		
		return result;
		
	}
	
	

}
