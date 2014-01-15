functor ThesaurusASP (ASP : ALL_SHORTEST_PATHS where type vertex = string)
  : THESAURUS =
struct
  structure Seq = ASP.Seq
  open Seq

  type thesaurus = ASP.graph

  (* Task 3.1 *)
  fun make (pairs : (string * string seq) seq) : thesaurus =
      let
        fun makeEdges (w1, s) = map (fn w2 => (w1, w2)) s
        val E = flatten (map makeEdges pairs)
      in ASP.makeGraph E
      end

  (* Task 3.2 *)
  (* computes the total number of words in the thesaurus *)
  fun numWords th = ASP.numVertices th

  (* Task 3.3 *)
  (* evaluates to a sequence of synonyms for a given word *)
  fun synonyms th = ASP.outNeighbors th

  (* reports the shortest path from word1 to word2 as a sequence
   * of strings with word1 first and word2 last.
   * evaluates to NONE if no such path exists.
   *)
  fun query th word1 = ASP.report (ASP.makeASP th word1)

end

structure Thesaurus = ThesaurusASP(StringASP)
structure Utils = ThesaurusUtils(StringASP.Seq)
