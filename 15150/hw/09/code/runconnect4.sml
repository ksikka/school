structure Con4 = Connect4(MiltonBradley)

structure C4_HvMM =
Referee(struct
         structure Maxie  = HumanPlayer(Con4)
         structure Minnie = MiniMax(struct
                                     structure G = Con4
                                     (* search depth 4 is relatively instantaneous;
                                        5 takes about 5 seconds per move *)
                                     val search_depth = 5
                                    end)
        end)

(* Task 4.6 goes here *)
structure C4_HvAB =
Referee(struct
         structure Maxie  = HumanPlayer(Con4)
         structure Minnie = AlphaBeta(struct
                                     structure G = Con4
                                     val search_depth = 5
                                    end)
        end)
