
(* same as the built-in @ *)
fun append (l1 : int list, l2 : int list) : int list = 
    case l1 of
        [] => l2
      | x::xs => x :: append (xs,l2)

(* Purpose: reverse the list l
   Ex: reverse [1,2,3] ==> [3,2,1]
*)
fun reverse (l : int list) : int list =
    case l of
        [] => []
      | x :: xs => (reverse xs) @ [x]
val [3,2,1] = reverse [1,2,3]

(* Purpose: reverse l in linear time *)
fun revTwoPiles (l : int list, r : int list) : int list =
    case l of
        [] => r
      | (x :: xs) => revTwoPiles(xs , x :: r)

fun fastReverse (l : int list) : int list = revTwoPiles(l , [])

(* ---------------------------------------------------------------------- *)

(* additional example *)

fun inteq (l1 : int , l2 : int) : bool = case Int.compare (l1,l2) of EQUAL => true | _ => false

fun square (x : int) : int = x * x
fun evenP (n : int) : bool = inteq (n mod 2 , 0)

(* Purpose: compute 2^n *)
fun fexp (n : int) : int =
    case n of
	0 => 1
      | _ => (case evenP n of
                  true => square (fexp (n div 2))
                | false => 2 * (fexp (n-1)))


