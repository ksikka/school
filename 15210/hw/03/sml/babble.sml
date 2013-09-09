structure Babbler : BABBLE =
struct
  structure KS = KgramStatsTable
  structure Seq = KS.Seq
  open Seq
  exception Impossible

  (* scanI : ('a * 'a -> 'a) -> 'a -> 'a seq -> 'a seq
       Inclusive scan. Output sequence will be same length as input sequence *)
  fun scanI f b s = 
    let 
      val (s', v) = Seq.scan f b s 
      val s' = Seq.subseq s' (1,Seq.length s' - 1)
    in Seq.append (s', Seq.singleton v)
    end 
    
 (* Given a string seq, joins with space in between. *)
  val joinWithSpaces = reduce (fn (s1,s2) => s1 ^ " " ^ s2) ""

 (* Choose random element from sequence *)
  fun choose_random (f:real) (s : (KS.token * int) seq) =
    if f < (Real.fromInt 0) orelse f > (Real.fromInt 1)
      then raise Impossible
    else
      let
        val freq_dist = scanI (fn ((a,b),(c,d)) => (c,b+d)) ("",0) s
        val freq_dist = map (fn (a,i) => (a,Real.fromInt i)) freq_dist
        val (_,sum_freqs) = nth freq_dist (length freq_dist - 1)
        val threshold = f * sum_freqs 
        val (t,_) = nth (filter (fn (_,f') => f' > threshold) freq_dist) 0
      in t end

 (* Generate n words of babble *)
  fun generate_sentence kgrammer n rseed =
  let
    val seed = (Random210.fromInt rseed)
    val randomVals = tabulate (fn i => Random210.randomReal seed i) n
    val getrand = (fn i => nth randomVals (i-1))
    (* Given kgrammer, prefix, and a counter, return
       a the sequence of tokens which is the of length |prefix| + counter *)
    fun increment_sentence prefix m =
      case m of
           (* If no more words are needed, return prefix *)
           0 => prefix
         | _ =>
              let val histSeq = KS.lookup_extensions kgrammer prefix
                  val shortened = (fn toks' => subseq toks' (1,length toks'-1))
              in case length histSeq of
                    (* If histogram is empty, shorten prefix, use contraction *)
                      0 => (case showl prefix of
                               NIL => raise Impossible
                             | CONS(x,xs) => append
                                    (singleton x,
                                               increment_sentence xs m))
                    | _ => let
                             val nextWord = choose_random (getrand m) histSeq
                             val prefix = append (prefix, singleton nextWord)
                             (* Lengthen prefix and decrement m *)
                           in increment_sentence prefix (m-1)
                           end
              end
  in
    joinWithSpaces (increment_sentence (empty ()) n) ^ "."
  end

(* Generate n sentences of babble, ranging from 5-10 words each. *)
fun generate_document kgrammer n seed =
  let
    (* Convenience functions *)
    val i_to_r = Real.fromInt
    val roundRealtoInt = Real.toInt IEEEReal.TO_NEAREST

    val rseed = Random210.fromInt seed
    val randomLengths = tabulate (fn i => (Random210.randomReal rseed i)) n
    val randomLengths = map (fn x => (i_to_r 5 * x) + (i_to_r 5)) randomLengths
    val randomSeeds = tabulate (fn i => (Random210.randomReal rseed (i+n))) n
    val randomSeeds = map (fn x => (i_to_r 10 * x)) randomSeeds
    val randomLengths = map roundRealtoInt randomLengths
    val randomSeeds = map roundRealtoInt randomSeeds
    val sentences =
            map2
              (fn (l,randseed) => generate_sentence kgrammer l randseed)
              randomLengths randomSeeds
  in
    joinWithSpaces sentences
  end


end
