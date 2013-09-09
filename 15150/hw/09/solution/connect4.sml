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

    (* (0,0) is bottom-left corner *)
    datatype c4state = S of (position Matrix.matrix) * player
    type state = c4state

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
            " " ^ ts (Seq.tabulate (fn i => Int.toString i ^ " ") Dim.num_cols)
            ^ "\n" ^
            "-" ^ ts (Seq.tabulate (fn _ => "--") Dim.num_cols) ^ "\n" ^
            Seq.mapreduce print_row "" (fn (x,y) => y^x) rows ^ "\n"
        end

    fun lowestFreeRow (S (m, _) : state) (i : int (* column *)) : int option =
        let fun lowest (s : position Seq.seq) (cur : int) : int option =
                case cur = Dim.num_rows
                 of true => NONE
                  | _ => (case Seq.nth cur s
                           of Empty => SOME cur
                            | Filled _ => lowest s (cur + 1))
        in
            lowest (Seq.nth i (Matrix.cols m)) 0
        end

    fun parse_move st input =
        case Int.fromString input
         of SOME i => (case i < Dim.num_cols
                        of true =>
                           (* make sure there is a free spot in the column *)
                           (case (lowestFreeRow st i) of (SOME _) => SOME i
                                                       | _ => NONE)
                         | false => NONE)
          | NONE => NONE

    val start = S (Matrix.repeat Empty (Dim.num_cols, Dim.num_rows), Maxie)

    val flip_player = fn Minnie => Maxie | Maxie => Minnie

    fun make_move (s as (S (m, p)), c) =
        case lowestFreeRow s c of
            NONE => raise Fail ("Illegal Move: no empty spaces in column " ^
                                Int.toString c ^ " in state \n" ^
                                state_to_string s)
          | SOME r => (S (Matrix.update m ((c, r), Filled p), flip_player p)
                       handle Seq.Range _ =>
                              raise Fail "Illegal Move: Out of range")

    fun moves (s as S (m, _)) =
        let val (cols,_) = Matrix.size m

            (* pruning works better if better moves are explored first *)
            fun inorder (s : 'a Seq.seq) : 'a Seq.seq =
                case Seq.length s of
                    0 => s
                  | 1 => s
                  | _ => let val (left, rest) = Seq.split (Seq.length s div 2) s
                             val Seq.Cons (middle, right) = Seq.showl rest
                         in
                             Seq.cons middle (Seq.append (inorder left)
                                                         (inorder right))
                         end
        in
            inorder (SeqUtils.filtermap (fn i =>
                                            case lowestFreeRow s i of
                                                NONE => NONE
                                              | SOME _ => SOME i)
                     (Seq.tabulate (fn x => x) cols))
        end

    (* find the maximum Filled streak;
       only returns an Empty streak if the board is totally blank *)
    fun max_streak (streaks : (int * position) Seq.seq) =
        let
          val streak_cmp = fn ((_, Empty), (_, Empty)) => EQUAL
                            | ((_, Empty), (_ , Filled _)) =>
                              LESS (* Empty is less than any Filled *)
                            | ((_ , Filled _), (_, Empty)) => GREATER
                            | ((x, _), (y, _)) => Int.compare (x, y)
        in
          SeqUtils.max streak_cmp (0, Empty) streaks
        end

    fun pos_streaks (ps : position Seq.seq) =
        let
          val eq_pos = fn (Filled Maxie, Filled Maxie) => true
                        | (Filled Minnie, Filled Minnie) => true
                        | (Empty , Empty) => true
                        | (_, _) => false
        in
          SeqUtils.look_and_say eq_pos ps
        end

    fun matrix_lines (m : position Matrix.matrix) : (position Seq.seq Seq.seq) =
        Seq.flatten (Seq.tabulate (fn 0 => Matrix.rows m
                                    | 1 => Matrix.cols m
                                    | 2 => Matrix.diags1 m
                                    | 3 => Matrix.diags2 m
                                    | _ => raise Fail "unspecified") 4)

    fun longest_streak (m : position Matrix.matrix) =
        let
          val lines = matrix_lines m
          val streaks = Seq.map pos_streaks lines
        in
          max_streak (Seq.map max_streak streaks)
        end

    fun status (board as (S (m, _))) =
      let
        val (streak_len, streak_type) = longest_streak m
      in
        case Int.compare (streak_len, 4) of
            LESS => (case Seq.length (moves board) of
                         0 => Over Draw
                       | _ => In_play)
          | _ => (case streak_type of
                      Filled Minnie => Over (Winner Minnie)
                    | Filled Maxie => Over (Winner Maxie)
                    | Empty => (* means board was blank *) In_play)
      end

    fun player (S (_, p)) = p


    fun exp (b : int, e : int) : int =
        case e of 0 => 1 | _ => b * exp (b, e -1)

    structure LASEstimator =
    struct
      (* look_and_say based estimator *)
      fun bordered_streak (streaks : (int * position) Seq.seq)
           : (int * position * (bool * bool)) Seq.seq =
          let
            fun isempty (i : int) =
                (case Seq.nth i streaks of
                     (_, Empty) => true
                   | (_, _) => false)
                handle Seq.Range _ => false

            fun ineighbors (i : int) =
                let
                  val (slen, stp) = Seq.nth i streaks
                in
                  (slen, stp, (isempty (i-1), isempty (i+1)))
                end
          in
            Seq.tabulate ineighbors (Seq.length streaks)
          end

      fun streak_val (slen : int, stype : position, (lempty, rempty)) : int =
          let
            val bonus = case (lempty, rempty) of
                            (true, true) => 4
                          | (false, false) => 0
                          | (_, _) => 1

            val abs_val = exp (4, slen) * bonus
          in
            case stype of
                Empty => 0
              | Filled Minnie => ~abs_val
              | Filled Maxie => abs_val
          end

      fun line_val (line : position Seq.seq) : int =
          Seq.mapreduce streak_val 0 op+ (bordered_streak (pos_streaks line))

    end

    structure BetterEstimator =
    struct
        (* the problem with the look_and_say based estimator isn't that it
           doesn't see things like
           X X _ X
           where there is a gap

           the following estimator looks at all consecutive groups of 4

           Enhancement: take into account the height?
           *)

        (* compute all subsequences of length 4 *)
        fun fours (line : 'a Seq.seq) : 'a Seq.seq Seq.seq =
            case Seq.length line < 4 of
                true => Seq.empty ()
              | false =>
                (* positions 0, 1, 2, ... (n-4), so that the last one is
                 * <n-4,n-3,n-2,n-1> and still has length 4 *)
                Seq.tabulate (fn i => Seq.take 4 (Seq.drop i line))
                             (Seq.length line - 3)

        (* returns SOME (player, n \in {1,2,3}) if there are n pieces by player
         * and the rest empty or NONE if it is totally empty or mixed *)
        fun alive (s : position Seq.seq) : (player * int) option =
            let val maxes =
                    Seq.mapreduce (fn Filled Maxie => 1 | _ => 0) 0 op+ s
                val mins= Seq.mapreduce (fn Filled Minnie => 1 | _ => 0) 0 op+ s
            in case (maxes, mins) of
                (0, 0) => NONE
              | (0, mins) => SOME (Minnie, mins)
              | (maxes, 0) => SOME (Maxie, maxes)
              | (_,_) => NONE
            end

        fun line_val p (line : position Seq.seq) : int =
            let
                (* offense over defense *)
                (* FIXME: unused variables! *)
                val  maxiedivisor = case p of Maxie => 1 | Minnie => 2
                val minniedivisor = case p of Maxie => 2 | Minnie => 1
            in
                Seq.mapreduce (fn four => case alive four of
                                             NONE => 0
                                           | SOME (Maxie,n) => exp(4,n)
                                           | SOME (Minnie,n) => ~(exp(4,n)))
                              0 op+ (fours line)
            end
    end

    datatype est = Definitely of outcome | Guess of int
    fun estimate (board as (S (m, p))) =
        Guess (Seq.mapreduce (BetterEstimator.line_val p) 0 op+
                             (matrix_lines m))

end




