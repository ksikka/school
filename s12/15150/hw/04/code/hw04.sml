use "lib.sml";

(*              This is the tree to be used for tests.
 *                                 1
 *
 *                           2           3
 *
 *                    4        5        6       7
 *                        
 *               8    9    10   11   12   13   14    15
 *       depth = 3
 *       size = 15
 * *)
val tester = 
      Node
          (Node
             (Node (Node (Empty,8,Empty),4,Node (Empty,9,Empty)),2,
              Node (Node (Empty,10,Empty),5,Node (Empty,11,Empty))),1,
           Node
             (Node (Node (Empty,12,Empty),6,Node (Empty,13,Empty)),3,
              Node (Node (Empty,14,Empty),7,Node (Empty,15,Empty))))


(* Task 4.1 *)
(* Purpose: Given a list of ints, return a list of the ints which are either
 * less than or greater than p (Depending on the rel value)
 *
 * Examples: 
 *
 * val [1,0,1] = filter_l ([1,2,3,4,5,0,1,2,3], 2, LT)
 * val [] = filter_l ([5,6,7,8,9,10],4,LT)
 * val [] = filter_l ([],4,LT)
 * val [2,3,4,5,6] = filter_l ([~1,0,1,2,3,4,5,6],2,GEQ)
 *
 *)
fun filter_l (l : int list, p : int, r : rel) : int list = 
  case l of
       [] => []
     | x::xs => let val y = filter_l(xs,p,r)
                in case (r, x < p) of 
                         (LT,true) => x :: y
                      | (GEQ,false) => x :: y
                      | _ => y
                end
val [1,0,1] = filter_l ([1,2,3,4,5,0,1,2,3], 2, LT)
val [] = filter_l ([5,6,7,8,9,10],4,LT)
val [] = filter_l ([],4,LT)
val [2,3,4,5,6] = filter_l ([~1,0,1,2,3,4,5,6],2,GEQ)
                  
(* Task 4.2 *)
(* Purpose to use the quicksort algorithm to sort a list of integers.
 * 
 * Example: 
 *
 * val [0,1,2,3,4,6,6,9] = quicksort_l [1,6,3,6,9,0,4,2] 
 * val [~1,0,2,4,8] = quicksort_l [2,8,~1,4,0]
 * val [0] = quicksort_l [0]
 * val [] = quicksort_l []
 *
 * *)
fun quicksort_l (l : int list) : int list =
  case l of
       [] => []
     | x::xs =>
         (quicksort_l(filter_l(l,x,LT)))@(x::quicksort_l(filter_l((xs,x,GEQ))))

val [0,1,2,3,4,6,6,9] = quicksort_l [1,6,3,6,9,0,4,2] 
val [~1,0,2,4,8] = quicksort_l [2,8,~1,4,0]
val [0] = quicksort_l [0]
val [] = quicksort_l []

(* Task 4.3 *)
(* Purpose: To take two trees and return a tree which contains all the elements
 * in each individual tree.
 * Examples:
 * (Let tester be the tree tester defined at the top of this file.)
 *
 * combine(tester,tester)
 *
 * The above expression returns a tree which is twice the size of 
 * the tree called tester, and contains 2 occurances of each element in tester.
 *)
fun combine (t1 : tree, t2 : tree) : tree = 
  case t1 of
       Empty => t2
     | Node(l,x,r) => case t2 of
                           Empty => t1
                         | Node(l2,x2,r2) =>
                             Node(combine(l,r),x,combine(combine(Node(Empty,x2,Empty),l2),r2))
val result =
  Node
    (Node
       (Node
          (Node (Empty,8,Node (Empty,9,Empty)),4,
           Node (Node (Empty,10,Empty),5,Node (Empty,11,Empty))),2,
        Node
          (Node (Node (Empty,12,Empty),6,Node (Empty,13,Empty)),3,
           Node (Node (Empty,14,Empty),7,Node (Empty,15,Empty)))),1,
     Node
       (Node
          (Node (Node (Empty,8,Empty),4,Node (Empty,9,Empty)),2,
           Node (Node (Empty,10,Empty),5,Node (Empty,11,Empty))),1,
        Node
          (Node (Node (Empty,12,Empty),6,Node (Empty,13,Empty)),3,
           Node (Node (Empty,14,Empty),7,Node (Empty,15,Empty))))) 
val true = result = combine(tester,tester) (* good,bc every element exists twice. *)
val true = tester = combine(Empty,tester)
val true = tester = combine(tester,Empty)
val true = size(result) = size(tester) + size(tester) (* satisfies size requirement *)


(* Task 4.4 *)
(* Purpose: Takes a tree, a number, and a comparator. Returns a tree where every
 * node has a value which is LT or GEQ than the number, based on the comp.
 * Examples:
 *
 * filter(tester,4,LT)
 * filter(tester,4,GEQ)
 *
 * The first expression returns a tree where all elements are strictly less than
 * 4. The second expression returns a tree where all elements are greater than
 * or equal to 4.
 * *)
fun filter (t : tree, i : int, r : rel) : tree =
  case t of 
       Empty => Empty
     | Node(l,x,right) => case (r, x < i) of
                           (LT, true) => Node(filter(l,i,r),x,filter(right,i,r))
                         | (GEQ, false) => Node(filter(l,i,r),x,filter(right,i,r))
                         | _ => combine(filter(l,i,r),filter(right,i,r))

val true = Node (Node (Empty,2,Empty),1,Node (Empty,3,Empty)) = filter(tester,4,LT)
val true = Node
    (Node
       (Node (Empty,9,Empty),8,
        Node (Node (Empty,10,Empty),5,Node (Empty,11,Empty))),4,
     Node
       (Node (Empty,12,Node (Empty,13,Empty)),6,
        Node (Node (Empty,14,Empty),7,Node (Empty,15,Empty)))) = filter(tester,4,GEQ)
val true = Empty = filter(Empty,4,LT)
val true = Empty = filter(Empty,4,GEQ)
val true = Empty = filter(tester,24,GEQ)
val true = Empty = filter(tester,1,LT)


(* Task 4.6 
 * Purpose: To sort a tree using the quicksort algorithm.
 * Examples:
 *
 * quicksort(Empty) => Empty
 *
 * quicksort(tester)
 * (this is equal to listToTree([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15])
 *)
fun quicksort_t (t : tree) : tree =
  case t of
       Empty => Empty
     | Node(l,x,r) =>
         Node( quicksort_t(filter(t,x,LT)),
               x,
               quicksort_t(combine(filter(l,x,GEQ),filter(r,x,GEQ) )))

val true = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] = tolist (quicksort_t tester)
val Empty = quicksort_t Empty
val true = Node(Empty,1,Empty) = quicksort_t (Node(Empty,1,Empty))

(* Task 5.1 *)
(* Purpose: Given a tree and an int i, returns two trees. The first tree is the
 * bottom-left most subtree with i elements. The second tree is what remains
 * from the original tree.
 * Example:
 *
 * takeanddrop (tester,1) returns a tuple with the leaf-node 8, and the rest of
 * the tree. *)
fun takeanddrop (t : tree, i : int) : tree * tree = 
  case (t,i) of 
      (_,0) => (Empty,Empty)
    | (Empty,_) => raise Fail "Not enough elements"
    | (Node(l,x,r),_) => (case i <= size(l) of
                              true  => let val (take,drop) = takeanddrop(l,i)
                                       in (take, Node(drop,x,r))
                                       end
                            | false => let val (take,drop) = takeanddrop(r,i-size(l)-1)
                                       in (Node(l,x,take),drop)
                                       end)
val true = takeanddrop(tester,1) =
  (Node (Empty,8,Empty),
   Node
     (Node
        (Node (Empty,4,Node (Empty,9,Empty)),2,
         Node (Node (Empty,10,Empty),5,Node (Empty,11,Empty))),1,
      Node
        (Node (Node (Empty,12,Empty),6,Node (Empty,13,Empty)),3,
         Node (Node (Empty,14,Empty),7,Node (Empty,15,Empty)))))
val true = takeanddrop(tester,3) =
  (Node (Node (Empty,8,Empty),4,Node (Empty,9,Empty)),
   Node
     (Node (Empty,2,Node (Node (Empty,10,Empty),5,Node (Empty,11,Empty))),1,
      Node
        (Node (Node (Empty,12,Empty),6,Node (Empty,13,Empty)),3,
         Node (Node (Empty,14,Empty),7,Node (Empty,15,Empty)))))
(*- takeanddrop(tester,100);
uncaught exception Fail [Fail: Not enough elements]
  raised at: hw04.sml:178.26-178.52*)

(* the rest of rebalance interms of your takeanddrop *)
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
