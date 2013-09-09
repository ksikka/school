(* map *)

fun double (x : int) : int = x * 2
fun doubAll (l : int list) : int list = 
    case l of 
        [] => []
      | x :: xs => double x :: doubAll xs

fun raiseBy (l : int list , c : int) : int list = 
    case l of 
        [] => []
      | x :: xs => (x + c) :: raiseBy (xs,c)

fun map (f : int -> int , l : int list ) : int list =
    case l of
        [] => []
      | x :: xs => f x :: map (f , xs)

(* map gets instantiated like this: *)
fun doubAll l = map (double , l)

(* or you can use an anonymous function *)
fun doubAll l = map (fn x => 2 * x , l)
(* doubAll can be defined anonymously too *)
val doubAll : int list -> int list = fn l => map (fn x => 2 * x , l)

fun raiseBy (l , c) = map (fn x => x + c , l)

(* what if we want to write something at a different type? *)
fun showAll (l : int list) : string list = 
    case l of 
        [] => []
      | x :: xs => Int.toString x :: showAll xs

(* map can be given a polymorphic type; 
   all instances of map have instance of this pattern
*)
fun map (f : 'a -> 'b , l : 'a list ) : 'b list =
    case l of
        [] => []
      | x :: xs => f x :: map (f , xs)

fun doubAll l = map (fn x => x + 1 , l)
fun showAll l = map (Int.toString , l)

(* ---------------------------------------------------------------------- *)

datatype 'a grades = 
    Empty 
  | Node of 'a grades * (string * 'a) * 'a grades
val letters = Node(Node(Empty,("drl","B"),Empty),("iev","A"),Empty)

(* if k is in d then
   lookup(d,k) == SOME v, where v is the value associated with k in d

   if k is not in d then lookup(d,k) == NONE
*)
fun lookup_opt (d : 'a grades, k : string) : 'a option = 
    case d of 
        Empty => NONE
      | Node(l,(k',v),r) => 
            (case String.compare(k,k') of 
                 EQUAL => SOME v
               | LESS => lookup_opt(l,k)
               | GREATER => lookup_opt(r,k))

val example' = 
    let val unknown = "drl"
    in 
        case lookup_opt(letters,unknown) of
            SOME grade => grade
          | NONE => (* do something else *) "bad input"
    end
