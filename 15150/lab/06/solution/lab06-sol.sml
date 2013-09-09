
(* code for the proof *)

datatype 'a tree = Empty | Leaf of 'a | Node of 'a tree * 'a tree

fun sum (t : int tree) : int =
    case t of 
      Empty => 0
    | Leaf x => x
    | Node (t1, t2) => sum t1 + sum t2

fun sumc (t : int tree) (k : int -> int) : int = 
    case t of
      Empty => k 0
    | Leaf x => k x
    | Node (t1, t2) => sumc t1 (fn a => sumc t2 (fn b => k (a + b)))

fun sum' (t : int tree) : int = sumc t (fn x => x)

(* ---------------------------------------------------------------------- *)
(* Task 3.3 *)
fun find (p : 'a -> bool) (t : 'a tree) : 'a option = 
    case t of 
        Empty => NONE
      | Leaf x => (case p x of 
                     true => SOME x
                   | false => NONE)
      | Node (t1, t2) => 
          (case find p t1 of
             NONE => find p t2
           | SOME x => SOME x)

(* Task 3.4 *)
fun find_cont (p : 'a -> bool) (t : 'a tree) (k : 'a option -> 'b) : 'b = 
    case t of 
        Empty => k NONE
      | Leaf x => (case p x of 
                     true => k (SOME x)
                   | false => k NONE)
      | Node (t1, t2) => 
          find_cont p t1 (fn a => case a of
                                   NONE => find_cont p t2 k
                                 | SOME x => k (SOME x))

