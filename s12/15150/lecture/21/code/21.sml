signature ORDERED = 
sig
    type t
    val compare : t * t -> order
end

structure IntOrdered : ORDERED =
struct
    type t = int
    val compare = Int.compare
end

signature DICT =
sig
  structure Key : ORDERED
  type 'v dict

  val empty  : 'v dict
  val insert : 'v dict -> (Key.t * 'v) -> 'v dict
  val lookup : 'v dict -> Key.t -> 'v option
end

functor RBTDict(Key : ORDERED) : DICT =
struct

  structure Key : ORDERED = Key

  datatype color = Red | Black

  (* A RBT satisfies
     (red) no red node has a red child
     (black) all paths from the root to a leaf have the same number of black nodes 

     therefore the length of the longest path (alternate red and black)
     is no more than twice the length of the shortest 

     and therefore the depth of the tree is O(log size)
     *)
  datatype 'v tree =
      Empty
    | Node of 'v tree * (color * (Key.t * 'v)) * 'v tree

  type 'v dict = 'v tree (* representation invariant: is a RBT *)

  val empty = Empty

  fun lookup d k =
      case d of
          Empty => NONE
        | Node (L, (_ , (k', v')), R) =>
              case Key.compare (k,k') of
                  EQUAL => SOME v'
                | LESS => lookup L k
                | GREATER => lookup R k
                  
      (* An AlmostRBT (ARBT) is like a RBT:
         it satisfies (black) and 
         (almost-red) no red node has a red child, except perhaps the root
         *)
  fun insert d (k, v) =
      let 
          (* Root is Red,   both RBT --> ARBT
             Root is Black, at most one ARBT, and the other(s) RBT --> RBT
             preserves the black-height
          *)
          fun balance p = 
              case p of 
                  (Node(Node (a , (Red, x) , b) , (Red , y) , c) , (Black , z) , d) => 
                      Node (Node (a , (Black , x) , b) , (Red , y), Node (c , (Black , z) , d))
                | (Node(a , (Red , x) , Node (b , (Red , y) , c)) , (Black , z) , d) => 
                      Node (Node (a , (Black , x) , b) , (Red , y), Node (c , (Black , z) , d))
                | (a , (Black , x) , Node(Node (b , (Red, y) , c) , (Red , z) , d)) => 
                      Node (Node (a , (Black , x) , b) , (Red , y), Node (c , (Black , z) , d))
                | (a , (Black , x) , Node(b , (Red , y) , Node (c , (Red , z) , d))) => 
                      Node (Node (a , (Black , x) , b) , (Red , y), Node (c , (Black , z) , d))
                | _ => Node p
          (* if d is an RBT[Red]   then ins d is an ARBT 
             if d is an RBT[Black] then ins d is an RBT 
             preserves the black-height
             *)
          fun ins d =
              case d of
                  Empty => Node (empty, (Red, (k, v)), empty)
                | Node (l, (c , (k', v')), r) =>
                      case Key.compare (k,k') of
                          EQUAL => Node (l, (c, (k, v)), r)
                        | LESS => balance (ins l, (c , (k', v')), r)
                        | GREATER => balance (l, (c , (k', v')), ins r)
          (* if t is an ARBT then blackenRoot t is a RBT *)
          fun blackenRoot t = case t of Empty => Empty 
             | Node (l , (_ , x) , r) => Node (l , (Black , x) , r)
      in blackenRoot (ins d) 
      end
end
structure IntTreeDict = RBTDict (IntOrdered)

fun fromAList l = List.foldr (fn (x,y) => IntTreeDict.insert y x) IntTreeDict.empty l
val test = fromAList [(1,"a"),(2,"b"),(3,"c"),(4,"d"),(5,"e"),(6,"f"),(7,"h"),(8,"i")]
val test' = fromAList (List.rev [(1,"a"),(2,"b"),(3,"c"),(4,"d"),(5,"e"),(6,"f"),(7,"h"),(8,"i")])

val test2 = fromAList [(5,"e"),(6,"f"),(7,"h"),(8,"i")]
val test2' = fromAList (List.rev [(5,"e"),(6,"f"),(7,"h"),(8,"i")])

functor Dict(Key : ORDERED) : DICT = RBTDict(Key)
