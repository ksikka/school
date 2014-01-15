use "../lib.sml";
(* Task 4.1 *)
(* PURPOSE:
 *
 * given a list of integers l, computes a list with only those
 * elements of l that are in the appropriate relation to the
 * bound, where "appropriate" is determined by the rel r
 *
 * EXAMPLES:
 *  filter_l (nil,1,GEQ) ==> nil
 *  filter_l ([1,2,3,4,5],2,GEQ) ==> [2,3,4,5]
 *  filter_l ([42,5,13,83,1,1,34,3,5,2], 4, LT) ==> [1,1,3,2]
 *)

fun filter_l (l : int list, bound : int, r : rel) =
    case l of
        [] => []
      | x :: xs =>
            let val wantx = case r of LT => x < bound | GEQ => x >= bound
            in
                case wantx of
                    true => x :: filter_l(xs,bound,r)
                  | false => filter_l (xs,bound,r)
            end

val nil = filter_l(nil,1,GEQ)
val [2,3,4,5] = filter_l([1,2,3,4,5],2,GEQ)
val [1,1,3,2] = filter_l([42,5,13,83,1,1,34,3,5,2],4,LT)

(* Task 4.2 *)
(*PURPOSE:
*
* given a list of integers, computes a list with the same members that is
* sorted in increasing order.  uses the quicksort algorithm.
*
* EXAMPLES:
*  quicksort_l nil ==> nil
*  quicksort_l [2] ==> [2]
*  quicksort_l [44,1,43,9,20] ==> [1,9,20,43,44]
*)
fun quicksort_l (l : int list) =
    case l of
        [] => []
      | [x] => [x]
      | x::xs =>
        let
            val left = filter_l (xs,x,LT)
            val right = filter_l (xs,x,GEQ)
        in
            quicksort_l left @ x :: quicksort_l right
        end

val [3,4,5,6,7,8,9] = quicksort_l [9,8,7,6,5,4,3]
val nil = quicksort_l nil
val [2] = quicksort_l [2]
val [1,9,20,43,44] = quicksort_l [44,1,43,9,20]

(* Task 4.3 *)
(*PURPOSE:
*
* given two trees t1 and t2, combines them into one tree which contains
* every element of t1, every element of t2, and no other elements.
*
* EXAMPLES:
*  combine (Empty, Empty) ==> Empty
*  combine (Node(Empty,1,Empty), Node(Node(Empty,3,Empty),4,Empty))
           ==>Node(Empty,1,Node(Node(Empty,3,Empty),4,Empty))
*  combine (Node(Empty,3,Empty),Node(Empty,4,Empty))
           ==>Node(Empty,3,Node(Empty,4,Empty))
*)

(* long solution using a helper function to grab a leaf: *)

fun leftmostleaf (t : tree) : int * tree =
    case t
     of Empty => raise Fail "invariant violation"
      | Node (Empty , x , Empty) => (x, Empty)
      | Node (Empty , x , r) =>
        let
          val (first, rrest) = leftmostleaf r
        in
          (first, Node (Empty, x , rrest))
        end
      | Node (l , x , r) =>
        let
          val (first, lrest) = leftmostleaf l
        in
          (first, Node (lrest, x , r))
        end

fun combine (t1 : tree , t2 : tree) : tree =
    case t1 of
        Empty => t2
      | _ =>
        let
          val (first, t1rest) = leftmostleaf t1
        in
          Node (t1rest, first , t2)
        end

(* short solution: *)
fun combine (t1 : tree, t2 : tree) : tree =
    case t1 of
        Empty => t2
      | Node(l1,x1,r1) => Node(combine(l1,r1),x1,t2)

val Empty = combine (Empty, Empty)
val Node(Empty,1,Node(Node(Empty,3,Empty),4,Empty)) =
    combine (Node(Empty,1,Empty), Node(Node(Empty,3,Empty),4,Empty))
val Node(Empty,3,Node(Empty,4,Empty))=
    combine (Node(Empty,3,Empty),Node(Empty,4,Empty))

(* Task 4.5 *)
(*PURPOSE:
*
* given a tree of integers t, computes a tree with only those
* elements of t that are in the appropriate relation to the
* bound, where "appropriate" is determined by the rel which

*
* EXAMPLES:
*  filter (Empty,1,GEQ) ==> Empty
*  filter (Node(Empty,1,Node(Node(Empty,3,Empty),4,Empty)),
          2,GEQ) ==> Node(Node(Empty,3,Empty),4,Empty)
*  filter (Node(Empty,3,Node(Empty,4,Empty)),1,LT) ==> Empty
*)

fun filter (t : tree, bound : int, which : rel) =
    case t of
        Empty => Empty
      | Node (l,x,r) =>
            let val l' = filter (l, bound, which)
                val r' = filter (r, bound, which)

                val wantx = (case which of
                               LT => x < bound
                             | GEQ => x >= bound)
            in
                case wantx of
                    true => Node (l' , x , r')
                  | false => combine (l',r')
            end

val Empty = filter (Empty,1,GEQ)
val Node(Node(Empty,3,Empty),4,Empty)=
    filter (Node(Empty,1,Node(Node(Empty,3,Empty),4,Empty)),2,GEQ)
val Empty = filter (Node(Empty,3,Node(Empty,4,Empty)),1,LT)


(* Task 4.6 *)
(*PURPOSE:
*
* given a tree of integers, computes a tree with the same members that is
* sorted.
*
* EXAMPLES:
*  quicksort_t Empty ==> Empty
*  quicksort_t Node(Empty,1,Empty) ==> Node(Empty,1,Empty)
*  quicksort_t Node(Node(Empty,4,Empty),1,Node(Empty,0,Empty))
             ==> Node(Node(Empty,0,Empty),1,Node(Empty,4,Empty)
*)

fun quicksort_t (t : tree) : tree =
    case t of
        Empty => Empty
      | Node (l , x , r) =>
        let
          val landr = combine (l,r)
          val ls = filter (landr, x, LT)
          val gt = filter (landr, x, GEQ)
        in
          Node (quicksort_t ls, x , quicksort_t gt)
        end
val Empty = quicksort_t Empty
val Node(Empty,1,Empty) = quicksort_t (Node(Empty,1,Empty))
val Node(Node(Empty,0,Empty),1,Node(Empty,4,Empty)) =
     quicksort_t (Node(Node(Empty,4,Empty),1,Node(Empty,0,Empty)))


(* Task 5.1 *)
(*PURPOSE:
*
* Given a tree t and an int i, separates t into "left" and "right"
* subtrees such that the left subtree contains i elements of t, in
* order, and the right subtree contain the remaining elements of t,
* in their original order.
*
* EXAMPLES:
*  takeanddrop (Node(Empty,1,Empty),0) ==> (Empty,Node(Empty,1,Empty))
*  takeanddrop (Node(Node(Empty,4,Empty),1,Node(Empty,0,Empty)),2)
             ==> (Node(Node(Empty,4,Empty),1,Empty),
                 Node(Empty,0,Empty))
*)
fun takeanddrop (t : tree, i : int) : tree * tree =
    case (i,t) of
      (0,_) => (Empty, t)
    | (_,Empty) => raise Fail "not enough elts"
    | (_, Node (l , x , r)) =>
      (case i <= size l of
         true =>
         let
           val (l1 , l2) = takeanddrop (l , i)
         in
           (l1 , Node (l2 , x , r))
         end
       | false =>
         let
           val (r1 , r2) = takeanddrop (r , i - (size l) - 1)
         in
           (Node (l , x , r1), r2)
         end)

val (Empty,Node(Empty,1,Empty)) =  takeanddrop (Node(Empty,1,Empty),0)
val (Node(Node(Empty,4,Empty),1,Empty),
     Node(Empty,0,Empty))=
     takeanddrop (Node(Node(Empty,4,Empty),1,Node(Empty,0,Empty)),2)
val (Node(Node(Empty,1,Empty),2,Node(Empty,3,Empty)),
    Node(Empty,4,Node(Node(Empty,5,Empty),6,Empty))) =
    takeanddrop (Node(Node(Node(Empty,1,Empty),2,Node(Empty,3,Empty)),
    4,Node(Node(Empty,5,Empty),6,Empty)),3)

(* the rest of rebalance in terms of your takeanddrop *)

fun halves (t : tree) : tree * int * tree =
    let
      val (l , vr) = takeanddrop (t , (size t) div 2)
      val (Node (Empty, v , Empty) , r) = takeanddrop (vr , 1)
    in
      (l , v , r)
    end

fun rebalance (t : tree) : tree =
    case t
     of Empty => Empty
      | _ =>
        let
          val (l , x , r) = halves t
        in
          Node (rebalance l , x , rebalance r)
        end
