functor MiniMax (Settings : sig
                               structure G : GAME
                               val search_depth : int
                            end
                 ) : PLAYER =
struct
    structure Game = Settings.G

    type edge = (Game.move * Game.est)
    fun edgeval ((_,value) : edge) = value
    fun edgemove ((move,_) : edge) = move

    structure EdgeUtils : sig
                             (* ordered by the estimate, 
                                ignoring the move *)
                             val min : edge * edge -> edge
                             val max : edge * edge -> edge
                         end = 
     OrderUtils(PairSecondOrder(struct type left = Game.move
                                       structure Right = EstOrder(Game)
                                end))


    (* assume seqs are non-empty *)
    val choose : Game.player -> edge Seq.seq -> edge =
        fn Game.Maxie => SeqUtils.reduce1 EdgeUtils.max
         | Game.Minnie => SeqUtils.reduce1 EdgeUtils.min

    fun search (depth : int) (s : Game.state) : edge =
        choose (Game.player s)
               (Seq.map
                (fn m => (m , evaluate (depth - 1)
                              (Game.make_move (s,m))))
                (Game.moves s))

    and evaluate (depth : int) (s : Game.state) : Game.est =
        case Game.status s of
            Game.Over v => Game.Definitely v
          | Game.In_play =>
                (case depth of
                     0 => Game.estimate s
                   | _ => edgeval(search depth s))


    val next_move = edgemove o (search Settings.search_depth)

end
