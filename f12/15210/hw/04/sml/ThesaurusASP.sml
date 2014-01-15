functor ThesaurusASP (ASP : ALL_SHORTEST_PATHS where type vertex = string)
  : THESAURUS =
struct
  structure Seq = ASP.Seq
  open Seq

  (* Remove the following when you're done! *)
  exception NYI
  type nyi = unit

  (* You must define the following type and
   * explain your decision here with a comment.
   *)
  type thesaurus = ASP.graph

  fun expand_syn (w,syns) : (string * string) seq =
    let 
      val fwd = map (fn s => (w,s)) syns
      val bkwd = map (fn s => (s,w)) syns
    in
      Seq.append (fwd,bkwd)
    end

  (* Task 3.1 *)
  fun make thes_seq : thesaurus =
    let val expanded_syns = flatten (map expand_syn thes_seq)
    in ASP.makeGraph expanded_syns
    end

  (* Task 3.2 *)
  val numWords = ASP.numVertices

  val synonyms = ASP.outNeighbors

  (* Task 3.3 *)
  fun query T s1 : string -> string seq seq = 
    let
      val asp_table = ASP.makeASP T s1
    in (ASP.report asp_table)
    end

end

structure Thesaurus = ThesaurusASP(StringASP)
structure Utils = ThesaurusUtils(StringASP.Seq)
