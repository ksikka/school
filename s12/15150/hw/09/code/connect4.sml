(* the signature of game specifications. *)
signature CONNECT4_BOARD_SPEC =
  sig
    val num_cols : int
    val num_rows : int
  end

structure MiltonBradley : CONNECT4_BOARD_SPEC =
  struct
    val num_cols = 7
    val num_rows = 6
  end

functor Connect4 (Dim : CONNECT4_BOARD_SPEC) : GAME where type move = int  =
  struct
    datatype player = Minnie | Maxie
    
    datatype outcome = Winner of player | Draw
    datatype status = Over of outcome | In_play

    datatype position = Filled of player | Empty

    datatype c4state = S of (position Matrix.matrix) * player 
                            (* (0,0) is bottom-left corner *)
    type state = c4state
    
    val start = S((Matrix.repeat Empty (Dim.num_cols,Dim.num_rows)),Maxie)

    type move = int (* cols are numbered 0 ... num_cols-1 *)
    

    fun move_to_string i = Int.toString i

    val pos_to_string = (fn Filled Minnie => "O"
                          | Filled Maxie => "X"
                          | Empty => " ")

    fun state_to_string (board as (S (m, _))) =
        let
          val rows = Matrix.rows m

          val ts : string Seq.seq -> string = Seq.reduce op^ ""

          fun print_row s = 
              "|" ^ ts (Seq.map (fn x => pos_to_string x ^ "|") s) ^ "\n"
        in
          " " ^ ts (Seq.tabulate (fn i => "" ^ Int.toString i ^ " ") Dim.num_cols) ^ "\n" 
          ^ "-" ^ ts (Seq.tabulate (fn _ => "--") Dim.num_cols) ^ "\n" ^
          Seq.mapreduce print_row "" (fn (x,y) => y^x) rows ^ "\n"
        end

    (* Purpose: return the the lowest free row of a column, in an option. *)
    fun lowestFreeRow (S (m, _) : state) (i : int (* column *)) : int option = 
      let
        val col : position Seq.seq = Seq.nth i (Matrix.cols m)
        val x : int = Seq.mapreduce (fn Empty => 0 | Filled _ => 1) 0 op+ col
        val length = Seq.length col
      in case x=length of
             true => NONE
           | false => SOME x
      end

    (* Purpose: return a sequence of possible moves which follow from a given
     * state*)
    fun moves (S(m,p):state) : move Seq.seq =
      let
        val cols = Matrix.cols m
        val rawMoves = Seq.tabulate (fn i => i) (Seq.length cols)
        val validMoves = Seq.filter (fn i => case (lowestFreeRow (S(m,p)) i) of
                                     NONE => false
                                   | SOME _ => true) rawMoves
      in validMoves
      end

    fun parse_move st input =
        case Int.fromString input of
            SOME i => (case (i < Dim.num_cols) of
                           true => 
                            (case (lowestFreeRow st i) of 
                                 (* make sure there is a free spot in the column *)
                                 (SOME _) => SOME i
                               | _ => NONE)
                         | false => NONE)
          | NONE => NONE
    (* Simply access and return the player in a state *)
    fun player (S (_, p) : state) : player = p

    (* a position equality function for use with look_and_say *)
    (* there are 3^2 potential inputs, 3*1 of which return true*)
    fun pos_eq (p1 : position, p2 : position) : bool =
      case (p1,p2) of
           (Empty,Empty) => true
         | (Filled(x),Filled(y)) => (case (x,y) of
                                         (Minnie,Minnie) => true
                                       | (Maxie,Maxie) => true
                                       | (_,_) => false)
         | (_,_) => false

    (* Return what the status of the given board is. *)
    fun status (S (m, _) : state) : status = 
      let
        val d1 = Matrix.diags1 m
        val d2 = Matrix.diags2 m
        val rows = Matrix.rows m
        val cols = Matrix.cols m
        val a = Seq.append (* aliased for convenience *)
        val combined_seqs = a d1 (a d2 (a rows cols))

        (* pos_eq is defined above this function *)
        val tuples = Seq.flatten (Seq.map (SeqUtils.look_and_say pos_eq) combined_seqs)
        val four_runs = Seq.filter (fn (i,t) => case t of 
                                                     Empty => false 
                                                   | _ => (i >= 4)) tuples

        val empty_spaces = Matrix.matching_subs (fn Empty => true | _ => false) m
        val board_full = (Seq.length empty_spaces) = 0

      in
        (* if there is a run of 4, it's a win for that alpha *)
        (* if no run of 4, (if full -> draw) else in_play *)
        case (Seq.length four_runs) > 0 of
             true => let
                       val (_,x) = (Seq.nth 0 four_runs)
                       val player = case x of 
                                         Filled y => y 
                                       | _ => raise Fail "invariant broken"
                     in Over(Winner(player))
                     end
           | false => case board_full of true => Over(Draw) | false => (In_play)
      end

    (* Tells you what a state looks like after you apply a move to it. *)
    fun make_move (S (m,p) : state, col : move ) : state = 
      let
        val rowOpt = lowestFreeRow (S(m,p)) col
        val otherPlayer = case p of Minnie => Maxie | Maxie => Minnie

      in case rowOpt of 
             NONE      => raise Fail "invalid move" 
           | SOME(row) => S(Matrix.update m ((col,row),Filled(p)),otherPlayer)
      end
    
    datatype est = Definitely of outcome | Guess of int

    (* Returns an estimate of what the game is like. Either numerical, or
    * definitely an outcome. Positive is better for Maxie, lower better for
    * Minnie.*)
    fun estimate (S(m,p):state) : est = 
      let
        val rows = Matrix.rows m
        (* pos_eq is defined above *)
        val tuples = Seq.flatten (Seq.map (SeqUtils.look_and_say pos_eq) rows)
        val points = Seq.mapreduce 
                       (fn (cnt,pos) => 
                         let val pt = case cnt of 3 => 64 | 2 => 16 | 1 => 4 | _ => 128
                             val mult = case pos of Empty => 0 | Filled(Maxie) => 1 | Filled(Minnie) => ~1
                         in pt*mult
                         end )
                       0 
                       op+
                       tuples
      in Guess(points)
      end
  end
