signature MIS =
sig
  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq
  type vertex
  type vertices

  (* an _undirected_ graph *)
  type graph

  (* Takes a sequence of undirected edges as (u,v) pairs and returns the
   * corresponding graph. Each edge will appear only once and there will
   * be no self-loops.
   *)
  val makeGraph : (vertex * vertex) seq -> graph

  (* Converts vertices to a vertex sequence *)
  val verticesToSeq : vertices -> vertex Seq.seq

  (* Returns a maximal independent set of the graph. *)
  val MIS : graph -> vertices
end
