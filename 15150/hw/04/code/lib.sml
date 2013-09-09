(* datatypes *)
datatype tree = Empty | Node of tree * int * tree
datatype rel = LT | GEQ

(* functions on trees *)
fun depth (t : tree) : int =
    case t
     of Empty => 0
      | Node(l,_,r) => 1 + Int.max(depth l, depth r)

fun size (t : tree) : int =
    case t
     of Empty => 0
      | Node(l,_,r) => (size l) + (size r) + 1

fun tolist (t : tree) : int list =
    case t
     of Empty => []
      | Node(l,x,r) => (tolist l) @ [x] @ (tolist r)

fun isbalanced (t : tree) : bool =
    case t
     of Empty => true
      | Node(l,_,r) =>
        let
          val dl = depth l
          val dr = depth r
        in
          Int.abs(dl - dr) <= 1 andalso isbalanced l andalso isbalanced r
        end

fun inteq(x1:int,x2:int) : bool = 
    case Int.compare(x1,x2) of EQUAL => true | _ => false

fun treeeq(t1:tree, t2:tree) : bool = 
    case (t1,t2) of 
        (Empty,Empty) => true
      | (Node(l1,x1,r1),Node(l2,x2,r2)) => 
            treeeq(l1,l2) andalso inteq(x1,x2) andalso treeeq(r1,r2)
      | _ => false

local
  (* true iff every y in t is less or equal to  x *)
  fun lteq_all(x,t) =
      case t
       of Empty => true
        | Node(l,y,r) => x <= y andalso lteq_all(x,l) andalso lteq_all (x,r)

  (* true iff every y in t is greater than x *)
  fun grt_all(x,t) =
      case t
       of Empty => true
        | Node(l,y,r) => x > y andalso grt_all(x,l) andalso grt_all (x,r)
in
  fun issorted (t : tree) : bool =
      case t
       of Empty => true
        | Node(l,x,r) => lteq_all(x,r) andalso
                         grt_all(x,l) andalso
                         issorted(l) andalso
                         issorted(r)
end

(* uses int.compare to compare ints and produce the correct rel *)
fun intrelcmp (a : int, b : int) : rel =
    case Int.compare(a,b)
     of LESS => LT
      | GREATER => GEQ
      | EQUAL => GEQ

