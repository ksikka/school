functor DictSet(D : DICT) : SET =
struct
  structure Element : ORDERED = D.Key
  type set = unit D.dict
  val empty = D.empty

  fun insert (d:set) (e:Element.t) : set = D.insert d (e,())

  fun remove (d:set) (e:Element.t) : set = D.remove d e

  fun member (d:set) (e:Element.t) : bool = 
    case D.lookup d e of
         NONE => false
       | _ => true
end
