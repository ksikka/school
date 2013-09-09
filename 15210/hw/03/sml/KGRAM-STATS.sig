signature KGRAM_STATS =
sig
  structure Seq : SEQUENCE
  type kgramstats (* self type *)
  type token = string
  type kgram = token Seq.seq

  (* make_stats tokens K
     Construct the underlying data structure given the sequence tokens
     representing the corpus and a maximum k-gram size K. *)
  val make_stats: token Seq.seq -> int -> kgramstats
  
  (* lookup_freq corpus prefix token
     For the corpus and a "prefix" of length at most K returns a pair
     consisting of:
      1) the number number of times "token" appeared after "prefix"
         for |prefix|=0 this is the total # of times token appears
      2) the total number of tokens that appear after "prefix" 
         for |prefix|=0 this is the total size of the corpus *)
  val lookup_freq : kgramstats -> kgram -> token -> (int * int)
  
  (* lookup_extensions corpus prefix
     For the corpus and a "prefix" of length at most K returns a
     sequence of pairs each consisting of 
      1) a token that appears at least once after "prefix", and
      2) a count of how many times that token appears 
     Every token that appears after "prefix" must appear in the seq *)
  val lookup_extensions : kgramstats -> kgram -> ((token * int) Seq.seq) 
end

