(* ---------------------------------------------------------------------- *)
(* trees *)

datatype 'a tree = 
    Empty 
  | Leaf of 'a
  | Node of 'a tree * 'a tree

fun map (f : 'a -> 'b) (t : 'a tree) : 'b tree =
    case t of
        Empty => Empty
      | Leaf x => Leaf (f x)
      | Node (t1,t2) => Node (map f t1, map f t2)

fun reduce (n : 'a * 'a -> 'a) (e : 'a) (t : 'a tree) : 'a =
    case t of
        Empty => e
      | Leaf x => x
      | Node (t1,t2) => n (reduce n e t1, reduce n e t2)

fun flatten (l : 'a tree tree) : 'a tree = 
    reduce Node Empty l

val sum : int tree -> int = reduce (op+) 0

(* mapreduce allows both a map and a reduce at once *)
fun mapreduce (l : 'a -> 'b) (e : 'b) (n : 'b * 'b -> 'b) (t : 'a tree) : 'b =
    case t of
        Empty => e
      | Leaf x => l x
      | Node (t1,t2) => n (mapreduce l e n t1, mapreduce l e n t2)

(* ---------------------------------------------------------------------- *)
(* Some helper functions on trees.  You don't need to read these,
   but they are necessary for the example below.
   We'll see a better data structure for these operations later in the course. *)

val SOME minint = Int.minInt

fun treeFromList (l : 'a list) : 'a tree = 
    case l of
        [] => Empty
      | [x] => Leaf x
      | _ => let val len = List.length l in Node (treeFromList (List.take (l, len div 2)), treeFromList (List.drop (l, len div 2))) end

fun treeToList (t : 'a tree) : 'a list = mapreduce (fn x => [x]) [] op@ t

fun tabulate (f : int -> 'a) (n : int) : 'a tree = 
    let fun loop (left:int,here:int) : 'a tree =
        case here of 
            0 => Empty
          | 1 => Leaf (f left)
          | _ => let val l = here div 2
                     val r = here - l
                 in 
                     Node(loop (left, l), loop (left + l, r))
                 end
    in 
        loop (0,n)
    end

fun treeFromList (l : 'a list) : 'a tree = tabulate (fn x => List.nth (l,x)) (List.length l)

fun size (t : 'a tree) : int = 
    case t of
        Empty => 0
      | Leaf _ => 1
      | Node(l,r) => size l + size r

(* assumes number to take/drop is in bounds

   if it returns (t1,t2) then t1 has size n
 *)
fun takeanddrop (t : 'a tree, n : int) : ('a tree * 'a tree) = 
    case (t,n) of 
        (_ , 0) => (Empty, t)
      | (Leaf x, 1) => (Leaf x, Empty)
      | (Node (l,r), n) => 
            (case n <= size l of
                 true => let val (t,d) = takeanddrop (l,n) in (t, Node(d,r)) end
              | false => let val (t,d) = takeanddrop (r,n - size l) in (Node(l,t), d) end)
      | _ => raise Fail "bad index"

(* assumes number to drop is in bounds *)
fun drop (t : 'a tree) (n : int) : 'a tree = 
    let val (_,d) = takeanddrop (t,n) in d end

(* assumes index is in bounds *)
fun nth (t : 'a tree) (n : int) : 'a = 
    let val (_,d) = takeanddrop (t,n)
        val (f,_) = takeanddrop (d,1)

        (* assumes t has size 1, but is potentially non-normal *)
        fun getElt (t : 'a tree) : 'a = 
            case t of
                Empty => raise Fail "spec"
              | Leaf x => x
              | Node(l,r) => 
                    (case size l of
                         1 => getElt l 
                       | _ => getElt r)
    in 
        getElt f
    end

(* ---------------------------------------------------------------------- *)
(* programming with function composition: wordcount and longestline *)

fun words (s : string) : string tree = treeFromList (String.tokens (fn #" " => true | #"\n" => true | _ => false) s)
fun lines (s : string) : string tree = treeFromList (String.tokens (fn #"\n" => true | _ => false) s)

val wordcount : string -> int = sum o map (fn _ => 1) o words
val longestlinelength : string -> int = reduce Int.max 0 o map wordcount o lines


(* ---------------------------------------------------------------------- *)
(* programming wth function composition: stock market best gain *)

(* assumes both trees have the same size *)
fun zip (t1 : 'a tree, t2 : 'b tree) : ('a * 'b) tree = tabulate (fn i => (nth t1 i, nth t2 i)) (size t1)

fun suffixes (t : 'a tree) : ('a tree) tree = tabulate (fn x => drop t (x + 1)) (size t)

val maxT : int tree -> int = reduce Int.max minint 
val maxAll : (int tree) tree -> int = maxT o map maxT

fun withSuffixes (t : int tree) : (int * int tree) tree = zip (t, suffixes t)

val bestGain : int tree -> int = 
      maxAll                                                        (* step 3 *)
    o (map (fn (buy,sells) => (map (fn sell => sell - buy) sells))) (* step 2 *)
    o withSuffixes                                                  (* step 1 *)

(* if it did drops instead, this would be 40
   if it didn't only look at the future, this would be 40 *)
val 21 = bestGain (treeFromList [40, 20, 0, 0, 0, 1, 3, 3, 0, 0, 9, 21]) 

(* ---------------------------------------------------------------------- *)
(* polynomials *)

(* represent 
   c0 + c1 x + c2 x^2 + ... cn x^n

   by
   fn 0 => c0 
    | 1 => c1
    | 2 => c2
    | ... 
    | n => cn
    | _ => 0 
*)

type poly = int -> int
(* x^2 + 2x + 1 *)
val example : poly =
     fn 0 => 1 
      | 1 => 2
      | 2 => 1
      | _ => 0

fun add (p1 : poly, p2 : poly) : poly = fn k => p1 k + p2 k

(* recursive version of mult *)
fun mult (c , d) = 
    fn k => let 
                fun convolution i =
                    case i of 
                        ~1 => 0
                      | _ => (c i) * (d (k - i)) + convolution (i - 1)
            in
                convolution k
            end

(* higher-order function version of mult *)
val sum = reduce (fn (x,y) => x + y) 0
fun upto n = tabulate (fn x => x) (n + 1)
fun mult (c : poly, d : poly) : poly = 
    fn e => sum (map (fn i => c i * d (e - i)) (upto e))

val test = fn 0 => 1 
            | 1 => 1
            | _ => 0
val test' = mult (test ,test)
val 1 = test' 0
val 2 = test' 1
val 1 = test' 2
val 0 = test' 3
