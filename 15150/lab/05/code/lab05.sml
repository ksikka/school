exception Unimplemented

fun inteq (l1 : int , l2 : int) : bool =
    case Int.compare (l1, l2) of
      EQUAL => true
    | _ => false

(* ---------------------------------------------------------------------- *)
(* LISTS - Tasks 2.*                                                      *)

fun filter (p : 'a -> bool, l : 'a list) : 'a list =
 case l of 
      [] => []
    | x::xs => case (p x) of 
                    true => x :: filter(p, xs)
                  | false =>  filter(p, xs)

fun evenP (n : int) : bool =
    case n of
      0 => true
    | 1 => false
    | _ => evenP (n - 2)

fun evens (l : int list) : int list = filter (evenP,l)

fun allLessThan (pivot : int, l : int list) : int list =
 filter ( (fn x => x<pivot) , l )

fun all (p : 'a -> bool, l : 'a list) : bool =
 case l of
      [] => true
    | x::xs => (p x) andalso all(p,xs)

fun allPos (l : int list) : bool = all( (fn x => x>0), l ) 

fun allOfLength (len : int, l : 'a list list) : bool = 
  all( (fn x => length(x) = len),l ) 

fun quicksort_l (l : int list) : int list = 
  case l of
       [] => []
     | x::xs =>
         (quicksort_l(filter((fn z => z<x),l)))@(x::quicksort_l(filter((fn
         z=> z>=x),xs)))

(* ---------------------------------------------------------------------- *)
(* Trees - Tasks 3.*                                                      *)

datatype 'a tree = 
  Empty
| Leaf of 'a
| Node of ('a tree) * ('a tree)

fun treemap (f : 'a -> 'b, t : 'a tree) : 'b tree =
 case t of 
     Empty => Empty
   | Leaf x => Leaf (f x)
   | Node (l,r) => Node(treemap (f,l), treemap (f,r))

fun treemult (c : int, t : int tree) : int tree = treemap( (fn x => c*x), t) 

fun treeall (p : 'a -> bool, t : 'a tree) : bool = 
 case t of 
      Empty => true
    | Leaf x => p x
    | Node (l,r) => treeall(p, l) andalso treeall(p,r)


fun nattree (t : int tree) : bool = treeall ( (fn x=> x>=0), t )

fun treereduce (f : 'a * 'a -> 'a, b : 'a, t : 'a tree) : 'a = raise Unimplemented


(* ------------ Support code ---------------- *)

(* TASK: fill in your constructors here *)

fun treeFromList (l : 'a list) : 'a tree =
    case l of
      [] => raise Fail "the empty tree"
    | [x] => raise Fail "a leaf with value x"
    | _ => let
             val len = List.length l
           in
             (raise Fail "a node") (treeFromList (List.take (l, len div 2)),
                                    treeFromList (List.drop (l, len div 2)))
           end

fun lines (s : string) : string tree =
  treeFromList (String.tokens (fn #"\n" => true | _ => false) s)

fun words (s : string) : string tree =
  treeFromList (String.tokens (fn #" " => true | #"\n" => true | _ => false) s)

(* ------------ Your code ------------------- *)
(* Task 4.1                                   *)

(* computes the number of words in a document *)
fun wordcount (s : string) : int = raise Unimplemented

(* computes the number of words in the longest line in a document *)
fun longestline (s : string) : int = raise Unimplemented
