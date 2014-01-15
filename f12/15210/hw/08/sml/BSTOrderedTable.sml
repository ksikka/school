functor BSTOrderedTable (structure Tree : BST
                         structure Seq : SEQUENCE) : ORD_TABLE =
struct

structure Table = BSTTable(structure Tree = Tree
                           structure Seq = Seq)

(* Include all the functionalities of the standard Table *)
open Table

(* This is defined after "open" so it doesn't get overwritten *)
structure Key = Tree.Key
type key = Key.t


fun first (T : 'a table) : (key * 'a) option =
  case Tree.expose T of
       NONE => NONE
     | SOME {left= L, key= k, value= v,...} => if Tree.size L = 0 then SOME(k,v)
                         else first L


fun last T =
  case Tree.expose T of
       NONE => NONE
     | SOME {right= R, key= k, value= v,...} => if Tree.size R = 0 then SOME(k,v)
                         else last R

fun previous T k =
  let
    val (L,_,R) = Tree.splitAt(T,k)
  in
    last L
  end

fun next T k =
  let
    val (L,_,R) = Tree.splitAt(T,k)
  in
    first R
  end

val join = Tree.join

val split = Tree.splitAt

fun getRange T (low, high) =
  let
    val (_,vOpt,R) = split (T,low)
    val first_pass = case vOpt of NONE => R
                        | SOME v => Table.insert (fn _ => raise Fail "") (low,v) R
    val (L,vOpt',_) = split (first_pass,high)
    val second_pass = case vOpt' of NONE => L
                        | SOME v => Table.insert (fn _ => raise Fail "") (high,v) L
  in second_pass
  end


end
