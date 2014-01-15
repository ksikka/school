signature ORDERED = 
sig
    type t
    val compare : t * t -> order 
end

structure StringLt : ORDERED = 
struct
    type t = string
    val compare = String.compare 
end


signature SORT =
sig

    structure El : ORDERED
    val sort : El.t Seq.seq -> El.t Seq.seq

end
(* functor Sort(E : ORDERED) : SORT *)


signature SEQUTILS =
sig
    val words : string -> string Seq.seq
    val seq : 'a list -> 'a Seq.seq
    val s2l : 'a Seq.seq -> 'a list

    val explode : string -> char Seq.seq
    val implode : char Seq.seq -> string
end 
(* structure SeqUtils : SEQUTILS *)


signature DICT =
sig
  structure Key : ORDERED
  type 'v dict 

  val empty  : 'v dict
  val insert : 'v dict -> (Key.t * 'v) -> 'v dict
  val lookup : 'v dict -> Key.t -> 'v option
  val map    : ('a -> 'b) -> 'a dict -> 'b dict

  (* split d k ==> (d1 , vo , d2) where
     d1 is the dictionary containing all keys less than k
     d2 is the dictionary containing all keys greater than k
     vo is SOME v if k |-> v is in d 
           NONE otherwise
           *)
  val split  : 'v dict -> Key.t -> 'v dict * 'v option * 'v dict

  (* merge combine (d1,d2) == d where
     - k in d if and only if k is in d1 or k is in d2
     - If k~v in d1 and k is not in d2, then k ~ v in d
     - If k~v in d2 and k is not in d1, then k ~ v in d
     - If k~v1 in d1 and k~v2 in d2, then k ~ combine (v1, v2) in d
     *)
  val merge  : ('v * 'v -> 'v) -> 'v dict * 'v dict -> 'v dict
      
  val fromSeq :  (Key.t * 'v) Seq.seq -> 'v dict (* for duplicates, earlier keys win *)

  (* computes the sequence of all (key,value) pairs in the dictionary *)
  val toSeq : 'v dict -> (Key.t * 'v) Seq.seq  

  (* computes the sequence of all values in the dictionary *)
  val valueSeq : 'v dict -> 'v Seq.seq  
end
(* functor Dict(K : ORDERED) : DICT *)


signature SET =
sig
  structure El : ORDERED
  type set 

  val empty  : set
  val insert : set -> El.t -> set
  val member : set -> El.t -> bool
  val union  : set * set -> set
      
  val fromSeq :  El.t Seq.seq -> set (* for duplicates, earlier keys win *)
  val toSeq    : set -> El.t Seq.seq
end
(* functor Set(E : ORDERED) : SET *)
