package examples.WordCount;

import java.util.ArrayList;

import cookiemonster.mapreduce.Reducer;

public class WordCountReducer extends Reducer{

	@Override
	public String reduce(String key, ArrayList<String> values) {
		int count = 0;
		for (String value : values){
			count += Integer.parseInt(value);
		}
		return Integer.toString(count);
	}

}
