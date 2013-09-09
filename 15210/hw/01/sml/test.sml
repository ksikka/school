structure PBF = ParenBF(ArrayParenPackage)
structure PDC = ParenDivAndConq(ArrayParenPackage)

structure ParenTest : TESTS =
struct
  open ArrayParenPackage

  (*strToParen : string -> paren Seq
   *
   *[strToParen s] converts the string `s` into a paren sequence. Raises
   *Fail if any characters of `s` are not '(' or ')'*)
  fun strToParen (s : string) : paren Seq.seq =
      let
        val chars = Seq.%(String.explode s)
        fun charToParen #"(" = OPAREN
          | charToParen #")" = CPAREN
          | charToParen c  = raise Fail ("strToParen does not recognize "
                                         ^ (String.str c) ^ "\n")
      in
        Seq.map charToParen chars
      end

  (*The following is an example of the type of testing structure that we
   *are expecting. You should build upon this to fully test your code on
   *a wide range of inputs. Feel free to modify the core functions as
   *you feel appropriate.
   *
   *This code will apply the inputs given in `tests` to the function
   *PBF.paren and compare to the expected values. If the two do not
   *match up, a message will be printed to the screen and `all` will be set
   *to false.*)

  fun optToStr NONE f = "NONE"
    | optToStr (SOME x) f = "SOME " ^ (f x)

  fun optEq opEq (NONE, NONE) = true
    | optEq opEq (NONE, _) = false
    | optEq opEq (_, NONE) = false
    | optEq opEq (SOME x, SOME y) = opEq(x, y)

  fun assertEqual expected actual opEq message =
      if opEq(expected, actual) then true
      else (print message; false)

  fun basicParenTest (input, expected) : bool =
      let
        val out = PBF.parenDist (strToParen input)
        val message = "BF: (" ^ input ^ ", " ^ (optToStr out Int.toString) ^ ")\n"
      in
        assertEqual out expected (optEq op=) message
      end

  fun divConqParenTest (input, expected) : bool =
      let
        val out = PDC.parenDist (strToParen input)
        val message = "DC: (" ^ input ^ ", " ^ (optToStr out Int.toString) ^ ")\n"
      in
        assertEqual out expected (optEq op=) message
      end

  val tests = [
               ("(()())()", SOME 4),
               ("()", SOME 0),
               ("(())", SOME 2),
               ("(()())", SOME 4),
               ("((()))", SOME 4),
               ("((()))()", SOME 4),
               ("((()))()()()()()", SOME 4),
               ("((()))(()()()()())", SOME 10),
               ("((()))(()()()()())(()()()(()(()))())", SOME 16),
               ("(((()))(()()()()())(()()()(()(()))()))", SOME 36),
               ("(()((()))())", SOME 10),
               (")", NONE),
               ("", NONE),
               ("((((())))())()", SOME 10)
              ]

  fun all () = 
    let
      val testBF = List.foldl (fn (a, b) => a andalso b) true
                          (List.map basicParenTest tests)
  
      val testDC = List.foldl (fn (a, b) => a andalso b) true
                          (List.map divConqParenTest tests)
    in testBF andalso testDC
    end
end
