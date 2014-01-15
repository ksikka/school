functor KgramTest (KS : KGRAM_STATS) : TESTS =
struct
   structure KS = KS
   structure Seq = KS.Seq

   (* is a corpus of one "1"
                   , two "2"
                   , three "3"
                   , six "6"
                   , eight "8"
                   , ten "10"
                   , twenty "20". This adds to 50 tokens. *)
   val corpus = " 1  2  3  6  8 10 20 20 10 20 "
              ^ " 2  3  6  8 20 10 20 20 10 20 "
              ^ " 3  6  8 20 10 20 20 10 20 20 "
              ^ " 6  8 10 20 20 10 20 20 10 20 "
              ^ " 6  6  8  8  8  8 20 10 20 20 "

   val toks  = Seq.tokens (fn c => c = #" ") corpus
   val stats = KS.make_stats toks 3

   val freq_tests = [ 
                      ((["10"],     "10"), (0,10)), 
                      ((["10"],     "20"), (10,10)), 
                      ((["20"],     "6"), (2,19)), 
                      ((["20"],     "10"), (8,19)), 
                      ((["20"],     "20"), (7,19)), 
                      ((["20","10"],"6"), (0,8)),
                      ((["20","10"],"10"), (0,8)),
                      ((["20","10"],"20"), (8,8)),
                      ((["20","10","20"],"20"), (5,8)),
                      (([],"10"),(10,50)),
                      (([],"20"),(20,50)),
                      ((["hello","world"],"20"),(0,0))
                    ]
   val exts_tests = [
                      (["10"]     ,[("20",10)]),
                      (["20"     ],[("10",8),("2",1),("20",7),("3",1),("6",2)]),
                      (["10","20"],[("2",1),("20",7),("3",1),("6",1)]),
                      (["hello"],[]),
                      ([],[("1",1),("2",2),("3",3),("6",6),("8",8),("10",10),("20",20)])
                    ]

  fun freq_test ((arg1,arg2),exp_out) : bool =
    let val arg1 = Seq.fromList arg1
        val act_out = KS.lookup_freq stats arg1 arg2
    in
        exp_out = act_out
    end

  fun exts_test (arg1,exp_out) : bool =
    let val arg1 = Seq.fromList arg1
        val exp_out = Seq.fromList exp_out
        val act_out = KS.lookup_extensions stats arg1
        val test_compare = (fn ((a,_),(b,_)) => String.compare (a,b))
        val exp_out = Seq.sort test_compare exp_out
        val act_out = Seq.sort test_compare act_out
        val test_seq_compare = Seq.collate test_compare
    in
        (test_seq_compare (exp_out,act_out)) = EQUAL
    end

   fun all () =
     let
       val freq_tests_worked = List.foldl (fn (t,r) => (freq_test t) andalso r) true freq_tests
       val exts_tests_worked = List.foldl (fn (t,r) => (exts_test t) andalso r) true exts_tests
     in freq_tests_worked andalso exts_tests_worked
     end
end
