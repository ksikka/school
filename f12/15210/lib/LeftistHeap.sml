functor LeftistHeap (Key : ORDERED) : PRIORITY_QUEUE =
struct
  structure Key = Key
  type key = Key.t

  datatype 'a pq = Empty 
                 | Node of {rank : int, value: key * 'a, 
	                    left : 'a pq, right : 'a pq} 
  type 'a t = 'a pq

  fun cmp((k1,v1),(k2,v2)) = Key.compare(k1,k2)

  exception EMPTY

  fun empty () = Empty
  fun isEmpty Empty = true 
    | isEmpty _ = false

  fun rnk Empty = 0
    | rnk (Node {rank=r,...}) = r

  fun node (v, l, r) =
    if (rnk r < rnk l)
    then Node {rank = 1 + rnk r, value=v, left=l, right=r}
    else Node {rank = 1 + rnk l, value=v, left=r, right=l}

  fun meld a Empty = a
    | meld Empty b = b
    | meld (n1 as Node {value=v1, left=l1, right=r1, ...})
	   (n2 as Node {value=v2, left=l2, right=r2, ...}) =
        case cmp(v1, v2) of 
           LESS => node (v1, l1, meld r1 n2)
         | _    => node (v2, l2, meld n1 r2)

  fun singleton(k,v) = Node {rank=1, value=(k,v), left=Empty, right=Empty}

  fun insert v Q = meld (singleton v) Q

  fun findMin Empty = NONE
    | findMin (Node {value=v, ...}) = SOME(v)

  fun deleteMin Empty = (NONE,Empty)
    | deleteMin (Node {value=v, left=l, right=r, ...}) = (SOME(v), meld l r)
end
