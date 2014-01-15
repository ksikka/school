signature BABBLE = sig
  structure KS : KGRAM_STATS
  
  (* Function for selecting a value from a histogram. 
     [choose_random f hist] returns a value from the histogram hist
     corresponding to the cumulative distribution at f, where
     f is a (random) number from 0 to 1. *)
   val choose_random : real ->  (KS.token * int) KS.Seq.seq -> KS.token
  
  (* generate_sentence kgramstats n seed
     Generates a sentence consisting of n words (tokens) of babble.
     These are output as a string with spaces between the words
     and ending with a period.
     Each word should be selected on a random basis weighted by its
     likelyhood to follow the previous k tokens and using the 
     random seed.   See the description in the text. *)
  val generate_sentence : KS.kgramstats -> int -> int -> string

  (* generate_document kgramstats n seed
     Generates n sentences (in parallel) with random lengths between
     5 and 10.   Each should be generated with a different seed
     based on the input "seed" (e.g. seed+1, seed+2, ...). 
     Sentences should be appended together into a string *)
  val generate_document : KS.kgramstats -> int -> int -> string
end

signature BABBLE_PACKAGE = 
sig
  structure Babbler : BABBLE
  structure Parser : PARSER
  sharing Babbler.KS.Seq = Parser.Seq
end
