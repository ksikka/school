(* Purpose: returns true if n is even, false otherwise.
   Assumes n is a natural number *)
fun evenP (n : int) : bool =
    case n
     of 0 => true
      | 1 => false
      | _ => evenP (n-2)

(* Purpose: returns true if n is odd, false otherwise.
   Assumes n is a natural number *)
fun oddP (n : int) : bool =
    case n
     of 0 => false
      | 1 => true
      | _ => oddP (n-2)

(* Purpose: returns m + n. Assumes m and n are natural numbers. *)
fun add (m : int, n : int) =
  case m of
    0 => n
  | _ => 1 + (add (m - 1, n))

(* Task 3.1: Implement and document this function. *)
(* Purpose: Multiplies two natural numbers, m and n. 
 * For maximum efficiency, use such that m <= n.
 *
 * Examples:
 * mult (1,6) ==> 6
 * mult (6,1) ==> 6
 * mult (2,3) ==> 6
 * mult (100,0) ==> 0
 * mult (0,100) ==> 0  *)
fun mult (m : int, n : int) : int =
  case m of 
       0 => 0
     | 1 => n
     | _ => add(n, mult(m-1,n))
val 6 = mult (1,6)
val 6 = mult (6,1)
val 6 = mult (2,3)
val 0 = mult (100,0)
val 0 = mult (0,100)

(* Task 3.3: Implement and document this function. *)
(* Purpose: To compute the partial sum of the first n numbers
*           in the harmonic series, where N is a natural number.
*
*  Examples:
*  harmonic 0 ==> 0
*  harmonic 1 ==> 1
*  harmonic 2 ==> 3/2
*  harmonic 3 ==> 11/6  *)
fun harmonic (n : int) : real =
    case n of 
         0 => 0.0
       | _ => harmonic(n-1) + 1.0 / real(n) (* n will not be zero here *)

val true = Real.==(harmonic 1, 1.0)
val true = Real.==(harmonic 0, 0.0)
val true = Real.==(harmonic 3, 11.0 / 6.0)


(* Task 3.5: Implement and document this function. *)
(* Purpose: To compute the partial sum of the first n numbers
 * in the alternating harmonic series, where N is a natural number.
 *
 * Examples:
 * altharmonic 0 ==> 0
 * altharmonic 1 ==> 1
 * altharmonic 2 ==> 1/2
 * altharmonic 3 ==> 5/6   *)
fun altharmonic (n : int) : real =
    case n of 
         0 => 0.0
       | _ => case evenP(n) of 
                   true => ~1.0/real(n) + altharmonic(n-1)
                 | false => 1.0/real(n) + altharmonic(n-1)
val true = Real.==(1.0, altharmonic(1))
val true = Real.==(0.5, altharmonic(2))
val true = Real.==(altharmonic(3), 1.0/3.0 + altharmonic(2))

(* Task 3.6: Implement and document these functions. *)
(* Purpose: A helper caused by altharmonic2 which differs 
 * from altharmonic2 in the way that it gets the parity of n
 *
 * Examples:
 * altharmonicHelper (0, even) ==> 0
 * altharmonicHelper (1, odd)  ==> 1
 * altharmonicHelper (2, even) ==> 1/2
 * altharmonicHelper (3, odd)  ==> 5/6   *)
fun altharmonicHelper (n : int, even : bool) : real =
    case n of 
         0 => 0.0
       | _ => case even of 
                   true => ~1.0/real(n) + altharmonicHelper(n-1, false)
                 | false => 1.0/real(n) + altharmonicHelper(n-1,true)

(* Purpose: To compute the partial sum of the first n numbers
 * in the alternating harmonic series, where N is a natural number.
 * More efficient than altharmonic.
 *
 * Examples:
 * altharmonic2 0 ==> 0
 * altharmonic2 1 ==> 1
 * altharmonic2 2 ==> 1/2
 * altharmonic2 3 ==> 5/6   *)
fun altharmonic2 (n : int) : real =
    case evenP(n) of
         true => altharmonicHelper(n, true)
       | false => altharmonicHelper(n, false)

(* Task 3.7: Implement this function. *)
(* Purpose: Takes in a tuple (dividend, divisor) and returns
 * the (quotient, remainder). Input must contain natural numbers.
 *
 * Examples:
 * divmod (4,2) ==> (2,0)
 * divmod (16,14) ==> (0,2)
 * divmod (54,7) ==> (7,5)
 * divmod (100,7) ==> (14,2)  *)
fun divmod (n : int, d : int) : int * int =
    case n < d of
         true => (0,n)
       | false => let val (quotient, remainder) = divmod(n-d, d) 
                  in (1 + quotient, remainder)
                  end
val (2,0) = divmod(4,2)
val (1,2) = divmod(16,14)
val (7,5) = divmod(54,7)
val (14,2) = divmod(100,7)

(* Task 3.8: Implement this function.
 * Purpose: Returns the sum of the digits of n 
 * in base b representation. n must be a natural number
 * and be must be an integer in such that 0 < b <= 11
 *
 * Examples: 
 * sum_digits (3,2) ==> 2
 * sum_digits (7,2) ==> 3
 * sum_digits (1234,10) ==> 10
 * sum_digits (12345,10) ==> 15   *)
fun sum_digits (n : int, b : int) : int =
    case n of
         0 => 0
       | _ => let val (quotient, remainder) = divmod(n,b)
              in remainder + sum_digits(quotient, b)
              end
val 2 = sum_digits(3,2)
val 3 = sum_digits(7,2)
val 10 = sum_digits(1234,10)
val 15 = sum_digits(12345,10)
