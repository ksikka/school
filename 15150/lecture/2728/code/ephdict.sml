
signature ORDERED = 
sig
    type t
    val compare : t * t -> order
end

structure IntLt : ORDERED =
struct
    type t = int
    val compare = Int.compare
end

signature DICT =
sig
  structure Key : ORDERED
  type 'v dict

  val empty  : 'v dict
  val insert : 'v dict -> (Key.t * 'v) -> 'v dict
  val lookup : 'v dict -> Key.t -> 'v option
  val delete : 'v dict -> Key.t -> 'v dict 
end

signature EPH_DICT =
sig
  structure Key : ORDERED
  type 'v dict

  val mk_empty  : unit -> 'v dict
  val insert : 'v dict -> (Key.t * 'v) -> unit
  val lookup : 'v dict -> Key.t -> 'v option
  val delete : 'v dict -> Key.t -> unit
end

(* implementation next time *)

functor TreeDict(Key : ORDERED) : DICT =
struct

  structure Key : ORDERED = Key

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

  fun merge (l , r) = 
      case r of 
          Leaf => l
        | Node (r1 , x , r2) => Node (merge (l , r1) , x , r2)

  fun delete d k = 
      case d of 
          Leaf => Leaf
        | Node (l , (k',v'), r) => 
              (case Key.compare (k,k') of
                   LESS => Node (delete l k , (k',v'), r)
                 | GREATER => Node (l , (k',v'), delete r k) 
                 | EQUAL => merge (l , r))

end

structure Test = 
struct
    structure D = TreeDict(IntLt)
    val testDict = D.insert (D.insert (D.insert (D.insert D.empty (2,"")) (1,"")) (0,"")) (3,"")
end

functor EphFromPers (PersDict : DICT) : EPH_DICT =
struct

  structure Key : ORDERED = PersDict.Key

  datatype 'v eph_dict = Dict of 'v PersDict.dict ref
  type 'v dict = 'v eph_dict

  fun mk_empty () = Dict (ref (PersDict.empty))

  fun insert (Dict (d as ref t)) (k, v) =
      (d := PersDict.insert t (k, v))

  fun lookup (Dict (d as ref t)) k =
      PersDict.lookup t k

  fun delete (Dict (d as ref t)) k =
      (d := PersDict.delete t k)

end

functor EphDictHard (Key : ORDERED) : EPH_DICT =
struct

  structure Key : ORDERED = Key

  datatype 'v eph_dict = Dict of 'v dict_contents ref
       and 'v dict_contents = Empty | Node of 'v eph_dict * (Key.t * 'v) * 'v eph_dict
  type 'v dict = 'v eph_dict

  fun mk_empty () = Dict (ref Empty)

  fun insert (Dict t) (k, v) =
      case t of
	  ref Empty => t := Node (mk_empty (), (k, v), mk_empty ())
	| ref (Node (l, (k', v'), r)) =>
	  case Key.compare (k, k') of
	      LESS => insert l (k, v)
	    | EQUAL => t := Node (l, (k, v), r)
	    | GREATER => insert r (k, v)

  fun lookup (Dict t) k =
      case t of
	  ref Empty => NONE
	| ref (Node (l, (k', v'), r)) =>
	  case Key.compare (k, k') of
	      LESS => lookup l k
	    | EQUAL => SOME v'
	    | GREATER => lookup r k

  (* merge left into the right *)
  fun merge (l as Dict (ref lctnts) : 'v eph_dict) ((Dict r) : 'v eph_dict) = 
      case r of 
          ref Empty => r := lctnts
        | ref (Node (rl , x , rr)) => merge l rl

  fun delete (Dict t) k =
      case t of
          ref Empty => ()
        | ref (Node (l , (k',v') , r)) => 
              (case Key.compare (k,k') of
                   LESS => delete l k
                 | GREATER => delete r k
                 | EQUAL => let val () = merge l r
                                val Dict (ref rctnts) = r
                                val () = t := rctnts
                            in () end)


end

structure TestEph = 
struct
    structure D = EphDictHard(IntLt)
    val testDict = 
        let val d = D.mk_empty()
            val () = D.insert d (2,"")
            val () = D.insert d (1,"")
            val () = D.insert d (0,"")
            val () = D.insert d (3,"")
        in d end
end

