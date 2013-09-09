fun inteq(x:int,y:int) = case Int.compare (x,y) of EQUAL => true | _ => false

(* PURPOSE
 *
 * given a multiset and a target value, 
 * returns SOME (a submultiset whose members sum to the target value) if there is one,  
 * or NONE if not
 *)
fun subset_sum_op (l : int list, s : int) : int list option =
    case l
        of [] => (case inteq (s, 0) of
                      true => SOME []
                    | false => NONE)
      | x::xs => (case subset_sum_op (xs, s - x) of 
                      SOME c1 => SOME (x::c1)
                    | NONE => subset_sum_op (xs , s))

val SOME nil = subset_sum_op (nil, 0)
val NONE = subset_sum_op (nil, 7)
val SOME (2::2::nil) = subset_sum_op (2::3::2::nil, 4)
val NONE = subset_sum_op (2::4::6::nil, 7)

(* PURPOSE
 *
 * given a multiset and a target value, 
 * returns a submultiset whose members sum to the target value if there is one,  
 * or raises NoSubset if not
 *
 * E.g. subset_sum_exn ([2,3,2], 4) ==> [2,2]
 *      subset_sum_exn ([2,4,6], 7) raises NoSubset
 *
 *)
exception NoSubset
fun subset_sum_exn (l : int list, s : int) : int list =
    case l
        of [] => (case inteq (s, 0) of
                      true => []
                    | false => raise NoSubset)
      | x::xs => (x :: subset_sum_exn (xs, s - x))
                 handle NoSubset => subset_sum_exn (xs , s)

val nil = subset_sum_exn (nil, 0)
val (2::2::nil) = subset_sum_exn (2::3::2::nil, 4)
val NONE = SOME (subset_sum_exn (nil, 7)) handle NoSubset => NONE
val NONE = SOME (subset_sum_exn (2::4::6::nil, 7)) handle NoSubset => NONE

(* PURPOSE
 *
 * given a multiset and a target value, 
 * raises Certificate with a submultiset whose members sum to the target value, if there is one,  
 * or returns () if not 
 *
 * E.g. subset_sum_exn ([2,3,2], 4) raises (Certificate [2,2])
 *      subset_sum_exn ([2,4,6], 7) ==> ()
 * 
 *)
exception Certificate of int list 
fun subset_sum_exn2 (l : int list, s : int) : unit =
    case l
        of [] => (case inteq (s, 0) of
                      true => raise Certificate []
                    | false => ())
      | x::xs => 
            let
                val () = (subset_sum_exn2 (xs, s - x)) handle Certificate c => raise Certificate (x :: c)
            in 
                subset_sum_exn2 (xs,s)
            end

val SOME nil = (let val x = (subset_sum_exn2 (nil, 0)) in NONE end) handle Certificate x => SOME x
val SOME (2::2::nil) = (let val x = subset_sum_exn2 (2::3::2::nil, 4) in NONE end) handle Certificate x => SOME x
val () = subset_sum_exn2 (nil, 7)
val () = subset_sum_exn2 (2::4::6::nil, 7)

