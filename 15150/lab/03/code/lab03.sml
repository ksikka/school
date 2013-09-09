(* you can remove this defintion when you're done to make sure you didn't
 * miss any functions
 *)
exception Unimplemented

fun evenP(n : int) : bool =
    case n
     of 0 => true
      | 1 => false
      | _ => evenP(n-2)

fun fib (n : int) : int =
    case n
     of ~1 => 0
      | 0 => 1
      | 1 => 1
      | _ => fib(n-1) + fib(n-2)

(* Task 2 
 * Purpose: Given an int list, return a list with only the even elements.
 *
 * Examples: [] ==> []
 * [0,1,2,3,4,5,6,7] ==> [0,2,4,6] *)
fun evens (n : int list): int list = 
  case n of 
       [] => []
     | x::xs => case evenP(x) of
                     true => x::evens(xs)
                   | false => evens(xs)

(* Task 3.1 
 * Purpose: to compute the fibonacci numbers in linear time. Returns
 * fastfib(n) is equivalent to (fib(n-1),fib(n))
 * Examples: 
 * 3 => (2,3)
 * 5 => (5,8) *)
fun fastfib (n : int) : int * int =
  case n of
       0 => (0,1)
     | 1 => (1,1)
     | _ => let val (nminus2, nminus1) = fastfib(n-1)
            in (nminus1, nminus2 + nminus1)
            end

(* Task 4.6 *)
fun merge (x : int list, y : int list) : int list =
  case x of
       [] => y
     | a::aa => case y of
                     [] => x
                   | b::bb => case a > b of
                                   true => b::merge(x,bb)
                                 | false => a::merge(aa,y)



