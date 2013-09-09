functor ParserTest (Parser : PARSER) : TESTS =
struct
   structure Parser = Parser
   structure Seq = Parser.Seq

   val bench_tokens = Seq.tokens (fn x => not (Char.isAlphaNum x))
   val custom_tokens = Seq.tokens (fn x => not (Char.isAlphaNum x))

   val tests = [
                    "",
                    ".",
                    "word",
                    "two words",
                    "a period terminated sentence.",
                    ".  spaccee . cadet ././ "
               ]

  fun test_against_bench t : bool =
    let val exp_out = bench_tokens t
        val act_out = custom_tokens t
    in
        ((Seq.collate String.compare) (exp_out, act_out)) = EQUAL
    end

   fun all () =
       List.foldl (fn (t,r) => (test_against_bench t) andalso r) true tests

end
