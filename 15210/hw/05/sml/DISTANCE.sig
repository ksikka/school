signature DISTANCE =
sig
  structure Table : TABLE
  structure Set : SET
  structure Seq : SEQUENCE

  type vertex = Table.key
  type weight = real
  type edge = vertex * vertex * weight
  type heuristic = vertex -> real
  type graph
  
  val makeGraph : edge Seq.seq -> graph

  val findPath : heuristic -> graph -> Set.set -> Set.set
                 -> ((vertex*weight) option * int)
end;
