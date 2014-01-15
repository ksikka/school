
structure GameTree =
struct

    datatype player = Minnie | Maxie

    datatype tree =
        Est of string * int
      | Node of string * tree list

end

(* useful for testing search algorithms that use the estimator;
   unbounded complete search would loop.
 *)
functor ExplicitGame (A: sig
                             val tree : GameTree.tree
                         end) : GAME where type move = int =
struct

    open GameTree

    datatype outcome = Winner of player | Draw
    datatype status = Over of outcome | In_play

    type move = int

    datatype absstate = S of (tree * player)
    type state = absstate

    fun status (S t) = In_play

    fun moves (s as S (t, _)) =
        case t of
            Est v => Seq.tabulate (fn x => x) 1
          | Node (_,succs) => Seq.tabulate (fn x => x) (List.length succs)

    fun player (S (_, p)) = p

    val start = S (A.tree, Maxie)

    fun make_move (s as S (t,p), i) =
        case t of
            Est _ => raise Fail "called make_move on an Est state"
          | Node (_,next) => S(List.nth (next,i), case p of Maxie => Minnie | Minnie => Maxie)

    datatype est = Definitely of outcome | Guess of int
    (* estimate the value of the state, which is assumed to be In_play *)
    fun estimate (S(t,p)) =
        case t of
            Est(s,v) => (print ("Estimating state " ^ s ^ "[" ^ Int.toString v ^ "]\n") ; Guess v)
          | _ => raise Fail "called estimate on a non-estimate node"

    val move_to_string = Int.toString

    fun state_to_string (S(t,p)) = (case p of Maxie => "(Maxie," | Minnie => "(Minnie,") ^
        (case t of
            Est(s,_) => s
          | Node(s,_) => s) ^ ")"

    fun parse_move s = raise Fail ""

end

(* run with search depth 2*)
structure HandoutSmall : GAME =
ExplicitGame(struct
                 open GameTree
                 val tree = Node ("a",
                                  [Node("b",
                                        [Est("c", 3),Est("d",6),Est("e",~2)]),
                                   Node("f",
                                        [Est("g", 6),Est("h",4),Est("i",10)]),
                                   Node("j",
                                        [Est("k", 1),Est("l",30),Est("m",9)])])
             end)

(* run with search depth 4*)
structure HandoutBig : GAME =
ExplicitGame(struct
                 open GameTree
                 val tree = Node ("a",
                                  [Node("b",
                                        [Node("c",[Node("d",[Est("e",3),Est("f",5)]),
                                                   Node("g",[Est("h",2),Est("i",7)])]),
                                         Node("j",[Node("k",[Est("l",10),Est("m",4)])])]),
                                   Node("n",
                                        [Node("o",[Node("p",[Est("q",2),Est("r",7)])]),
                                         Node("s",[Node("t",[Est("u",8),Est("v",2)]),
                                                   Node("w",[Est("x",4),Est("y",6)])])])])
             end)
