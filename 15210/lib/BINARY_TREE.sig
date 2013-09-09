signature BINARY_TREE =
sig

  type 'a tree 
  type 'a t = 'a tree

  datatype 'a node = EMPTY | LEAF of 'a | NODE of 'a tree * 'a tree

  val empty : unit -> 'a tree
  val size : 'a tree -> int

  val singleton : 'a -> 'a tree
  val expose : 'a tree -> 'a node

  val join : 'a tree * 'a tree -> 'a tree

end;
