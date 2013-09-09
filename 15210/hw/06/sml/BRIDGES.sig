signature BRIDGES =
sig
  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq
  type vertex
  type edge = vertex * vertex
  type edges = edge seq

  type ugraph

  (* Takes a sequence of undirected edges as (u,v) pairs and returns the
   * corresponding graph. Each edge will appear only once and there will
   * be no self-loops.
   *)
  val makeGraph : edge seq -> ugraph

  (* Returns a sequence containing all the edges in the input graph which
   * are bridges, and only those edges.
   *)
  val findBridges : ugraph -> edges
end
