functor BSTOrderedTable (structure Tree : BST
                         structure Seq : SEQUENCE) : ORD_TABLE =
struct

structure Table = BSTTable(structure Tree = Tree
                           structure Seq = Seq)
open Table

structure Key = Tree.Key
type key = Key.t

exception NYI

fun first T =
    case Tree.expose T of
	NONE => NONE
      | SOME {key=k, value=v, left=l, right=r} =>
	case first l of
	    NONE => SOME (k, v)
	  | kv => kv

fun last T =
    case Tree.expose T of
	NONE => NONE
      | SOME {key=k, value=v, left=l, right=r} =>
	case last r of
	    NONE => SOME (k, v)
	  | kv => kv
		 
fun previous T k = 
    let
	fun prev(T, anc_kv) = 
	    case Tree.expose T of
		NONE => anc_kv
	      | SOME {key=k', value=v', left=l, right=r} =>
		case Key.compare(k, k') of
		    LESS => prev (l, anc_kv)
		  | EQUAL => (case last l of
				  NONE => anc_kv
				| child_kv => child_kv)
		  | GREATER => prev (r, SOME(k',v'))
    in
	prev(T, NONE)
    end

fun next T k = 
    let
	fun next'(T, anc_kv) = 
	    case Tree.expose T of
		NONE => anc_kv
	      | SOME {key=k', value=v', left=l, right=r} =>
		case Key.compare(k, k') of
		    LESS => next' (l, SOME(k',v'))
		  | EQUAL => (case first r of
				  NONE => anc_kv
				| child_kv => child_kv)
		  | GREATER => next' (r, anc_kv)
    in
	next'(T, NONE)
    end

fun join (l, r) = Tree.join (l, r)

fun split (T, k) = Tree.splitAt(T, k)
		   
(* assumes low <= high *)   

fun getRange T (low, high) = 
    let
	val (_, ml, T') = Tree.splitAt (T, low)
	val (T'', mh, _) = Tree.splitAt (T', high)
	fun toTree (k, opt) = 
	    case opt of
		NONE => empty()
	      | SOME v => Tree.singleton (k,v)
    in
	join (toTree (low, ml), join (T'', toTree (high, mh)))   
    end 
end
