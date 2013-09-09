signature BST =
sig
  structure Key : ORDERED

  type 'a tree 
  type 'a t = 'a tree

  type 'a node = {left : 'a tree, key : Key.t, value : 'a, right : 'a tree}

  val empty : unit -> 'a tree
  val size : 'a tree -> int

  val singleton : (Key.t * 'a) -> 'a tree

  val makeNode : 'a node -> 'a tree
  val expose : 'a tree -> 'a node option

  val join : ('a tree * 'a tree) -> 'a tree
  val splitAt  : ('a tree * Key.t) -> ('a tree * 'a option * 'a tree)

end;
