functor Jamboree (Settings : sig
                                 structure G : GAME
                                 val search_depth : int
                                 val prune_percentage : real
                             end) : PLAYER  =
struct
  structure Game = Settings.G

  structure EstOrd = OrderUtils(EstOrder(Game))
  structure ShEst = ShowEst(Game)

  type edge = (Game.move * Game.est)

  datatype value =
      BestEdge of edge
    | Pruned
  fun valueToString (v : value) : string =
      case v of 
          Pruned => "Pruned" 
        | BestEdge (_,e) => "Value(" ^ ShEst.toString e ^ ")"

  type alphabeta = value * value (* invariant: alpha < beta *)
  fun abToString (a,b) = "(" ^ valueToString a ^ "," ^ valueToString b ^ ")"

  (* for alpha, we want max(alpha,Pruned) to be alpha, i.e.
     Pruned <= alpha for any alpha;
     otherwise order by the estimates on the edges
     *)
  fun alpha_is_less_than (alpha : value, v : Game.est) : bool =
      case alpha of
          Pruned => true
        | BestEdge(_,alphav) => EstOrd.lt(alphav,v)
  fun maxalpha (v1,v2) : value =
      case (v1,v2) of
          (Pruned,y) => y
        | (x,Pruned) => x
        | (BestEdge(_,e1), BestEdge(_,e2)) => 
              case EstOrd.lt (e1,e2) of true => v2 | false => v1

  (* for beta, we want min(beta,Pruned) to be beta, i.e.
     beta <= Pruned for any beta;
     otherwise order by the estimates on the edges
     *)
  fun beta_is_greater_than (v : Game.est, beta : value) : bool =
      case beta of
          Pruned => true
        | BestEdge(_,betav) => EstOrd.lt(v,betav)
  fun minbeta (v1,v2) : value =
      case (v1,v2) of
          (Pruned,y) => y
        | (x,Pruned) => x
        | (BestEdge(_,e1), BestEdge(_,e2)) => 
              case EstOrd.lt (e1,e2) of true => v1 | false => v2

  datatype result = Value of value | ParentPrune   (* an evaluation result *)
  fun resultToString r = 
      case r of Value v => valueToString v | ParentPrune => "ParentPrune"

  (* Task 1: copy updateAB and value_for and check_bounds here *)
  (* Depending on which player is going, it updates alpha and beta
   * according to the spec. *)
  fun updateAB (state : Game.state)
               ((alpha, beta) : alphabeta)
               (value : value) : alphabeta =
    case Game.player state of
         Game.Minnie => (alpha                 , minbeta(beta,value)) 
       | Game.Maxie  => (maxalpha(alpha,value) , beta               ) 

  (* Returns the relevant value to the player, either alpha or beta*)
  fun value_for (state : Game.state) ((alpha, beta) : alphabeta) : value = 
    case Game.player state of
         Game.Minnie => beta
       | Game.Maxie  => alpha

  datatype result = Value of value | ParentPrune   (* an evaluation result *)
  fun resultToString r = 
      case r of Value v => valueToString v | ParentPrune => "ParentPrune"

  (* Returns the result of checking MM with the alpha and beta, according to the
   * spec *)
  fun check_bounds ((alpha,beta) : alphabeta)
                   (state : Game.state)
                   (incomingMove : Game.move)
                   (v : Game.est) : result = 
  let
    val bounds = (alpha_is_less_than (alpha,v), beta_is_greater_than (v,beta),Game.player state)
  in
    case bounds of
            (true ,true , _         ) => Value(BestEdge(incomingMove,v))
          | (false,_    ,Game.Minnie) => Value(Pruned)
          | (false,_    ,Game.Maxie ) => ParentPrune 
          | (_    ,false,Game.Minnie) => ParentPrune
          | (_    ,false,Game.Maxie ) => Value(Pruned)
  end

  (* Task 2 *)
  (* Helper to pick an appropriate value for reduce *)
  fun reduceValue(state: Game.state)(v1: value)(v2: value) : value =
    case Game.player state of
      Game.Maxie  => maxalpha(v1, v2)
    | Game.Minnie => minbeta(v1, v2)

  (* Evaluates a node by trying to put a result on it, or searching if depth>1*)
  fun evaluate (depth : int) 
               (ab : alphabeta)
               (state : Game.state)
               (incomingMove : Game.move) : result =
    case Game.status state of
         Game.Over v  => check_bounds ab state incomingMove (Game.Definitely v)
       | Game.In_play => (case depth of
                              0 => check_bounds ab state incomingMove  (Game.estimate state)
                            | _ => let 
                                      val moves = Game.moves state
                                      val numChildren = Seq.length moves
                                      val l = floor(Settings.prune_percentage*real(numChildren))
                                      val (abMoves, mmMoves) = Seq.split l moves
                                   in
                                     case search depth ab state abMoves mmMoves of
                                       Pruned => Value(Pruned)
                                     | BestEdge(_,e) => check_bounds ab state incomingMove e                                 
                                   end)

  (* Searches the children of the game tree, updates alpha and beta, and then
   * picks the highest utility value attainable. *)
  and search (depth : int)
             (ab : alphabeta)
             (state : Game.state)
             (abmoves : Game.move Seq.seq)
             (mmmoves : Game.move Seq.seq) : value =
      case Seq.showl abmoves of
           Seq.Nil => (Seq.mapreduce
                         (fn x => case evaluate (depth-1) ab (Game.make_move(state,x)) x of
                                    ParentPrune => Pruned
                                  | Value v => v)
                         (value_for state ab)
                         (fn (v1, v2) => reduceValue state v1 v2)
                         mmmoves)
         | Seq.Cons(x,xs) => (case evaluate (depth-1) ab (Game.make_move(state,x)) x of
                                Value v => search depth (updateAB state ab v) state xs mmmoves 
                              | ParentPrune => Pruned)
  (* Task 5 *)
  (* Returns what the next move should be, according to the AI. *)
  fun next_move s =
    let
      val moves = Game.moves s
      val numMoves = Seq.length moves
      val l = floor(Settings.prune_percentage * real(numMoves))
      val (abMoves, mmMoves) = Seq.split l moves
    in
      case search Settings.search_depth (Pruned, Pruned) s abMoves mmMoves of
        Pruned => raise Fail "uhoh, got pruned as first thing searched"
      | BestEdge(m,_) => m
    end

end
