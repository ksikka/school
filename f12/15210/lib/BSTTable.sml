functor BSTTable (structure Tree : BST
                  structure Seq : SEQUENCE) : TABLE =
struct
  structure TBL =
  struct
    structure Key = Tree.Key
    structure Seq = Seq
    type key = Key.t
    type 'a elt = key * 'a
    type 'a table = 'a Tree.t
    type 'a t = 'a table
    type 'a seq = 'a Seq.seq
    val empty = Tree.empty
    fun singleton(k:key,v) = Tree.singleton (k,v)
    val size = Tree.size

    fun mapk f T =
	case Tree.expose T of
	    NONE => empty ()
	  | SOME {key=k, value=v, left=l, right=r} =>
            Tree.makeNode {key=k, value=f (k,v), left=mapk f l, right=mapk f r}

    fun map f T = mapk (fn (_, v) => f v) T

    fun tabulate f S = mapk (fn (k, _) => f k) S

    fun domain T = map (fn v => ()) T

    fun reduce f ident T =
	case Tree.expose T of
	    NONE => ident
	  | SOME {key=k, value=v, left=l, right=r} =>
	    f(reduce f ident l, f(v, reduce f ident r))

    fun filter f T =
	case Tree.expose T of
	    NONE => empty ()
	  | SOME {key=k, value=v, left=l, right=r} =>
	    (case f (k,v)
	      of true => Tree.makeNode{key=k, value=v,
				       left=filter f l, right=filter f r}
	       | _ => Tree.join(filter f l, filter f r))

    fun iter f init T =
	case Tree.expose T of
	    NONE => init
	  | SOME {key=k, value=v, left=l, right=r} =>
	    iter f (f ((iter f init l), (k,v))) r

    fun iterh f init T =
	let
	    fun itr state T =
		case Tree.expose T of
		    NONE => (empty(), state)
		  | SOME {key=k, value=v, left=l, right=r} =>
		    let val (l', state') = itr state l
			val state'' = f (state',(k,v))
			val (r', state''') = itr state'' r
		    in (Tree.makeNode{key=k, value= state'', left=l', right=r'},
			state''')
		    end
	in
	    itr init T
	end

    fun find T k =
	case Tree.expose T of
	    NONE => NONE
	  | SOME {key=k', value=v, left=l, right=r} =>
            (case Key.compare(k, k')
	      of LESS => find l k
               | EQUAL => SOME(v)
               | GREATER => find r k)

    fun mergeOpt combine (t1,t2) =
	case Tree.expose t2 of
	    NONE => t1
	  | _ =>
            (case Tree.expose t1 of
		 NONE => t2
               | SOME {key=k1, value=v1, left=l1, right=r1} =>
		 let val (l2,m,r2) = Tree.splitAt(t2,k1)
		     val l = mergeOpt combine (l1, l2)
		     val r = mergeOpt combine (r1, r2)
		 in case m of
		     NONE => Tree.makeNode {key=k1, value=v1, left=l, right=r}
		   | SOME(v2) =>
		     (case combine(v1,v2) of
			  NONE => Tree.join(l,r)
			| SOME vv => Tree.makeNode
					 {key=k1, value=vv,
					  left=l, right=r})
		 end)

    fun merge combine (t1,t2) =
	mergeOpt (fn (v1,v2) => SOME(combine(v1,v2))) (t1,t2)

    fun extractOpt combine (t1,t2) =
	case Tree.expose t2
	 of NONE => empty ()
	  | _ =>
	    (case Tree.expose t1 of
		 NONE => empty ()
               | SOME {key=k1, value=v1, left=l1, right=r1} =>
		 let val (l2,m,r2) = Tree.splitAt(t2,k1)
		     val l = extractOpt combine (l1,l2)
		     val r = extractOpt combine (r1,r2)
		 in case m of
			NONE => Tree.join(l,r)
		      | SOME v2 =>
			(case combine(v1,v2)
			  of NONE => Tree.join(l,r)
			   | SOME vv => Tree.makeNode {key=k1, value=vv,
						       left=l, right=r})
		 end)


    fun extract (t1,t2) = extractOpt (fn (a,()) => SOME a) (t1,t2)

    fun erase (t1,t2) =
	case Tree.expose t2
	 of NONE => t1
	  | _ =>
	    (case Tree.expose t1
	      of NONE => empty ()
               | SOME {key=k1, value=v1, left=l1, right=r1} =>
		 let val (l2,m,r2) = Tree.splitAt(t2,k1)
		     val l = erase(l1,l2)
		     val r = erase(r1,r2)
		 in case m
		     of NONE => Tree.makeNode {key=k1, value=v1, left=l, right=r}
		      | SOME(_) => Tree.join(l,r)
		 end)

    fun insert combine kv T = merge combine (T, singleton kv)

    fun delete k T = erase (T,singleton(k,()))

 (*
  fun collect S
      case Seq.showt S
	 of Seq.EMPTY => empty()
	  | Seq.ELT (k,v) => singleton (k,Seq.singleton(v))
	  | Seq.NODE (l,r) => merge (fn (x,y) => (Seq.append(x,y)))
				    (collect l, collect r)
 *)

    fun fromSeq S =
	case Seq.showt S
	 of Seq.EMPTY => empty()
	  | Seq.ELT (k,v) => singleton (k, v)
	  | Seq.NODE (l,r) => merge (fn (x,y) => x) (fromSeq l, fromSeq r)

    fun collect S = fromSeq (Seq.collect Key.compare S)

    fun toSeq T =
	case Tree.expose T
	 of NONE => Seq.empty()
	  | SOME {key=k, value=v, left=l, right=r} =>
	    Seq.append (toSeq l, Seq.hidel (Seq.CONS ((k,v), toSeq r)))

    fun range T = Seq.map (fn (k,v) => v) (toSeq T)

    fun toString f T =
	Seq.toString (fn (k,v) => "(" ^ "_," ^ (f v) ^ ")") (toSeq T)
  end

  structure Set =
  struct
    type key = TBL.key
    type set = unit TBL.table
    type t = set
    structure Seq = TBL.Seq
    val (empty:set) = TBL.empty()
    fun singleton(k) = TBL.singleton(k,())
    val size = TBL.size
    fun filter f S = TBL.filter (fn (k,_) => f k) S
    fun iter f init S = TBL.iter (fn (b,(k,_)) => f(b,k)) init S
    fun find S k = case (TBL.find S k) of NONE => false | _ => true
    fun union (T1, T2) = TBL.merge (fn _ => ()) (T1, T2)
    fun intersection (T1, T2) = TBL.extract(T1,T2)
    fun difference (T1, T2) = TBL.erase(T1,T2)
    fun equal (M1,M2) =
	(size M1 = size M2) andalso (size M1 = size (intersection(M1,M2)))
    fun insert k T = TBL.insert (fn _ => ()) (k,()) T
    fun delete k T = TBL.delete k T
    fun fromSeq S = TBL.fromSeq (Seq.map (fn a => (a,())) S)
    fun toSeq S = Seq.map (fn (a,_) => a) (TBL.toSeq S)
    fun toString S = TBL.toString (fn x => "") S
  end

  open TBL
  type set = Set.set

end;



