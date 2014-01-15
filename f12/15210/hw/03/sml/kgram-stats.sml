signature HISTOGRAM =
sig
    structure Seq : SEQUENCE
    val histogram :  ('a * 'a -> order) -> 'a Seq.seq -> ('a * int) Seq.seq 
end

functor Histogram(aSeq : SEQUENCE) : HISTOGRAM =
struct
    structure Seq = aSeq
    open Seq
    fun histogram cmp s =
      let val initedHist = map (fn str => (str,1)) s
          val collectedHist = collect cmp initedHist
      in map (fn (str,ones) => (str,reduce op+ 0 ones)) collectedHist end
end

structure KgramStatsTable : KGRAM_STATS =
struct
  structure Table = Default.StringSeqTable
  structure STable = Default.StringTable
  structure Seq = Table.Seq
  structure Hist = Histogram(Seq)
  open Seq
  
  exception Impossible

  type token = string
  type kgramstats = (int * (token * int) seq * int STable.table) Table.table
  type kgram = token seq

  (* k_grams k toks
       Given positive number k, and token sequence toks,
       returns all k-grams of the token sequence *)
  fun k_grams (toks : token seq) (k : int) : kgram seq =
    let val num_k_grams = Int.max( length toks - k + 1 , 0 )
    in tabulate (fn i => subseq toks (i,k)) num_k_grams end
 
 (* Given a sequence of tokens, and the maximum k,
    returns a value of type kgramstats *)
  fun make_stats toks maxk =
    let
      (* If maxk is 3, then want 1, 2, 3, 4-grams *)
      val kGramSizes = tabulate (fn i => i+1) (maxk + 1)
     (* A function which given a sequence of more than 1 thing,
        returns (first n-1 things, nth thing) *)
      fun dropOffLastElem (s : token seq) : (kgram * token)=
        if length s < 1 then raise Impossible else
        let
          val l = length s
          val lastElem = nth s (l-1)
        in (subseq s (0,l-1),lastElem) end
        
      val kGramPlusOnes = flatten (map (k_grams toks) kGramSizes)
      val kGramPlusOnes = map dropOffLastElem kGramPlusOnes
      val seqOfSeqToSeq = collect (collate String.compare) kGramPlusOnes
      fun preprocessSeqEntries (prefix',toks') =
        let
          val length_toks = length toks'
          val hist = Hist.histogram String.compare toks'
          val tble = STable.fromSeq hist
        in (prefix',(length_toks, hist, tble))
        end
      val finalSeq = map preprocessSeqEntries seqOfSeqToSeq
    in
      Table.fromSeq finalSeq 
    end

  
 (* See signature for function spec *)
  fun lookup_extensions kgramtable prefix = 
    case Table.find kgramtable prefix of
         NONE => empty ()
       | SOME (_,hist,_) => hist
    
 (* See signature for function spec *)
  fun lookup_freq kgramtable prefix tok =
    case Table.find kgramtable prefix of
         NONE => (0,0) 
       | SOME (n2,_,tble) => (case STable.find tble tok of
                                  NONE => (0,n2)
                                | SOME(n1) => (n1,n2))

end
