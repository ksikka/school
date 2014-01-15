structure Nim : GAME =
struct

    datatype player = Maxie | Minnie;

    datatype outcome = Winner of player | Draw
    datatype status = Over of outcome | In_play;

    datatype state = State of int * player (* int is how many pebbles are left *)
    datatype move = Move of int (* how many pebbles to pick up *)

    fun player (State (_, p)) = p

    fun status (State s) =
        case s of
            (0, p) => Over (Winner p)
          | _ => In_play

    (*
    fun moves (State (pile , _)) =
        case pile of
            0 => raise Fail "Invariant violation: called moves when the game is over"
          | 1 => Seq.cons (Move 1, Seq.empty())
          | 2 => Seq.cons (Move 1, Seq.cons (Move 2, Seq.empty()))
          | _ => Seq.cons (Move 1, Seq.cons (Move 2, (Seq.cons (Move 3, Seq.empty()))))
    *)
    fun moves (State (pile , _)) = Seq.tabulate (fn x => Move (x + 1)) (Int.min (pile , 3))

    val start = State (15, Maxie)

    fun flip p = case p of Maxie => Minnie | Minnie => Maxie
    fun make_move (State (pile, player), Move n) =
        case (pile >= n) of
            true => State (pile - n, flip player)
         | false => raise Fail "tried to make an illegal move"

    (* cf. Sprague–Grundy theorem *)
    datatype est = Definitely of outcome | Guess of int
    fun estimate (State (pile, p)) =
        case (pile mod 4) of
            1 => Definitely (Winner (flip p))
          | _ => Definitely (Winner p)

    fun player_to_string p = case p of Maxie => "Maxie" | Minnie => "Minnie"

    fun state_to_string (State (n, p)) =
        Int.toString n ^ " left, and it is " ^ player_to_string p ^ "'s turn"

    fun move_to_string (Move take) = Int.toString take

    fun parse_move (State (pile,_)) s =
        let fun enough n =
            case n <= pile of
                true => SOME (Move n)
              | false => NONE
        in
            case s of
                "1" => enough 1
              | "2" => enough 2
              | "3" => enough 3
              | _ => NONE
        end
end
