structure BabblePackage : BABBLE_PACKAGE =
struct
  structure Babbler = Babbler 
  structure Parser = Parser(ArraySequence)
end


functor BabbleTest (BabblePackage : BABBLE_PACKAGE) : TESTS =
struct
   open BabblePackage

   fun babbleFromFile (inputfile, outfile) =
        let
          val ins = TextIO.openIn inputfile
          val instring = TextIO.inputAll ins
          val toks = Parser.tokens 
                        (fn (c:char) => not (Char.isAlphaNum c))  
                        instring
          val kgrammer = Babbler.KS.make_stats toks 3
          val outs = TextIO.openOut outfile
          val () = print "Going to generate document.\n"
          val () = TextIO.output (outs, (Babbler.generate_document kgrammer 50 324))
          val () = TextIO.closeOut outs
          val () = print "Ready.\n"
        in
          "OK"
        end

   fun all () = 
     (babbleFromFile("input/shakespeare.txt", "babble-shakespeare.txt");
      babbleFromFile("input/mobydick.txt", "babble-mobydick.txt");
      babbleFromFile("input/kennedy.txt", "babble-kennedy.txt"); 
      true)

end
