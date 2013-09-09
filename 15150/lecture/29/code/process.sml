
(* a process is an agent that you can ask for input *)
structure Process : sig
                        type 'a process = unit -> 'a option

                        val stdinLines : string process
                        val stdin : char process
                        val random : real process
                        val file : string -> char process
                        val fileLines : string -> string process
                    end =
struct
    type 'a process = unit -> 'a option

    fun stdinLines () = TextIO.inputLine TextIO.stdIn

    fun stdin () = TextIO.input1 TextIO.stdIn
    val random = 
        let 
            val randstate = Random.rand (0,0)
        in
            fn () => SOME (Random.randReal randstate) (* effect: updates the state *)
        end

    fun file f = let val h = TextIO.openIn f
                 in 
                     fn () => TextIO.input1 h
                 end

    fun fileLines f = let val h = TextIO.openIn f
                      in 
                          fn () => TextIO.inputLine h
                      end
end
