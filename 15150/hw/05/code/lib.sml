CM.make "../../../src/rationals/rat.cm";

type rat = Rational.t

infixr 9 //
infixr 7 ++
infixr 7 --
infixr 8 **

fun (n : int) // (d : int) = Rational.fromPair (n, d)

fun (x : rat) ++ (y : rat) : rat = Rational.plus(x, y)
fun (x : rat) -- (y : rat) : rat = Rational.subtract(x, y)
fun (x : rat) ** (y : rat) : rat = Rational.times(x, y)
val ~~ : rat -> rat = Rational.negate
val divide : rat * rat -> rat = Rational.divide
val r2s = Rational.toString

(* represent c_0 x^0 + c_1 x + c_2 x^2 + ...
   by the function that maps the natural number i to the coefficient c_i
*)
type poly = int -> rat


(* ---------------------------------------------------------------------- *)
(* Other provided functions *)

(* Purpose: Returns SOME of the nth (starting from index 0) element of the
 * argument list if the list has at least n+1 elements.  Otherwise, the result
 * is NONE.
 *)
fun nth (l : 'a list, n : int) : 'a option =
    case l of
        nil => NONE
      | x::xs => (case n of
                      0 => SOME x
                    | _ => nth (xs, n-1))

(* Purpose: Converts an argument list into a function that maps a natural
 * number int to the element of the list in that position if there is one.
 * Otherwise, the function maps the int to the value x.
 *)
fun listToFun (x : 'a, l : 'a list) : int -> 'a =
    fn y => case nth (l, y) of NONE => x | SOME x' => x'

(* Helpful function for debugging/testing *)
local
  fun termToString (c : rat, e : int) : string =
      r2s c ^ "x^" ^ Int.toString e
in
  fun polyToString (n : poly, count : int) : string =
      (String.concatWith " + "
                         (List.tabulate(count+1, fn e => termToString(n e, e)))
      ) ^ " + ...\n"
end


(* Purpose: Compare the coefficients of two polynomials for equality up to the
 * coefficient of x^count
 *)
fun polyEqual (n1 : poly, n2 : poly, count : int) : bool =
    ListPair.all (fn (r1, r2) => EQUAL = Rational.compare (r1,r2))
                 (List.tabulate(count+1, n1), List.tabulate(count+1, n2))


type matrix = Rational.t list list

(* Examples of matrix functions *)
fun toString (m : matrix) : string =
    let
      val s = map (map Rational.toString) m
      val com = String.concatWith ","
    in
      "[" ^ (com (map (fn x => "[" ^ (com x) ^ "]") s)) ^ "]"
    end

fun zed (h : int, w : int) : matrix =
    List.tabulate(h, fn _ => List.tabulate(w, fn x => Rational.fromInt 0))

fun width [] = 0
  | width (l::_) = length l

val height = List.length

fun rateq (r1 : rat, r2 : rat) : bool =
    case Rational.compare (r1, r2) of
        EQUAL => true
      | _ => false

fun mateq (m1 : matrix, m2 : matrix) : bool =
    ListPair.allEq (ListPair.allEq rateq) (m1, m2)

