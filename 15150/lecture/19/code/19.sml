
signature SEQUENCE =
sig

  type 'a seq
  val map : ('a -> 'b) -> 'a seq -> 'b seq
  val reduce : (('a * 'a) -> 'a) -> 'a -> 'a seq -> 'a
  val tabulate : (int -> 'a) -> int -> 'a seq
  val nth    : int -> 'a seq -> 'a 
end

structure TreeSeq : SEQUENCE = 
struct

    datatype 'a tree = Leaf of 'a | Empty | Node of 'a tree * 'a tree
    type 'a seq = 'a tree

    fun map f t = case t of
        Leaf x => Leaf (f x)
      | Empty => Empty
      | Node (t1 , t2) => Node (map f t1, map f t2)

    fun reduce n e t = 
        case t of 
            Leaf x => x
          | Empty => e
          | Node (t1 , t2) => n (reduce n e t1, reduce n e t2)

    (* helper function is not visible to clients *)
    fun numLeaves t = 
        case t of 
            Empty => 0
          | Leaf _ => 1
          | Node (t1,t2) => numLeaves t1 + numLeaves t2

    fun nth i s = 
        case (s , i) of 
          (Empty , _) => raise Fail "out of range"
        | (Leaf x , 0) => x
        | (Leaf x , _) => raise Fail "out of range" 
        | (Node (t1 , t2) , n) => 
              let val s1 = numLeaves t1 
              in 
                  case n < s1 of
                      true => nth n t1
                    | false => nth (n - s1) t2
              end

    fun tabulate f n = 
        let 
            (* return the sequence <f from, ..., f (to - 1) > *)
            fun tabulate' (from, to) = 
                case to - from of 
                    0 => Empty
                  | 1 => Leaf (f from)
                  | diff => Node (tabulate' (from , from + diff div 2) , tabulate' (from + diff div 2 , to))
        in
            tabulate' (0 , n)
        end 

end

(* optimized *)
structure TreeSeq : SEQUENCE = 
struct
    
    (* representation invariant:
       in Node (t1 , s1 , t2) , s1 is the number of leaves in t1 
       *)
    datatype 'a tree = Leaf of 'a | Empty | Node of 'a tree * int * 'a tree
    type 'a seq = 'a tree

    fun map f t = case t of
        Leaf x => Leaf (f x)
      | Empty => Empty
      | Node (t1 , s1 , t2) => Node (map f t1, s1, map f t2)

    (* don't show *)
    fun reduce n e t = 
        case t of 
            Leaf x => x
          | Empty => e
          | Node (t1 , _ , t2) => n (reduce n e t1, reduce n e t2)

    fun nth i s = 
        case (s , i) of 
            (Empty , _) => raise Fail "out of range"
          | (Leaf x , 0) => x
          | (Leaf x , _) => raise Fail "out of range" 
          | (Node (t1 , s1 , t2) , n) => 
                case n < s1 of
                    true => nth n t1
                  | false => nth (n - s1) t2
                        
    (* make a mistake! *)
    fun tabulate f n = 
        let 
            (* return the sequence <f from, ..., f (to - 1) > *)
            fun tabulate' (from, to) = 
                case to - from of 
                    0 => Empty
                  | 1 => Leaf (f from)
                  | diff => Node (tabulate' (from , from + diff div 2) , 
                                  diff div 2, (* + 1 BUG *)
                                  tabulate' (from + diff div 2 , to))
        in
            tabulate' (0 , n)
        end 
end

