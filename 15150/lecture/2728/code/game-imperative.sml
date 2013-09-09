(* Simple example of a race condition *)
structure Banker =
struct
    
  fun update (f : 'a -> 'a) (r : 'a ref) : unit = 
      let val (ref cur) = r in r := f cur end
  fun deposit  n a = update (fn x => x + n) a
  fun withdraw n a = update (fn x => x - n) a

  val account = ref 100
  val () = deposit 100 account
  val () = withdraw 50 account
  val _ = Seq.tabulate (fn 0 => deposit 100 account 
                         | 1 => withdraw 50 account) 2

end

(* what goes wrong with ephemeral games *)
signature EPH_GAME =
sig
    datatype player = Minnie | Maxie
    datatype outcome = Winner of player | Draw
    datatype status = Over of outcome | In_play

    type state (* capability to read and write the state of the game *)
    type move (* moves *)
    val make_move : (state * move) -> unit (* assumes move is valid in that state *)
    val undo_last_move : state -> unit 

    (* so there can be many copies *)
    val start : unit -> state

    (* views of the state: *)
    val moves : state -> move Seq.seq (* assumes state is not Over; 
                                         generates moves that are valid in that state; 
                                         always generates at least one move *)
    val status : state -> status
    val player : state -> player

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

signature EPH_PLAYER =
sig
    structure Game : EPH_GAME
    val next_move : Game.state -> Game.move
end

functor EphMiniMax (Settings : sig
                               structure G : EPH_GAME
                               val search_depth : int
                            end) : EPH_PLAYER = 
struct
    structure Game = Settings.G


    type edge = (Game.move * Game.est)
    fun edgeval ((_,value) : edge) = value
    fun edgemove ((move,_) : edge) = move

    structure EdgeUtils : sig
                             (* ordered by the estimate, ignoring the move *)
                             val min : edge * edge -> edge
                             val max : edge * edge -> edge
                         end = OrderUtils(PairSecondOrder(struct type left = Game.move 
                                                                 structure Right = EstOrder(struct open Game 
                                                                                                   (* hack: EstOrder doesn't actually need make_move;
                                                                                                      we should have given the argument a smaller signature;
                                                                                                      as a hack, we can just supply a dummy value.  
                                                                                                      *)
                                                                                                   fun make_move _ = raise Fail "unimplemented" 
                                                                                                   val start = Game.start()
                                                                                            end)
                                                          end))

    (* assume seqs are non-empty *)
    val choose : Game.player -> edge Seq.seq -> edge = 
        fn Game.Maxie => SeqUtils.reduce1 EdgeUtils.max 
         | Game.Minnie => SeqUtils.reduce1 EdgeUtils.min 

    fun search_buggy (depth : int) (s : Game.state) : edge =
        choose (Game.player s)
               (Seq.map 
                (fn m => (m , 
                          (Game.make_move (s,m);
                           evaluate (depth - 1) s)))
                (Game.moves s))

    and search_ok_seq (depth : int) (s : Game.state) : edge =
        choose (Game.player s)
               (Seq.map 
                (fn m => (m , 
                          (Game.make_move (s,m);
                           evaluate (depth - 1) s) before
                           Game.undo_last_move s))
                (Game.moves s))

    and evaluate (depth : int) (s : Game.state) : Game.est =
        case Game.status s of
            Game.Over v => Game.Definitely v
          | Game.In_play => 
                (case depth of 
                     0 => Game.estimate s
                   | _ => edgeval(search_ok_seq depth s))
 
    val search = search_ok_seq

    val next_move = edgemove o (search Settings.search_depth)

end

functor EphGameFromPers (G : GAME) : EPH_GAME = 
struct

    open G
    type state = (G.state * G.state list) ref

    fun make_move (r as ref (s,hist) , m) = r := (G.make_move (s,m) , s :: hist)

    fun undo_last_move r = 
        case r of
            ref (_,s::hist) => r := (s , hist)
          | _ => raise Fail "no previous move"

    fun start() = ref (G.start, [])

    fun gstate (ref(s,_) : state) = s

    val moves = G.moves o gstate
    val status = G.status o gstate
    val player = G.player o gstate
    val estimate = G.estimate o gstate
    val state_to_string = G.state_to_string o gstate
    fun parse_move r mstr = G.parse_move (gstate r) mstr

end