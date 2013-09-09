(* Signature for the Ordered Table abstract data type *)
signature ORD_TABLE =
sig
  include TABLE 

 (* Given an ordered table T, first evaluates to SOME(k,v) if 
    (k,v) is in T and k is the minimum key in T. Otherwise, it evaluates
    to NONE. *)
  val first : 'a table -> (key * 'a) option

  (* Given an ordered table T, last evaluates to SOME(k,v) if 
     (k,v) is in T and k is the maximum key in T. Otherwise, it
     evaluates to NONE. *)
  val last : 'a table ->  (key * 'a) option

  (* Given an ordered table T and a key k, previous evaluates to
    SOME(k',v') if (k',v') is in T and k' is the largest key in T less
    than k. Otherwise, it evaluates to NONE. *)
  val previous : 'a table -> key -> (key * 'a) option

  (* Given an ordered table T and a key k, next evaluates to
     SOME(k',v') if (k',v') is in T and k' is the smallest key in T greater
     than k. Otherwise, it evaluates to NONE. *)
  val next : 'a table -> key -> (key * 'a) option

  (* Given an ordered table T and a key k, split evaluates to a triple
     consisting of 
     1) an ordered table containing all (k',v) in T such that k' < k, 
     2) SOME(v) if (k,v) is in T and NONE otherwise, and 
     3) an ordered table containing all (k',v) in T such that k' > k *)
  val split : 'a table * key -> 'a table * 'a option * 'a table

  (* Given two ordered tables T1 and T2, where all the keys in T1 are
     less than all the keys in T2, join evaluates to an ordered table
     that is the union of T1 and T2.*)
  val join : 'a table * 'a table -> 'a table
  
  (* Given a table T and keys lo and hi, getRange evaluates to an ordered
     table of all (k,v) in T such that lo <= k <= hi *)
  val getRange : 'a table -> key * key ->'a table 
end
