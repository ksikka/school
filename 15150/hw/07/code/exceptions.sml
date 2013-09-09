(* PURPOSE
 *
 * Given two ints, determines if
 * they are equal.
 *)
fun inteq (l1 : int , l2 : int) : bool =
    case Int.compare (l1,l2)
     of EQUAL => true
      | _ => false

(* PURPOSE
 *
 * Given a multiset and a target value,
 * returns SOME (a submultiset whose members
 *   sum to the target value) if there is
 * or NONE if not
 *)
fun subset_sum_op (l : int list, s : int) : int list option =
  case l of
    [] => (case inteq (s, 0) of
             true => SOME []
           | false => NONE)
  | x::xs => (case subset_sum_op (xs, s - x) of
                SOME c1 => SOME (x::c1)
              | NONE => subset_sum_op (xs , s))

(* Task 2.1 *)
(* PURPOSE
*
* given a multiset and a target value,
* returns a submultiset whose members sum to the target value if there is one,
* or raises NoSubset if not
*
* E.g. subset_sum_exn ([2,3,2], 4) ==> [2,2]
*      subset_sum_exn ([2,4,6], 7) raises NoSubset
*)
exception NoSubset
fun subset_sum_exn (l : int list, s : int) : int list =
  case l of
    [] => (case inteq (s, 0) of
             true => []
           | false => raise NoSubset)
  | x::xs => subset_sum_exn(xs, s) handle NoSubset => x::subset_sum_exn(xs,s-x)

  (* Tests *)
  val [2,2] = subset_sum_exn ([2,3,2], 4)
  val [~1] = subset_sum_exn ([2,4,6], 7) handle NoSubset => [~1]

(* Task 2.2 *)
(* PURPOSE
*
* given a multiset and a target value,
* raises Certificate with a submultiset whose members sum to the target value,
* if there is one, or returns () if not
*
* E.g. subset_sum_exn2 ([2,3,2], 4) raises (Certificate [2,2])
*      subset_sum_exn2 ([2,4,6], 7) ==> ()
*
*)

exception Certificate of int list
fun subset_sum_exn2 (l : int list, s : int) : unit =
  case l of
    [] => (case inteq (s, 0) of
             true => raise Certificate([])
           | false => ())
  | x::xs => let val () = subset_sum_exn2(xs,s) 
                 val () = subset_sum_exn2(xs,s-x) handle Certificate(y) => raise Certificate(x::y)
             in () 
             end

val NONE = (SOME (subset_sum_exn2 ([2,3,2],4))) handle Certificate([2,2]) => NONE
val () = subset_sum_exn2 ([2,4,6],7)
