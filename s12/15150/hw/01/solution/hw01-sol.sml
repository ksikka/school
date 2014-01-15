(*
   Purpose: double the number n
            assumes n >= 0

   Examples:
   double 0 ==> 0
   double 3 ==> 6
*)

fun double (n : int) : int =
    case n of
        0 => 0
      | _ => 2 + (double (n - 1))

(*
   Purpose: compute n! = n * (n-1) * (n-2) * ... * 1
            assumes n >= 0

   Examples:
   fact 0 ==> 1
   fact 5 ==> 120
   Invariants: n >= 0
*)

fun fact (n : int) : int =
    case n of
        0 => 1
      | _ => n * (fact (n - 1))

(*
   Purpose: quadruple the number n
            assumes n >= 0

   Examples:
   triple 0 ==> 0
   triple 3 ==> 9
*)

fun triple (n : int) : int =
    case n of
        0 => 0
      | _ => 3 + (triple (n - 1))

val 9 = triple 3
val 0 = triple 0
