
(* Purpose: reverse l in O(length l) time *)
local
    fun revTwoPiles (l : int list, r : int list) : int list = 
        case l of 
            [] => r
          | (x :: xs) => revTwoPiles(xs , x :: r)
in
    fun reverse (l : int list) : int list = revTwoPiles(l , [])
end

(* ---------------------------------------------------------------------- *)

(* Purpose: insert n in sorted order into l.  
            If l is sorted, then insert(n,l) ==> l' where
               l' is sorted and
               l' is a permutation of n :: l
*)
fun insert (n : int , l : int list) : int list = 
    case l of 
        [] => n :: []
      | (x :: xs) => (case n < x of
                          true => n :: (x :: xs)
                        | false => x :: (insert (n , xs)))

val [ 1 , 2 , 3 , 4 , 5] = insert (4 , [ 1, 2, 3, 5])

(* Purpose: sort l
            For all l, isort l ==> l' where
              l' is sorted (in increasing order) and a permutation of l
*)
fun isort (l : int list) : int list = 
    case l of 
        [] => []
      | (x :: xs) => insert (x , isort xs)
            
val [ 1 , 2 , 3 , 4 , 5] = isort [ 5, 1 , 4 , 3, 2] 

(* ---------------------------------------------------------------------- *)


(* Purpose: deal the list into two piles *)
fun split (l : int list) : int list * int list = 
    case l of 
        [] => ([] , [])
      | [ x ] => ([ x ] , [])
      | x :: y :: xs => let val (pile1 , pile2) = split xs
                        in (x :: pile1 , y :: pile2)
                        end
val ([1,3],[2,4]) = split [1,2,3,4]

(* Purpose: merge two sorted lists into one *)
fun merge (l1 : int list , l2 : int list) : int list = 
    case (l1 , l2) of
        ([] , l2) => l2
      | (l1 , []) => l1
      | (x :: xs , y :: ys) => 
            (case x < y of
                 true => x :: (merge (xs , l2))
               | false => y :: (merge (l1 , ys)))
val [1,2,3,4] = merge ([1,3],[2,4])

(* Purpose: sort the list in O(n log n) work *)
fun mergesort (l : int list) : int list = 
    case l of
        [] => []
      | [x] => [x]
      | _ => let val (pile1,pile2) = split l 
             in
                 merge (mergesort pile1, mergesort pile2)
             end
val [1,2,3,4,5] = mergesort [5,3,2,1,4]

