datatype tree =
    Empty
  | Node of tree * int * tree

fun splitAt (t : tree , bound : int) : tree * tree =
 case t of
     Empty => (Empty , Empty)
   | Node (l , x , r) => 
      (case bound < x of
           true => let val (ll , lr) = splitAt (l , bound) 
                   in (ll , Node (lr , x , r))
                   end
         | false => let val (rl , rr) = splitAt (r , bound) 
                    in (Node (l , x , rl) , rr)
                    end)

fun merge (t1 : tree , t2 : tree) : tree = 
 case t1 of 
     Empty => t2
   | Node (l1 , x , r1) =>
      let val (l2 , r2) = splitAt (t2 , x) 
      in
          Node (merge (l1 , l2) , 
                x, 
                merge (r1 , r2))
      end

fun mergesort (t : tree) : tree =
    case t of
        Empty => Empty
      | Node (l , x , r) => 
          merge(merge (mergesort l , mergesort r), 
                Node(Empty,x,Empty))

(* ---------------------------------------------------------------------- *)

(* for testing *)
(* 
   if split l ==> SOME (l1,x,l2) then l = l1 @ x::l2
*)
fun split (l : int list) : (int list * int * int list) option = 
    case l of 
        [] => NONE
      | _ => 
            let 
                val midlen = (length l) div 2
                val front = (List.take (l,midlen))
                val x :: back = (List.drop (l,midlen))  (* because we round down, if the list is non-empty, this has at least one thing in it *)
            in 
                SOME (front, x , back)
            end 

fun ltt l = 
      case split l of
          NONE => Empty
        | SOME (l,x,r) => Node (ltt l , x , ltt r)

fun depth t = 
    case t of
        Empty => 0
      | Node(t1,_,t2) => 1 + Int.max (depth t1, depth t2)