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

 (* Summorial 
  * Purpose: Return the sum of the first n 
  * natural numbers.
  * Examples:
  * 0 ==> 0
  * 4 ==> 10
  * 5 ==> 15 *)
 fun summ(n : int) : int =
   case n of 
        0 => 0
      | _ => summ(n-1)+n

 val 0 = summ(0)
 val 10 = summ(4)
 val 21 = summ(6)

(* Square
 * Purpose: to return the square of a natural number
 * Examples:
 * 0 ==> 0
 * 4 ==> 16
 * 8 ==> 64 *)
fun square(n : int) : int = 
  case n of
       0 => 0
     | _ => square(n-1) + double(n) - 1

val 0 = square(0)
val 16 = square(4)
val 64 = square(8)

(* oddP
 * Purpose: returns true if natural number is odd
 * returns false if natural number is even
 * Examples:
 * 3 ==> true
 * 16 ==> false
 * 101 ==> true *)
fun oddP(n : int) : bool = 
  case n of 
       0 => false
     | 1 => true
     | _ => oddP(n-2)
val true = oddP(3)
val false = oddP(16)
val true = oddP(101)

(* divisibleByThree
 * Purpose: returns true if the natural number 
 * is an integer multiple of 3, false if not.
 * Examples:
 * 3 ==> true
 * 16 ==> false
 * 102 ==> true *)
fun divisibleByThree(n : int) : bool = 
  case n of 
       0 => true
     | 1 => false
     | 2 => false
     | _ => divisibleByThree(n-3)
val true = divisibleByThree(3)
val false = divisibleByThree(16)
val true = divisibleByThree(102)

(* add
 * Purpose: returns the x+y where x is in N
 * Examples: 
 * 2,3 ==> 5
 * 4,5 ==> 9
 * 9,5 ==> 14 *)
fun add(x : int, y : int) : int = 
  case x of 
       0 => y
     | _ => add(x-1, y) + 1
val 5 = add(2,3)
val 5 = add(0,5)
val 5 = add(5,0)
val 144 = add(100,44)
