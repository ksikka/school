fun evenP (n : int) : bool =
    case n
     of 0 => true
      | 1 => false
      | _ => evenP (n-2)

fun oddP (n : int) : bool =
    case n
     of 0 => false
      | 1 => true
      | _ => oddP (n-2)

fun add (m : int, n : int) =
  case m of
    0 => n
  | _ => 1 + (add (m - 1, n))

(*
  Purpose: recursively multiply two numbers
  Example: mult (0, _) = 0
           mult (1, n) = n
           mult (2, 2) = 4
*)
fun mult (m : int, n : int) =
  case m of
    0 => 0
  | _ => add (n, mult (m - 1, n))


(*
  Purpose: Calculate the nth harmonic number.
  Example: harmonic 0 = 0.0
           harmonic 1 = 1.0
           harmonic 2 = 1.5
 *)
fun harmonic (n : int) : real =
    case n
     of 0 => 0.0
      | _ => (1.0 / real n) + harmonic (n-1)

val true = Real.==(harmonic 0, 0.0)
val true = Real.==(harmonic 1, 1.0)
val true = Real.==(harmonic 2, 1.5)
val true = Real.==(harmonic 5, (1.0/1.0) + (1.0/2.0) + (1.0/3.0) + (1.0/4.0) + (1.0/5.0))

(*
  Purpose: Calculate the nth alternating harmonic number.
  Example: altharmonic 0 = 0.0
           altharmonic 1 = 1.0
           altharmonic 2 = 0.5
 *)
fun altharmonic (n : int) : real =
    case n
     of 0 => 0.0
      | _ =>
      let
        val sign : real =
          case oddP n of
            true => 1.0
          | _ =>  ~1.0
        val term : real = 1.0 / real n
      in
        sign * term + altharmonic (n-1)
      end

(*
  Purpose: Calculate the nth alternating harmonic number,
           assuming even is true iff n is even, or false
           iff n is odd.

  Example: altharmonicHelper (1, true) = ~1.0
           altharmonicHelper (2, true) = 0.5
           altharmonicHelper (3, false) = 0.8333...
 *)
fun altharmonicHelper (n : int, even : bool) =
    case n
     of 0 => 0.0
      | _ =>
      let
        val sign : real =
          case even of
            true => ~1.0
          | _ => 1.0
        val term : real = 1.0 / real n
      in
        sign * term + altharmonicHelper (n-1, not even)
      end

(* Purpose: Calculate the nth harmonic number.
   Example: see altharmonic.
 *)
fun altharmonic2 (n : int) : real =
    altharmonicHelper (n, evenP n)

(*
  Purpose: return the quotient and remainder of dividing two numbers
    divmod (x,y) assumes that x > 0  and y > 0
  Example: divmod (4,4) = (1,0), divmod (4,5) = (0,4), divmod (9,4) = (2,1)
*)
fun divmod (n : int, d : int) : int * int =
  case n < d of
    true => (0 , n)
  | false =>
  let
    val (q , r) = divmod (n - d, d)
  in
    (q + 1 , r)
  end

(*
  Purpose: sum the digits of n in base b
  Example: sum_digits (12345, 10) = 15
           sum_digits (15, 2) = 4
*)

fun sum_digits (n : int, b : int) : int =
    case n
     of 0 => 0
      | _ => let val (quo, rem) = divmod (n, b)
             in rem + sum_digits (quo, b)
             end
