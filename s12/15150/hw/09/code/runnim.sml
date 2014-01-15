structure Nim_HvMM = Referee(struct
                                 structure Maxie  = HumanPlayer(Nim)
                                 structure Minnie = MiniMax(struct
                                                                structure G = Nim
                                                                val search_depth = 5
                                                            end)
                             end)

structure Nim_HvMM1 = Referee(struct
                                 structure Maxie  = HumanPlayer(Nim)
                                 structure Minnie = MiniMax(struct
                                                                structure G = Nim
                                                                val search_depth = 1
                                                            end)
                             end)

structure Nim_MM1vH = Referee(struct
                                 structure Maxie = MiniMax(struct
                                                                structure G = Nim
                                                                val search_depth = 1
                                                            end)
                                 structure Minnie = HumanPlayer(Nim)
                             end)

