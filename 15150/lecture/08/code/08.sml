(* polymorphism *)

(* typing equations are underconstrained, so it is polymorphic *)
fun length (l : 'a list) : int = 
    case l of
        [] => 0
      | x :: xs => 1 + length xs

fun zip (l : 'a list, r : 'b list) : ('a * 'b) list = 
    case (l,r) of
        ([],_) => []
      | (_,[]) => []
      | (x::xs,y::ys) => (x,y)::zip(xs,ys)

(* typing equations have unique solution *)
fun add(x:int,y:int) : int = x + y
fun sum (l : int list) : int = 
    case l of
        [] => 0
      | x :: xs => add (x , sum xs)

(* typing equations are overconstrainted, so type error *)
(*
fun sum (l : int list) : int = 
    case l of
        [] => "hi"
      | x :: xs => add (x , sum xs)
*)

(* ---------------------------------------------------------------------- *)
(* specs vs. checks; options *)

(* monomorphic *)

datatype letter_grades = 
    LEmpty 
  | LNode of letter_grades * (string * string) * letter_grades

fun lookup_letter (d : letter_grades, k : string) : string = 
    case d of 
        LEmpty => raise Fail "not found"
      | LNode (l,(k',v),r) => 
            (case String.compare(k,k') of 
                 EQUAL => v
               | LESS => lookup_letter(l,k)
               | GREATER => lookup_letter(r,k))

datatype number_grades = 
    NEmpty 
  | NNode of number_grades * (string * int) * number_grades

fun lookup_number (d : number_grades, k : string) : int = 
    case d of 
        NEmpty => raise Fail "not found"
      | NNode (l,(k',v),r) => 
            (case String.compare(k,k') of 
                 EQUAL => v
               | LESS => lookup_number(l,k)
               | GREATER => lookup_number(r,k))

(* polymorphic *)

datatype 'a grades = 
    Empty 
  | Node of 'a grades * (string * 'a) * 'a grades

(* if k is in d then
   lookup(d,k) returns the value associated with k in d

   (don't call lookup when k is not in d)
*)
fun lookup (d : 'a grades, k : string) : 'a = 
    case d of 
        Empty => raise Fail "not found"
      | Node(l,(k',v),r) => 
            (case String.compare(k,k') of 
                 EQUAL => v
               | LESS => lookup(l,k)
               | GREATER => lookup(r,k))

val letters = Node(Node(Empty,("drl","B"),Empty),("iev","A"),Empty)
val "B" = lookup(letters,"drl")

val numbers = Node(Node(Empty,("drl",89),Empty),("iev",90),Empty)
val 89 = lookup(numbers,"drl")

(* contains(d,k) == true if k is in d 
                 == false if k is not in d *)
fun contains (d : 'a grades, k : string) : bool = 
    case d of 
        Empty => false
      | Node(l,(k',v),r) => 
            (case String.compare(k,k') of 
                 EQUAL => true
               | LESS => contains(l,k)
               | GREATER => contains(r,k))

val example = 
    let val unknown = "drl"
    in 
        case contains(letters,unknown) of
            true => 
                (* now we know that unknown is in lettergrades *)
                lookup(letters,unknown)
          | false => (* do something else *) "bad input"
    end

