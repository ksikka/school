signature GAME =
sig
    datatype player = Minnie | Maxie

    datatype outcome = Winner of player | Draw
    datatype status = Over of outcome | In_play

    type state (* state of the game; e.g. board and player *)
    type move (* moves *)

    (* views of the state: *)
    val moves : state -> move Seq.seq (* assumes state is not Over;
                                         generates moves that are valid in that state;
                                         always generates at least one move *)
    val status : state -> status
    val player : state -> player

    (* initial state and transitions: *)
    val start : state
    val make_move : (state * move) -> state (* assumes move is valid in that state *)

    (* The sign of a guess is absolute, rather than relative to whose turn it is:
       negative values are better for Minnie
       and positive values are better for Maxie. *)
    datatype est = Definitely of outcome | Guess of int
    (* estimate the value of the state, which is assumed to be In_play *)
    val estimate : state -> est

    val move_to_string : move -> string
    val state_to_string : state -> string
    val parse_move : state -> string -> move option (* ensures move is valid in
                                                       that state; string is a
                                                       single line, and *not*
                                                       newline terminated *)
end


functor EstOrder (G : GAME) : ORDERED =
LEOrder (struct
             type t = G.est

             fun le (x,y) =
                 case x = y of
                     true => true
                   | false => (* they're not equal *)
                         case (x,y) of
                             (G.Definitely (G.Winner G.Minnie), _) => true
                           | (_, G.Definitely (G.Winner G.Maxie)) => true
                           | (G.Guess x, G.Definitely G.Draw) => x <= 0
                           | (G.Definitely G.Draw, G.Guess x) => 0 <= x
                           | (G.Guess x, G.Guess y) => x <= y
                           | (_, _) => false
         end)

functor ShowEst (G : GAME) : sig type t val toString : t -> string end =
struct

    type t = G.est

    fun toString v = case v of
        G.Definitely (G.Winner G.Maxie) => "Maxie wins!"
      | G.Definitely (G.Winner G.Minnie) => "Minnie wins!"
      | G.Definitely G.Draw => "It's a draw!"
      | G.Guess i => "Guess:" ^ Int.toString i

end
