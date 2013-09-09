fun oddP n = case n mod 2 of 1 => true | _ => false

datatype 'a tree = Empty | Leaf of 'a | Node of 'a tree * 'a tree

(* returns SOME(the first odd number) if any,
   or NONE if there isn't one
*)
fun findOdd (t : int tree) : int option =
    case t of
        Empty => NONE
      | Leaf x => (case oddP x of true => SOME x | false => NONE)
      | Node(l,r) =>
            (case findOdd l of
                 NONE => findOdd r
               | SOME x => SOME x)
val SOME 3 = findOdd (Node(Leaf 2, Node(Leaf 3, Leaf 4)))
val NONE   = findOdd (Node(Leaf 2, Node(Leaf 6, Leaf 4)))


exception NoOdd
fun findOdd (t : int tree) : int =
    case t of
        Empty => raise NoOdd
      | Leaf x => (case oddP x of true => x | false => raise NoOdd)
      | Node(l,r) => (findOdd l) handle NoOdd => findOdd r
val 3 = findOdd (Node(Leaf 2, Node(Leaf 3, Leaf 4)))
val 0 = (findOdd (Node(Leaf 2, Node(Leaf 6, Leaf 4)))) handle NoOdd => 0
val NONE = SOME (findOdd (Node(Leaf 2, Node(Leaf 6, Leaf 4)))) handle NoOdd => NONE


exception Found of int
fun findOdd (t : int tree) : unit =
    case t of
        Empty => ()
      | Leaf x => (case oddP x of true => raise Found x | false => ())
      | Node(l,r) => let val () = findOdd l in findOdd r end

val () = (findOdd (Node(Leaf 2, Node(Leaf 6, Leaf 4))))
val 3 = (findOdd (Node(Leaf 2, Node(Leaf 3, Leaf 4))); 0) handle Found x => x
val SOME 3 = (let val () = findOdd (Node(Leaf 2, Node(Leaf 3, Leaf 4))) in NONE end)
             handle Found x => SOME x



fun findOdd (t : int tree) : 'a =
    case t of
        Empty => raise NoOdd
      | Leaf x => (case oddP x of true => raise Found x | false => raise NoOdd)
      | Node(l,r) => findOdd l handle NoOdd => findOdd r

val true = (findOdd (Node(Leaf 2, Node(Leaf 6, Leaf 4)))) handle NoOdd => true
val SOME 3 = findOdd (Node(Leaf 2, Node(Leaf 3, Leaf 4))) handle Found x => SOME x


exception Failed
(* creates a function that
   raises Failed if f returns NONE
   returns x if f returns SOME x *)
fun toexn (f : 'a -> 'b option) : 'a -> 'b =
    fn x => case f x of NONE => raise Failed | SOME v => v

(* creates a function that
   returns NONE if g raises Failed
   returns SOME x if f returns x *)
fun toopt (f : 'a -> 'b) : 'a -> 'b option =
    fn x => SOME (f x) handle Failed => NONE

