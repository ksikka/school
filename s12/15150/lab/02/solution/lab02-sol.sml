(* Purpose: double the number n
 * Examples:
 * double 0 ==> 0
 * double 2 ==> 4
 *)
fun double (n : int) : int =
    case n of
      0 => 0
    | _ => 2 + double (n - 1)

(* Tests for double *)
val 0 = double 0
val 4 = double 2

(* Purpose: calculate the sum of the natural numbers from 0 to n
 * Examples:
 * summ 0 ==> 0
 * summ 2 ==> 3
 *)
fun summ (n : int) : int =
    case n of
      0 => 0
    | _ => n + (summ (n - 1))

(* Tests for summ *)
val 0 = summ 0
val 3 = summ 2

(* Purpose: calculate the product of n with itself
 * Examples:
 * square 0 ==> 0
 * square 3 ==> 9
 *)
fun square (n : int) : int =
    case n of
      0 => 0
    | _ => square (n - 1) + double n - 1

(* Tests for square *)
val 0 = square 0
val 9 = square 3

(* Purpose: determine whether the number is even
 * Examples:
 * evenP 0 ==> true
 * evenP 3 ==> false
 * evenP 12 ==> true
 * evenP 27 ==> false
*)
fun evenP (n : int) : bool =
    case n of
      0 => true
    | 1 => false
    | _ => evenP (n - 2)

(* Tests for evenP *)
val true = evenP 0
val false = evenP 1
val true = evenP 12
val false = evenP 27

(* Purpose: determine whether the number is odd
 * Examples:
 * oddP 0 ==> false
 * oddP 3 ==> true
 * oddP 12 ==> false
 * oddP 27 ==> true
 *)
fun oddP (n : int) : bool =
    case n of
      0 => false
    | 1 => true
    | _ => oddP (n - 2)

(* Tests for oddP *)
val false = oddP 0
val true = oddP 1
val false = oddP 12
val true = oddP 27

(* Purpose: determine whether a natural number is divisible by 3

   Examples:
   divByThree 0 ==> true
   divByThree 1 ==> false
   divByThree 2 ==> false
   divByThree 3 ==> true
*)
fun divByThree (n : int) : bool =
    case n of
        0 => true
      | 1 => false
      | 2 => false
      | _ => divByThree (n - 3)

val true  = divByThree 0
val false = divByThree 1
val false = divByThree 2
val true = divByThree 3
val true = divByThree 9
val false = divByThree 11

(* Purpose: calculate the sum of x and y
 * Examples:
 * add (0, 7) ==> 7
 * add (3, 3) ==> 6
 * add (8, 0) ==> 8
*)
fun add (x : int, y : int) : int =
    case x of
      0 => y
    | _ => 1 + add (x - 1, y)

(* Tests for add *)
val 7 = add (0, 7)
val 6 = add (3, 3)
val 8 = add (8, 0)


