                 
structure ParallelExceptions =
struct

    datatype 'a result = Success of 'a | Failure of exn

    fun reify (f : 'a -> 'b) : 'a -> 'b result =
        fn x => Success (f x) handle e => Failure e

    fun reflect (f : 'a -> 'b result) : ('a -> 'b) =
        fn x => case f x of Success v => v | Failure e => raise e

    fun leftToRight (s : 'b result Seq.seq) : 'b Seq.seq result =
        Seq.mapreduce (fn Success v => Success (Seq.singleton v)
                        | Failure e => Failure e)
                      (Success (Seq.empty()))
                      (fn (Success v1 , Success v2) => 
                            Success (Seq.append v1 v2)
                        | (Failure e , _) => Failure e
                        | (Success _ , Failure e) => Failure e)
                      s

    fun emap (f : 'a -> 'b) : 'a Seq.seq -> 'b Seq.seq = 
        reflect (leftToRight o (Seq.map (reify f)))

    (* should raise 2 *)
    val () = ignore (emap (fn 1 => 1 
                            | n => raise Fail (Int.toString n))
                          (Seq.cons 1 (Seq.cons 2 (Seq.cons 3 (Seq.empty())))))
             handle Fail "2" => ()

end
