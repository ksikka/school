functor AlphaBeta (Settings : sig
                                 structure G : GAME
                                 val search_depth : int
                             end)
        : PLAYER where type Game.move = Settings.G.move
                 where type Game.state = Settings.G.state =
struct
  structure Game = Settings.G

  structure EstOrd = OrderUtils(EstOrder(Game))
  structure ShEst = ShowEst(Game)

  type edge = (Game.move * Game.est)

  datatype value =
      BestEdge of edge
    | Pruned
  fun valueToString (v : value) : string =
      case v of Pruned => "Pruned"
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

  fun updateAB s (alpha, beta) (value : value) : alphabeta =
      case (Game.player s) of
          Game.Minnie => (alpha, minbeta (beta, value))
        | Game.Maxie => (maxalpha (alpha, value), beta)

  fun value_for state (alpha, beta) : value =
      case (Game.player state) of
          Game.Minnie => beta
        | Game.Maxie => alpha

  datatype result = Value of value | ParentPrune   (* an evaluation result *)
  fun resultToString r = case r of Value v => valueToString v
                                 | ParentPrune => "ParentPrune"

  fun check_bounds (alpha,beta) state incomingMove (v : Game.est) : result =
      case (alpha_is_less_than (alpha, v), beta_is_greater_than (v, beta)) of
          (false,true) => (case (Game.player state) of
                               Game.Maxie => ParentPrune
                             | Game.Minnie => Value Pruned)
        | (true,true) => Value (BestEdge (incomingMove, v))
        | (true,false) => (case (Game.player state) of
                               Game.Maxie => Value Pruned
                             | Game.Minnie => ParentPrune)
        | (false,false) => raise Fail "alpha = beta"

  fun evaluate (depth : int)
               (ab : alphabeta)
               (state : Game.state)
               (incomingMove : Game.move) : result =
      let val check = check_bounds ab state incomingMove
      in case Game.status state
          of Game.Over v => check (Game.Definitely v)
           | Game.In_play =>
             (case depth
               of 0 => check (Game.estimate state)
                | _ => (case search depth ab state (Game.moves state) of
                            Pruned => Value Pruned
                          | BestEdge (_,v) => check v))
      end

  and search depth ab state moves : value =
      case Seq.showl moves of
          Seq.Nil => value_for state ab
        | Seq.Cons (m, ms) =>
              (case (evaluate (depth - 1) ab (Game.make_move (state, m)) m) of
                   ParentPrune => Pruned
                 | Value v => search depth (updateAB state ab v) state ms)

  fun next_move s =
      case (search Settings.search_depth (Pruned, Pruned) s (Game.moves s)) of
          Pruned => raise Fail "alphabeta: overall result is Pruned"
        | (BestEdge (m,_)) => m
end
