(* ---------------------------------------------------------------------- *)
(* Functions provided by the course staff. *)

(* Purpose: max (x, y) ==> the greater of x or y
 * Examples:
 *  max (1, 4) ==> 4
 *  max (~4, 0) ==> 0
 *  max (2, 2) ==> 2
 *)
fun max (n1 : int, n2 : int) : int =
    case n1 < n2 of
      true => n2
    | false => n1
               
val 4 = max (1, 4)
val 0 = max (~4, 0)
val 2 = max (2, 2)

(*
   If l is non-empty, then there exist l1,x,l2 such that
      split l ==> (l1,x,l2) and
      l is l1 @ x::l2 and
      length(l1) and length(l2) differ by no more than 1
*)
fun split (l : int list) : (int list * int * int list) =
    case l of
      [] => raise Fail "split should never be called on an empty list"
    | _ => 
      let
        val midlen = (length l) div 2
        val front = (List.take (l,midlen))
        (* because we round down, if the list is non-empty,
         *  this has at least one thing in it *)
        val x :: back = (List.drop (l,midlen))  
      in
        (front, x, back)
      end


(* ---------------------------------------------------------------------- *)
(* Functions you, the student, need to implement. *)

(***** Section 2: Depth  *****)

datatype tree =
    Empty
  | Node of (tree * int * tree)

(* Task 2.1 *)

(* Purpose: Computes the depth of the tree. Empty trees are of depth 0;
 *   singletons are of depth 1.
 * Examples:
 * depth Empty ==> 0
 * depth (Node(Empty,1,Empty)) ==> 1
 * depth (Node(Node(Empty,2,Empty),1,Empty)) ==> 2
 *)
fun depth (t : tree) : int =
    case t of
      Empty => 0
    | Node (l, _ , r) => 1 + max (depth l, depth r)

val 0 = depth Empty
val 3 = depth (Node(Node(Node(Empty,5,Empty),2,Empty),1,Empty))


(* ---------------------------------------------------------------------- *)

(***** Section 3: Lists to Trees *****)

(* Task 3.1 *)
(* Purpose: transforms an int list into a balanced tree
 * listToTree [] ==> Empty
 * listToTree [1] ==> Node(Empty,1,Empty)
 * listToTree [1,2,3] ==> Node(Node(Empty,1,Empty),2,Node(Empty,3,Empty))
 *)
fun listToTree (l : int list) : tree =
    case l of
      [] => Empty
    | _ =>
      let val (l1, x,  l2) = split l
      in
        Node (listToTree l1, x , listToTree l2)
      end
      
val Empty = listToTree nil
val Node (Empty , 3 , Empty) = listToTree [3]
val Node(Node(Empty,5,Empty),8,Node(Empty,2,Empty)) = listToTree [5,8,2]



(* ---------------------------------------------------------------------- *)

(***** Section 4: Reverse *****)

(* Purpose: compute the list resulting from an in-order traversal of t *)
fun treeToList (t : tree) : int list =
    case t of
      Empty => []
    | Node (l,x,r) => treeToList l @ (x :: (treeToList r))

(* Task 4.1 *)

(* Purpose: Constructs the "mirror image" of the argument tree
 * Examples:
 * revT Empty ==> Empty
 * revT (Node(Empty,1,Empty)) ==> Node(Empty,1,Empty)
 * revT (Node(Empty,1,Node(Empty,6,Empty))) ==> Node(Node(Empty,6,Empty),1,Empty)
 *)
fun revT (t : tree) : tree =
    case t of
      Empty => Empty
    | Node (t1, x , t2) => Node (revT t2, x , revT t1)

val t1 = (Node(Node(Empty,15,Empty),8,Node(Empty,4,Empty)))
val [4,8,15] = treeToList (revT t1)
val [4,8,15] = rev (treeToList t1)
val Empty = revT Empty
val Node(Empty,1,Empty) = revT (Node(Empty,1,Empty))
val Node(Node(Empty,4,Empty),8,Node(Empty,15,Empty)) = revT t1

(* ---------------------------------------------------------------------- *)

(***** Section 4: Binary Search *****)

(* Task 5.1 *)

(* Purpose: Assuming t is sorted, determine whether x is in t.
            Work and span should be O(depth of t)
 * Examples:
 * binarySearch (Empty,4) ==> false
 * binarySearch (Node(Empty,8,Empty), 15) ==> false
 * binarySearch (Node(Empty,42,Empty), 42) ==> true
 * binarySearch (Node(Node(Empty,16,Empty),23,Empty), 23) ==> true
 *
 *)
fun binarySearch (t : tree, x : int) : bool =
    case t of
        Empty => false
      | Node (l, y, r) => (case Int.compare (x, y) of
                               EQUAL => true
                             | LESS => binarySearch (l, x)
                             | GREATER => binarySearch (r, x))

val t2 = Node (Node (Empty, 5, Empty), 6, Empty)
val t3 = Node (Node (Empty, 1, Empty), 2, Node (Empty, 3, Empty))

val true = binarySearch (t3, 3)
val false = binarySearch (t2, 3)
val false = binarySearch (Node (t3, 4, t2), 7)
val true = binarySearch (Node (t3, 4, t2), 6)

