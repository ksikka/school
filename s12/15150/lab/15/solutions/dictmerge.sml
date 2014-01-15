structure SeqUtils : SEQUTILS =
struct

    fun s2l s = Seq.mapreduce (fn x => [x]) [] op@ s
    fun seq l = List.foldr (fn (x,y) => Seq.cons x y) (Seq.empty()) l

    fun words (s : string) : string Seq.seq = 
        (* String.tokens shoudl return a sequence *)
        seq (String.tokens (fn s => s = #" ") s)

end

functor TreeDict(Key : ORDERED) : DICT =
struct

  structure Key : ORDERED = Key

  (* invariant: sorted according to Key.compare *)
  datatype 'v tree =
      Leaf
    | Node of 'v tree * (Key.t * 'v) * 'v tree

  type 'v dict = 'v tree 

  val empty = Leaf

  fun lookup d k =
    case d of
      Leaf => NONE
    | Node (L, (k', v'), R) =>
          case Key.compare (k,k') of
              EQUAL => SOME v'
            | LESS => lookup L k
            | GREATER => lookup R k
                  
  fun insert d (k, v) =
    case d of
      Leaf => Node (empty, (k,v), empty)
    | Node (L, (k', v'), R) =>
      case Key.compare (k,k') of
          EQUAL => Node (L, (k, v), R)
        | LESS => Node (insert L (k, v), (k', v'), R)
        | GREATER => Node (L, (k', v'), insert R (k, v))

  fun map f d = 
      case d of
          Leaf => Leaf
        | Node(l,(k,v),r) => Node (map f l , (k, f v) , map f r)

  fun split d k = 
      case d of 
          Leaf => (Leaf , NONE , Leaf)
        | Node (l , (k',v') , r) => 
              (case Key.compare (k,k') of
                   EQUAL => (l , SOME v' , r)
                 | LESS => let val (ll , vo , lr) = split l k 
                           in (ll , vo , Node (lr , (k',v') , r)) end
                 | GREATER => let val (rl , vo , rr) = split r k 
                              in (Node (l , (k',v') , rl) , vo , rr) end)

  fun merge c (d1, d2) = 
    case d1 of 
        Leaf => d2
      | Node (l1 , (k,v1) , r1) =>
            let val (l2 , v2o , r2) = split d2 k 
            in
                Node (merge c (l1, l2) , 
                      (k , case v2o of NONE => v1 | SOME v2 => c (v1,v2)), 
                      merge c (r1, r2))
            end

  fun fromSeq s =
      Seq.mapreduce (fn (k,v) => insert empty (k,v)) empty (merge (fn(v1,v2) => v1)) s

  fun toSeq d =
      case d of
          Leaf => Seq.empty()
        | Node (l , x , r) => Seq.append (toSeq l) (Seq.cons x (toSeq r))
        
end

functor Dict(K : ORDERED) = TreeDict(K)

functor Set(E : ORDERED) : SET = 
struct

    structure El = E
    structure D = Dict(El)

    type set = unit D.dict

    val empty = D.empty
    fun insert s e = D.insert s (e,())
    fun member s e = 
        case D.lookup s e of
            SOME _ => true
          | NONE => false
    fun union (s1,s2) = D.merge (fn _ => ()) (s1,s2)
    val fromSeq = D.fromSeq o (Seq.map (fn x => (x,())))
    fun toSeq s = (Seq.map #1 o D.toSeq) s

end

functor Sort(E : ORDERED) : SORT =
struct

    structure El = E

    (* totally hacky: relies on the fact that TreeDict.tolist is in order *)
    structure D = TreeDict(E)
    fun sort s = 
        let val d = Seq.mapreduce (fn x => D.insert D.empty (x, 1))
                                  D.empty
                                  (D.merge (op+)) s
        in 
            Seq.flatten (Seq.map (fn (item,multiplicity) => Seq.repeat multiplicity item)
                         (D.toSeq d))
        end
end
