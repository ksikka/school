signature COLORING =
sig
  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq
  type color = int
  type vertex

  (* Given a sequence of edges E, graphColor(E) returns a seqeunce which
   * maps every vertex to a color. You may make the same assumptions
   * about the input seq that you did in the previous task.
   *)
  val graphColor : (vertex * vertex) seq -> (vertex * color) seq
end
