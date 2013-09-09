import java.util.*;
/* An instance of this class is a DFA. Your functions should not need to edit
 * this file, but should understand how the five fields below and the
 * Constructor method work.
 */

public class DFA
{
	public Set<Integer> states;
	public Integer initial_state;
	public Set<Integer> final_states;
	public Set<Character> alphabet;
	public Map<Integer,Map<Character,Integer>> transitions; //Yes, transition functions are curried Maps...

	// DFA Constructor
	public DFA(Set<Integer> states,
			Integer initial_state,
			Set<Integer> final_states,
			Set<Character> alphabet,
			Map<Integer,Map<Character,Integer>> transitions)
	{
		this.states = states;
		this.initial_state = initial_state;
		this.final_states = final_states;
		this.alphabet = alphabet;
		this.transitions = transitions;
	}

	// Returns the String representation of the DFA
	public String toString()
	{
		StringBuilder p = new StringBuilder();
		for(Character c : alphabet)
			p.append(c + " ");
		p.append("\n");
		for(Integer i : states)
			p.append(i + " ");
		p.append("\n");
		p.append(initial_state + "\n");
		for(Integer i : final_states)
			p.append(i + " ");
		for(Integer i : states)
		{
			for(Character c : alphabet)
				p.append("\n" + i + " " + c + " " + transitions.get(i).get(c));
		}
		return p.toString();
	}
	public static DFA from_input_string(Scanner scanner)
	{
		StringTokenizer alphabetTok;
		StringTokenizer statesTok;
		Integer initial_state;
		StringTokenizer finalTok;
		try
		{
			alphabetTok = new StringTokenizer(scanner.nextLine().trim(), " ");
			statesTok = new StringTokenizer(scanner.nextLine().trim(), " ");
			initial_state = Integer.parseInt(scanner.nextLine().trim());
			finalTok = new StringTokenizer(scanner.nextLine().trim(), " ");
		} catch (NoSuchElementException e) {return null;}
		
		Set<Integer> states = new HashSet<Integer>();
		Set<Integer> final_states = new HashSet<Integer>();
		Set<Character> alphabet = new HashSet<Character>();
		Map<Integer,Map<Character,Integer>> transitions = new HashMap<Integer,Map<Character,Integer>>();
		
		while(alphabetTok.hasMoreTokens())
		{
			alphabet.add(alphabetTok.nextToken().trim().charAt(0));
		}
		while(statesTok.hasMoreTokens())
		{
			states.add(Integer.parseInt(statesTok.nextToken().trim()));
		}
		while(finalTok.hasMoreTokens())
		{
			final_states.add(Integer.parseInt(finalTok.nextToken().trim()));
		}
		for(int i = 0; i < alphabet.size()*states.size(); i ++)
		{
			int state1;
			char symbol;
			int state2;
			StringTokenizer transTok;
			try
			{
				transTok= new StringTokenizer(scanner.nextLine().trim(), " ");
				state1 = Integer.parseInt(transTok.nextToken().trim());
				symbol = transTok.nextToken().trim().charAt(0);
				state2 = Integer.parseInt(transTok.nextToken().trim());
			} catch(NoSuchElementException e) {return null;}
			if(transitions.containsKey(state1))
				transitions.get(state1).put(symbol, state2);
			else
			{
				transitions.put(state1, new HashMap<Character, Integer>());
				transitions.get(state1).put(symbol, state2);
			}
		}
		return new DFA(states, initial_state, final_states, alphabet, transitions);
	}
}
