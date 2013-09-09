signature MST =
sig
  structure Seq : SEQUENCE = ArraySequence

  type vertex
  type edge = vertex * vertex * int

  (* Computes a minimum spanning tree of the undirected graph
   * represented by a sequence of directed edges
   *)
  val MST : (edge Seq.seq * int) -> edge Seq.seq
end
