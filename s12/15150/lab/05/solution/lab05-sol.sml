(* Purpose: given two integers, evaluates to true
            iff. they are equal
   Examples: inteq(1,1) => true
             inteq(2,1) => false
*)
fun inteq (l1 : int , l2 : int) : bool =
    case Int.compare (l1, l2) of
      EQUAL => true
    | _ => false

(* Tests for inteq *)
val true = inteq(2,2)
val true = inteq(5,5)
val false = inteq(2,1)
val false = inteq(3,6)

(* ---------------------------------------------------------------------- *)
(* lists *)

(* filter *)

(* Purpose: Given a natural number, evaluates to
            true iff. this number is even
   Examples: evenP 1 => false
             evenP 2 => true
*)
fun evenP (n : int) : bool =
    case n of
      0 => true
    | 1 => false
    | _ => evenP (n - 2)
(* Tests for evenP *)
val true = evenP 2
val false = evenP 3
val true = evenP 42
val true = evenP 150
val false = evenP 251

(* Things are boring without higher order functions! *)
fun evens (l : int list) : int list =
    case l of
	 [] => []
	| x :: xs => case evenP x of
			  true => x :: evens xs
			 |false => evens xs

fun allLessThan (pivot : int, l : int list) : int list =
    case l of
	 [] => []
	| x :: xs => case x < pivot of
			  true => x :: allLessThan (pivot, xs)
			 |false => allLessThan (pivot, xs)

(* Task 2.1 *)
(* Purpose: Given a list l and a predicate p on elements
            of this list, evaluates to the list of
            elements from l for which p is true
   Examples: filter (evenP, [1,2,3,4,5]) => [2,4]
             filter ((fn x => x < 2), [~1, 5, 1, 11] => [~1, 1]
*)
fun filter (p : 'a -> bool, l : 'a list) : 'a list =
  case l of
    [] => []
  | x :: xs => case p x of
             true => x :: filter(p, xs)
           | false => filter(p, xs)
(* Tests for filter *)
val [2,4] = filter (evenP, [1,2,3,4,5])
val [1,3,5] = filter ((fn x => not(evenP x)), [1,2,3,4,5])
val [1, 1, 0] = filter ((fn x => x < 2), [1, 5, 1, 5, 0])
val [5, 5] = filter ((fn x => x > 2), [1, 5, 1, 5, 0])
val [] = filter ((fn x => x = 2), [1, 5, 1, 5, 0])

(* Task 2.2 *)
(* Purpose: Given an int list, evaluate to the sublist of this
            list composed of only the even numbers
   Examples: evens ([1,2,3,4,5]) => [2,4,6]
             evens ([1,7,9]) => []
             evens ([]) => []
*)
fun evens (l : int list) : int list = filter (evenP , l)

(* Tests for evens *)
val [2,4,6] = evens [1,2,3,4,5,6]
val [] = evens [1,7,9]
val [] = evens []
val [42] = evens [41,42,43]

(* Purpose: Given an int list l and an integer pivot,
            evaluates to the sublist of l of only
            those numbers that are less than pivot
   Examples: allLessThan(2, [1,2,3]) => [1]
             allLessThan(1, [1,2,3]) => []
             allLessThan(5, []) => []
*)
fun allLessThan (pivot : int, l : int list) : int list =
    filter (fn x => x < pivot , l)

(* Tests for allLessThan *)
val [0,1,1,2] = allLessThan(3, [0,1,1,2,3,5])
val [1] = allLessThan(2, [1,2,3])
val [] = allLessThan(1, [1,2,3])
val [] = allLessThan(5, [])

(* Task 2.3 *)

(* Purpose: Given an int list l, evaluates to the permuation of l
            which is sorted in increasing order
   Examples: quicksort_l [1,4,5,2,3] => [1,2,3,4,5]
             quicksort_l [] => []
*)
fun quicksort_l (l : int list) : int list =
    case l of
        [] => []
      | [x] => [x]
      | x::xs =>
        let
            val left = filter ((fn y => y < x),xs)
            val right = filter ( (fn y => y >= x), xs)
        in
            quicksort_l left @ x :: quicksort_l right
        end

(* Tests for quicksort_l *)
val [] = quicksort_l []
val [1,2,3] = quicksort_l [3,2,1]
val [1,2,3,4,5] = quicksort_l [3,4,2,1,5]
val [0,1,1,5,5] = quicksort_l [1,5,1,5,0]
val [1,1,2,5,5] = quicksort_l [1,5,2,5,1]

(* Purpose: Given an int list l, evaluates to true
            iff. every int in l is positive (>0)
   Examples: allPos [] => true
             allPos [2,4,1] => true
             allPos [2,~1,3] => false
*)
fun allPos (l : int list) : bool =
    case l of
         [] => true
       | x :: xs => (x > 0) andalso allPos xs

(* Tests for allPos *)
val true = allPos [1,2,3]
val true = allPos [1]
val true = allPos []
val false = allPos [~1,1,2,3]
val false = allPos [1,2,3,0]

(* Purpose: Given a list of lists l and an int len, evaluates to true
            iff. every list in l is of length len
   Examples: allOfLength (7, []) => true
             allOfLength (1, [[1],[2],[3]] => true
             allOfLength (1, [[1],[1,2,3]] => false
*)
fun allOfLength (len : int, l : 'a list list) : bool =
     case l of
          [] => true
         | x :: xs => (inteq(List.length x, len)) andalso allOfLength(len, xs)

(* Tests for allOfLength *)
val true = allOfLength (1, [[1],[2],[3]])
val true = allOfLength (1, [])
val true = allOfLength (3, [[1,2,3],[4,5,6],[7,8,9]])
val false = allOfLength (1, [[1,2],[3,4]])
val false = allOfLength (2, [[1],[2],[3]])

(* Task 2.4 *)
(* Purpose: Given a list l and a predicate p, evaluates to
            true iff. p x for all x in l
   Examples: all(evenP, [2,4,6]) => true
             all(evenP, [1,2,3]) => false
             all((fn s => s="yes"), ["yes","yes","yes"]) => true
             all((fn s => s="yes"), ["yes","nope","yes"]) => false
*)
fun all (p : 'a -> bool, l: 'a list) : bool =
     case l of
         [] => true
       | x ::xs => (p x)  andalso all (p, xs)

(* Tests for all *)
val true = all(evenP, [2,4,6])
val false = all(evenP, [1,2,3])
val true = all((fn s => s="yes"), ["yes","yes","yes"])
val false = all((fn s => s="yes"), ["yes","nope","yes"])

(* Purpose: Given an int list l, evaluates to true
            iff. every int in l is positive (>0)
   Examples: allPos [] => true
             allPos [2,4,1] => true
             allPos [2,~1,3] => false
*)
fun allPos (l : int list) : bool = all (fn x => x > 0 , l)

(* Tests for allPos *)
val true = allPos [1,2,3]
val true = allPos [1]
val true = allPos []
val false = allPos [~1,1,2,3]
val false = allPos [1,2,3,0]

(* Purpose: Given a list of lists l and an int len, evaluates to true
            iff. every list in l is of length len
   Examples: allOfLength (7, []) => true
             allOfLength (1, [[1],[2],[3]] => true
             allOfLength (1, [[1],[1,2,3]] => false
*)
fun allofLength (len : int, l : 'a list list) : bool =
    all (fn l => inteq (List.length l , len), l)

(* Tests for allOfLength *)
val true = allOfLength (1, [[1],[2],[3]])
val true = allOfLength (1, [])
val true = allOfLength (3, [[1,2,3],[4,5,6],[7,8,9]])
val false = allOfLength (1, [[1,2],[3,4]])
val false = allOfLength (2, [[1],[2],[3]])

(* ---------------------------------------------------------------------- *)
(* trees *)

(* Task 3.1 *)
datatype 'a tree = Empty | Leaf of 'a | Node of 'a tree * 'a tree

(* Some trees for testing *)
val t1 = Node(Leaf(1),Leaf(2))
val t2 = Node(Leaf("1"),Leaf("2"))

val t3 = Node(Node(Leaf(0),Empty),Leaf(1))
val t4 = Node(Node(Leaf(1),Empty),Leaf(2))

val t5 = Node(Leaf(2),Leaf(4))
val t6 = Node(Node(Leaf(2),Empty),Leaf(4))
val t7 = Node(t1,t4)
val t8 = Node(t5,t6)

(* Task 3.2 *)
(* Purpose: Given an 'a tree t and a function 'a->'b f,
            evaluates to the tree t' equivalent to t, but with each
            x in t as f x
   Examples: treemap (Int.toString, Node(Leaf(1),Leaf(2)))
               => Node(Leaf("1"),Leaf("2"))
             treemap (Int.toString, Empty) => Empty
             treemap ((fn x => x+1), Node(Node(Leaf(0),Empty),Leaf(1))
               => Node(Node(Leaf(1),Empty),Leaf(2))
*)
fun treemap (f : 'a -> 'b , t : 'a tree) : 'b tree =
  case t of
    Empty => Empty
  | Leaf x => Leaf (f x)
  | Node (l, r) => Node (treemap (f, l), treemap (f, r))

(* Tests for treemap *)
val t2 = treemap (Int.toString, t1)
val Empty = treemap (Int.toString, Empty)
val t4 = treemap ((fn x => x+1), t3)

(* Purpose: Given a tree t and an int c, evaluates to the tree t',
            equivalent to t, but with each element multiplied by c
   Examples: treemult(2, Node(Leaf(1),Leaf(2))) => Node(Leaf(2),Leaf(4))
             treemult(6, Leaf(6)) => Leaf(36)
             treemult(7, Empty) => Empty
*)
fun treemult (c : int, t : int tree) : int tree = treemap (fn x => x * c, t)

(* Tests for treemult *)
val Empty = treemult (42, Empty)
val Leaf(36) = treemult(6, Leaf(6))
val t5 = treemult(2,t1)
val t8 = treemult(2,t7)

(* Task 3.3 *)
(* Purpose: Given a tree t and a predicate p, evaluates to
            true iff. p x for all x in t
   Examples: all(evenP, Node(Leaf(2),Leaf(4))) => true
             all(evenP, Leaf(3)) => false
             all((fn s => s="yes"), Node(Node(Leaf("yes"),Leaf("yes")),
                                         Leaf("yes")))
               => true
             all((fn s => s="yes"), Node(Leaf("yes"),
                                         Node(Leaf("nope"),Leaf("yes"))))
               => false
*)
fun treeall (p : 'a -> bool, t : 'a tree) : bool=
  case t of
    Empty => true
  | Leaf x => p x
  | Node (l, r) => treeall (p, l) andalso treeall (p, r)

(* Tests for treeall *)
val true = treeall(evenP, Node(Leaf(2),Leaf(4)))
val false = treeall(evenP, Leaf(3))
val true = treeall((fn s => s="yes"), Node(Node(Leaf("yes"),Leaf("yes")),
                                       Leaf("yes")))
val false = treeall((fn s => s="yes"), Node(Leaf("yes"),
                                        Node(Leaf("nope"),Leaf("yes"))))

(* Purpose: Given an int tree t, evaluates to true iff.
            all of its ints are nats
   Examples: nattree(Node(Leaf(2),Leaf(4))) => true
             nattree(Leaf(~3)) => false
*)
fun nattree (t : int tree) : bool = treeall (fn x => x > 0, t)

(* Tests for nattree *)
val true = nattree(Node(Leaf(2),Leaf(4)))
val false = nattree(Leaf(~3))
val false = nattree(t3)
val true = nattree(t7)
val true = nattree(t8)

(* reduce *)

(* From handout *)
fun sum (t : int tree) : int =
    case t of
        Empty => 0
      | Leaf x => x
      | Node(t1,t2) => (sum t1) + (sum t2)

fun max (t : int tree) : int =
    case t of
        Empty => 0
      | Leaf x => x
      | Node(t1,t2) => Int.max((max t1), (max t2))

(* Task 3.4 *)
(* Purpose: given a tree t, a combining function n, and a base value b,
            combines all elements of t into result value using n, where
            b is used as the value for Empty trees
   Examples: treereduce((fn (x,y) => x+y), 1, Empty) => 1
             treereduce((fn (x,y) => x+y), 0, Node(Leaf(1),Leaf(2))) => 3
             treereduce((fn (x,y) => x*y), 1, Node(Leaf(1),Leaf(2))) => 2
*)
fun treereduce (n : 'a * 'a -> 'a, b : 'a, t : 'a tree) =
  case t of
    Empty => b
  | Leaf x => x
  | Node (l, r) => n (treereduce (n, b, l), treereduce (n, b, r))

(* Tests for treereduce *)
val 1 = treereduce((fn (x,y) => x+y), 1, Empty)
val 3 = treereduce((fn (x,y) => x+y), 0, Node(Leaf(1),Leaf(2)))
val 2 = treereduce((fn (x,y) => x*y), 1, Node(Leaf(1),Leaf(2)))
val 12 = treereduce((fn (x,y) => x+y), 0, t8)

(* Some handy functions based on treereduce *)
fun sum (t : int tree) : int = treereduce (fn (x,y) => x + y , 0 , t)
fun max (t : int tree) : int = treereduce (Int.max , 0 , t)

(* mapreduce puzzles *)

fun treeFromList (l : 'a list) : 'a tree =
    case l of
        [] => Empty
      | [x] => Leaf x
      | _ => let
               val len = List.length l
             in
               Node (treeFromList (List.take (l, len div 2)),
                     treeFromList (List.drop (l, len div 2)))
             end

fun lines (s : string) : string tree =
    treeFromList (String.tokens (fn #"\n" => true | _ => false) s)

fun words (s : string) : string tree =
    treeFromList (String.tokens (fn #" " => true | #"\n" => true | _ => false) s)

(* Task 4.1 *)
(* Purpose: Given a string s, evaluates to the number of words in s
   Examples: wordcount "Hi" => 1
             wordcount "" => 0
             wordcount "Lorem ipsum dolor sit amet" => 5
*)
fun wordcount (s : string) : int =
    sum (treemap ((fn _ => 1), (words s)))

(* Tests for wordcount *)
val 1 = wordcount "Hi"
val 0 = wordcount ""
val 5 = wordcount "Lorem ipsum dolor sit amet"

(* Purpose: Given a string lines of words, evaluates to the number of
            words in the longest line
   Examples: longestline "hi" => 1
             longestline "15150\n15251\n15150 15251\n" => 2
             longestline "for life's not a paragraph\n
                          And death i think is no parenthesis\n" => 7
*)
fun longestline (s : string) : int =
    treereduce (Int.max, 0, (treemap (wordcount, (lines s))))

(* Tests for longestline *)
val 1 = longestline "hi"
val 2 = longestline "15150\n15251\n15150 15251\n"
val 7 = longestline "for life's not a paragraph\nAnd death i think is no parenthesis\n"
