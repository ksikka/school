import java.util.*;

public class DFAConstructions {

	//You should not modify this method.
	public static void main(String[] args)
	{
		Scanner scanner = new Scanner(System.in);
		if(args[0].trim().equalsIgnoreCase("union"))
		{
			DFA in1 = DFA.from_input_string(scanner);
			scanner.nextLine();
			DFA in2 = DFA.from_input_string(scanner);
			print_DFA(union(in1, in2));
		}
		else if(args[0].trim().equalsIgnoreCase("difference"))
		{
			DFA in1 = DFA.from_input_string(scanner);
			scanner.nextLine();
			DFA in2 = DFA.from_input_string(scanner);
			print_DFA(difference(in1, in2));
		}
		else if(args[0].trim().equalsIgnoreCase("reversal"))
			print_DFA(reversal(DFA.from_input_string(scanner)));
		else if(args[0].trim().equalsIgnoreCase("kleene_star"))
			print_DFA(kleene_star(DFA.from_input_string(scanner)));
		else
			throw new IllegalArgumentException("You must input a valid DFA construction.");
	}

	//Returns the String representation of the input DFA
	public static String from_dfa(DFA in)
	{
		return in.toString();
	}

	//Prints the String representation of the input DFA
	public static void print_DFA(DFA in)
	{
		System.out.println(from_dfa(in));
	}

	/* Returns a DFA accepting the Union of the languages accepted by
         * the input DFAs (this construction is implemented for you as an
	 * example)
	 */
	public static DFA union(DFA m1, DFA m2)
	{
		Map<Integer,Map<Integer,Integer>> newStates = new HashMap<Integer,Map<Integer,Integer>>();
		
		Set<Integer> states = new HashSet<Integer>();
		
		int i = 0;
		for(Integer j : m1.states)
		{
			Map<Integer, Integer> jStates = new HashMap<Integer, Integer>();
			for(Integer k : m2.states)
			{
				jStates.put(k, i);
				states.add(i);
				i++;
			}
			newStates.put(j, jStates);
		}
		
		Integer initial_state = newStates.get(m1.initial_state).get(m2.initial_state);
		
		Set<Integer> final_states = new HashSet<Integer>();
		for(Integer j : m1.final_states)
		{
			for(Integer k : m2.states)
				final_states.add(newStates.get(j).get(k));
		}
		for(Integer j : m2.final_states)
		{
			for(Integer k : m1.states)
					final_states.add(newStates.get(k).get(j));
		}
		
		//We assume that the alphabets of m1 and m2 are the same
		Set<Character> alphabet = new HashSet<Character>(m1.alphabet);
		
		Map<Integer,Map<Character,Integer>> transitions = new HashMap<Integer,Map<Character,Integer>>();
		for(Integer j : m1.states)
		{
			for(Integer k : m2.states)
			{
				Map<Character,Integer> thisState = new HashMap<Character,Integer>();
				for(Character c : alphabet)
				{
					thisState.put(c, newStates.get(m1.transitions.get(j).get(c)).get(m2.transitions.get(k).get(c)));
				}
				transitions.put(newStates.get(j).get(k), thisState);
			}
		}
		return new DFA(states, initial_state, final_states, alphabet, transitions);
	}

	/* Returns a DFA accepting the Difference of the languages accepted by
         * the input DFAs (i.e., the the output DFA accepts those string which
	 * are accepted by m1 and rejected by m2)
	 */
	private static DFA difference(DFA m1, DFA m2)
	{
		throw new RuntimeException("You need to implement this method");
	}

	/* Returns a DFA accepting the Reversal of the language accepted by
         * the input DFA
	 */
	private static DFA reversal(DFA m)
	{
		throw new RuntimeException("You need to implement this method");
	}

	/* Returns a DFA accepting the Kleene Star of the language accepted by
         * the input DFA
	 */
	private static DFA kleene_star(DFA m)
	{
		throw new RuntimeException("You need to implement this method");
	}
}
