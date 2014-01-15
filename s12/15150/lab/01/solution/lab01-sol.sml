(* ---------------------------------------------------------------------- *)
(* For Sec 7.1 *)
fun intToString (x : int) : string = Int.toString x
(* ---------------------------------------------------------------------- *)

val true = CM.make "../../../src/sequence/sources.cm";
open VectorSeq

type row = int seq
type students = row seq

(* Example for count:
row1 : yes yes no
row2 : no  yes no

answer should be: 3
*)

val row1 : row  = cons (1 , cons (1 , cons (0 , empty())))
val row2 : row  = cons (0 , cons (1 , cons (0 , empty())))
val classroom : students = cons (row1 , cons (row2, empty()))

(* Task 7.2 *)
val row1 : row = cons (1, cons (0, cons (1, cons(1, empty()))))
val row2 : row = cons (0, cons (0, cons (0, cons(1, empty()))))
val row3 : row = cons (1, cons (1, cons (0, cons(0, empty()))))
val classroom1 : students = cons (row1 , cons (row2, cons (row3, empty())))

(* Task 7.3 *)
val row4 : row = cons (1, cons (1, cons (1, cons(1, empty()))))
val row5 : row = cons (1, cons (1, cons (1, cons(1, empty()))))
val row6 : row = cons (1, cons (1, cons (1, cons(1, empty()))))
val classroom2 : students = cons (row4 , cons (row5, cons (row6, empty())))

(* Purpose: Add two numbers *)
fun add (x : int , y : int) = x + y

(* Purpose: Do andalso on two numbers *)
fun pairAnd (x : int , y : int) =
    case (x,y) of
        (1,1) => 1
      | _ => 0




(* ---------------------------------------------------------------------- *)

(* Code from class *)

(* Purpose: Add the numbers in the sequence r *)
fun sum (r : int seq) : int = reduce add 0 r

(* Purpose: Count the number of students in the class who have taken 122 *)
fun count (s : students) : int = sum (map sum s)

(* ---------------------------------------------------------------------- *)

(* Code for task 7.4 *)

(* Purpose: See if everyone in a row has taken 122 *)
fun allInRow (r : row) : int = reduce pairAnd 1 r

(* Task 7.5 *)

(* Purpose: See if everyone in a classroom has taken 122 *)
fun allInClassroom (c : students) : int = allInRow (map allInRow c)

val 0 = allInClassroom classroom
val 0 = allInClassroom classroom1
val 1 = allInClassroom classroom2
