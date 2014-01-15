signature COUNTING_PLAYER =
sig
    structure Game : GAME

    (* also returns the number of terminal states visited
       (i.e. the number of times it calls Game.estimate and Game.status).
       This is useful for testing pruning.
    *)
    val next_move : Game.state -> Game.move * int
end

functor MiniMaxCount1 (Settings : sig
                                      structure G : GAME
                                      val search_depth : int
                                  end
                              ) : COUNTING_PLAYER =
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
                                                                 structure Right = EstOrder(Game)
                                                          end))

    (* assume seqs are non-empty *)
    val choose : Game.player -> edge Seq.seq -> edge =
        fn Game.Maxie => SeqUtils.reduce1 EdgeUtils.max
         | Game.Minnie => SeqUtils.reduce1 EdgeUtils.min

    val terminals = ref 0
    fun incr () = terminals := !terminals + 1

    fun search (depth : int) (s : Game.state) : edge =
        choose (Game.player s)
               (Seq.map
                (fn m => (m , evaluate (depth - 1) (Game.make_move (s,m))))
                (Game.moves s))

    and evaluate (depth : int) (s : Game.state) : Game.est =
        case Game.status s of
            Game.Over v => (incr (); Game.Definitely v)
          | Game.In_play =>
                (case depth of
                     0 => (incr () ; Game.estimate s)
                   | _ => edgeval(search depth s))

    fun next_move s =
        (terminals := 0;
         ((edgemove o (search Settings.search_depth)) s,
          !terminals))
end

functor MiniMaxCount2 (Settings : sig
                                      structure G : GAME
                                      val search_depth : int
                                  end
                              ) : COUNTING_PLAYER =
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
                                                                 structure Right = EstOrder(Game)
                                                          end))

    (* assume seqs are non-empty *)
    val choose : Game.player -> edge Seq.seq -> edge =
        fn Game.Maxie => SeqUtils.reduce1 EdgeUtils.max
         | Game.Minnie => SeqUtils.reduce1 EdgeUtils.min

    fun next_move s =
        let
            val terminals = ref 0
            fun incr () = terminals := !terminals + 1

            fun search (depth : int) (s : Game.state) : edge =
                choose (Game.player s)
                (Seq.map
                 (fn m => (m , evaluate (depth - 1) (Game.make_move (s,m))))
                 (Game.moves s))

            and evaluate (depth : int) (s : Game.state) : Game.est =
                case Game.status s of
                    Game.Over v => (incr (); Game.Definitely v)
                  | Game.In_play =>
                        (case depth of
                             0 => (incr () ; Game.estimate s)
                           | _ => edgeval(search depth s))
        in
            ((edgemove o (search Settings.search_depth)) s,
             !terminals)
        end

end

(* uncomment these lines if you want to run the code with your connect4 *)
(*
structure MMC1 = MiniMaxCount1(struct
                               structure G : GAME = Connect4(MiltonBradley)
                               val search_depth = 5
                               end )
structure MMC2 = MiniMaxCount2(struct
                               structure G : GAME = Connect4(MiltonBradley)
                               val search_depth = 5
                               end )
*)
