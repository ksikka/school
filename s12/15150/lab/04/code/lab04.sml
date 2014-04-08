(* ---------------------------------------------------------------------- *)
(* Functions provided by the course staff. *)

(* Purpose: max (x, y) ==> the greater of x or y
 * Examples:
 *  max (1, 4) ==> 4
 *  max (~4, 0) ==> 0
 *  max (2, 2) ==> 2
 *)
fun max (n1 : int, n2 : int) : int =
    case Int.compare(n1,n2)
     of LESS => n2
      | _ => n1

val 4 = max (1, 4)
val 0 = max (~4, 0)
val 2 = max (2, 2)

(*
   If l is non-empty, then there exist l1,x,l2 such that
      split l == (l1,x,l2) and
      l == l1 @ x::l2 and
      length(l1) and length(l2) differ by no more than 1
*)
fun split (l : int list) : (int list * int * int list) =
    case l of
        [] => raise Fail "split should never be called on an empty list"
      | _ => let
                 val midlen = (length l) div 2
                 val front = (List.take (l,midlen))

                 (* because we round down, if the list is non-empty, this
                  * has at least one thing in it
                  *)
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

fun depth (t : tree) : int = 
	case t of
		Empty => 0
		| Node(l,x,r) => 1 + max(depth(l),depth(r))

(* ---------------------------------------------------------------------- *)

(***** Section 3: Lists to Trees *****)

(* Task 3.1 *)

fun listToTree (l : int list) : tree =
	case l of 
		[] => Empty
		| x::xs => let val (leftlist, n, rightlist) = split(l)
                   in Node(listToTree(leftlist),n,listToTree(rightlist))
                   end

val 3 = depth(listToTree([1,2,3,4,5,6]))

(* ---------------------------------------------------------------------- *)

(***** Section 4: Reverse *****)

(* Purpose: compute a list of the elements in the tree, 
            ordered by an in-order traversal *)
fun treeToList (t : tree) : int list =
    case t of
        Empty => []
      | Node (l,x,r) => treeToList l @ (x :: (treeToList r))

(* Task 4.1 *)
fun revT (t : tree) : tree =
    case t of 
        Empty => Empty
        | Node(l,x,r) => Node(revT(r),x,revT(l))
val [6,5,4,3,2,1] = treeToList(revT(listToTree([1,2,3,4,5,6])))

(* ---------------------------------------------------------------------- *)

(***** Section 5: Binary Search *****)

(* Task 5.1 *)

fun binarySearch (t : tree, x : int) : bool = raise Fail "Unimplemented"
