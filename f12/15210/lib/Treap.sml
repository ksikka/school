functor Treap (HashKey : HASHKEY) : BST =
struct
  structure Key = HashKey
  type priority = int

  datatype 'a treap = TE | TN of {sz : int,
                                  pri : priority,
                                  key : Key.t,
                                  value : 'a,
                                  left : 'a treap,
	                          right : 'a treap}
  type 'a tree = 'a treap
  type 'a t = 'a tree

  type 'a node = {left : 'a tree, key : Key.t, value : 'a, right : 'a tree}

  fun empty () = TE

  fun size TE = 0
    | size (TN {sz=s, ...}) = s

  fun singleton (k,v) = 
    TN {sz = 1, pri = HashKey.hash k, key = k, value = v, left = TE, right = TE}

  fun expose TE = NONE
    | expose (TN {key = k, value = v, left = l, right = r, ...}) =
        SOME {key = k, value = v, left = l, right = r}

  fun join (TE, r) = r
    | join (l, TE) = l
    | join (n1 as TN {sz=s1, pri=p1, key=k1, value=v1, left=l1, right=r1},
            n2 as TN {sz=s2, pri=p2, key=k2, value=v2, left=l2, right=r2}) =
       case (p1 < p2) of
          true => TN {sz = s1+s2, pri=p1, value=v1, key=k1, 
                      left = l1, 
                      right = join(r1, n2)}
        | false => TN {sz=s1+s2, pri=p2, value=v2, key=k2, 
                       left = join(n1, l2),
                       right = r2}

  fun makeNode {left = l, key = k, value = v, right = r} =
      join(l, join(singleton(k,v), r))

  fun splitAt (tr, k) =
  let 
    fun makeNodeS (k,v,p,l,r) =
      TN {sz = 1 + size(l) + size(r), 
          pri=p, key=k, value=v, left=l, right=r}

    fun spl TE = (TE, NONE, TE)
      | spl (n1 as TN {sz=s1, pri=p1, key=k1, value=v1, left=l1, right=r1}) =
         case Key.compare(k,k1) of
            EQUAL => (l1, SOME(v1), r1)
          | LESS =>
              let val (l, m, r) = spl l1
              in (l, m, makeNodeS(k1,v1,p1,r,r1))
              end 
          | GREATER =>
              let val (l, m, r) = spl r1
              in (makeNodeS(k1,v1,p1,l1,l), m, r)
              end
   in
     spl tr
   end

end
