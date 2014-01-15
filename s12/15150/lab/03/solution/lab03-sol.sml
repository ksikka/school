
fun evenP(n : int) : bool =
    case n
     of 0 => true
      | 1 => false
      | _ => evenP(n-2)


(* purpose: evens take an int list and removes all odd elements
 *   leaving the remaining events in the same order
 *
 * examples:
 *   evens( [1,2,3,4,5]) ==> [2,4]
 *   evens([]) ==> []
 *   evens([0,2,4,6]) ==> [0,2,4,6]
 *   evens([1,3,5]) ==> []
 *)

fun evens (l: int list) : int list =
    case l of
        [] => []
      | x::xs => (case evenP x of
                      true => x :: evens(xs)
                    | false => evens(xs) )

val [2,4] = evens [1,2,3,4,5]
val [] = evens []
val [0,2,4,6] = evens [0,2,4,6]
val [] = evens [1,3,5]


(* Purpose: fastfib n == (fib (n - 1) , fib n)
 * examples:
 *  fastfib(3) ==> (2,3)
 *  fastfib(12) ==> (144, 233)
 *  fasefib(0) ==> (0,1)
 *  fastfib(1) ==> (1,1)
 *)
fun fastfib (n : int) : int * int =
    case n of
        0 => (0 , 1)
      | 1 => (1 , 1)
      | _ =>
        let
            val (x : int , y : int) = fastfib (n - 1)
        in
            (y , x + y)
        end


(* tests for fastfib *)

val (0,1) = fastfib 0
val (1,1) = fastfib 1
val (144, 233) = fastfib 12;


(* purpose: merge(l1, l2) returns a list l with the following properties:
 *            (a) l contains exactly the elements of l1 and l2
 *            (b) if l1 and l2 are sorted in increasing order, then l is
 *                 sorted in increasing order
 *
 * example:
 *  merge([],[]) ==> []
 *  merge([1,2],[]) ==> [1,2]
 *  merge([1,3,5,7,9],[0,2,4]) => [0,1,2,3,4,5,7,9]
 *)
fun merge (L1, L2) =
    case (L1, L2)
     of ([], L2) => L2
      | (L1, []) => L1
      | (x :: xs, y :: ys) =>
        case (Int.compare(x,y))
         of LESS => x :: (merge(xs,     y :: ys))
          | _ =>    y :: (merge(x :: xs, ys    ))

(* tests for merge *)
val [] = merge([],[])
val [1,2] = merge([1,2],[])
val [0,1,2,3,4,5,7,9] = merge([1,3,5,7,9],[0,2,4])
