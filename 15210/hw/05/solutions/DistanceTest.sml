structure Dist = Distance(Default.StringTable)

structure DistanceTest : TESTS =
struct
  open Dist

  fun nullHeuristic v = 0.0

  fun s l = Set.fromSeq(Seq.fromList l)

  fun genGraph L = 
     makeGraph (Seq.map (fn ((u,v),w) => (u,v,real w)) (Seq.fromList L))

  fun setString S =
  let
     val x = (Seq.reduce (fn (a,b) => a^", "^b) "" (Set.toSeq S))
   in
    "{"^ (String.substring(x,2,(String.size x)-2)) ^"}"
   end

  fun check((G,S,D),r) = 
    let 
       fun answerString a =
          case a of
            NONE => "NONE"
          | SOME(v,i) => "SOME(" ^ v ^ ", " ^ (Int.toString i)^")"
       val (r',s) = findPath nullHeuristic G S D
       fun r2(v,d) = (v,Real.round d)
       val r' = (Option.map r2 r')
    in 
      if (r = r') then true
      else ((print ("Failed Test: " ^
                    "S = " ^ (setString S) ^ " : " ^
                    "D = " ^ (setString D) ^ " : " ^
                    "Result = " ^ (answerString r') ^ "\n"))
            ; false)
    end

  fun combineCheck L =
    Seq.reduce (fn (a,b) => a andalso b) true (Seq.fromList L)

  val graph1 = genGraph
       [(("a","b"),10),
        (("a","c"),1), 
        (("c","d"),1),
        (("d","b"),1),
        (("c","b"),3)]

  val graph2 = genGraph
               [(("a","b"),10),(("b","c"),12),(("a","c"),7),
                (("c","a"),2),(("b","d"),2),(("a","d"),1),
                (("e","f"), 4),(("f","a"),5),(("e","b"),1),(("d","f"),11),
                (("f","g"), 1),(("g","h"),17)]

  val graph3 = genGraph
       [(("s","a"),3),
        (("s","b"), 2),
        (("b","a"),~2), 
        (("a","c"),1),     
        (("b","d"),1),
        (("c","d"),1)]

  val graph4 = genGraph
       [(("s","a"),3),
        (("s","b"),4),
        (("b","a"),~2) ]

  fun checkS1D1G1() = combineCheck [
      check((graph1, s["a"], s["a"]), SOME("a", 0)),
      check((graph1, s["a"], s["b"]), SOME("b", 3)),
      check((graph1, s["a"], s["c"]), SOME("c", 1)),
      check((graph1, s["c"], s["b"]), SOME("b", 2)),
      check((graph1, s["b"], s["a"]), NONE),
      check((graph1, s["d"], s["a"]), NONE)
      ]

  fun checkS2D1G2() = combineCheck [
      check((graph2, s["a","b"], s["d"]), SOME("d", 1)),
      check((graph2, s["e","d"], s["h"]), SOME("h", 22)),
      check((graph2, s["c","d"], s["h"]), SOME("h", 29)),
      check((graph2, s["b","e"], s["a"]), SOME("a", 9)) ]

  fun checkS2D2G2() = combineCheck [
      check((graph2, s["a","b"], s["c","d"]), SOME("d", 1)),
      check((graph2, s["e","d"], s["a","h"]), SOME("a", 9)),
      check((graph2, s["c","d"], s["e","h"]), SOME("h", 29)),
      check((graph2, s["b","e"], s["a","c"]), SOME("a", 9)) ]

  fun checkS1D1G3() = combineCheck [
      check((graph3, s["s"], s["a"]), SOME("a", 0)),
      check((graph3, s["s"], s["b"]), SOME("b", 2)),
      check((graph3, s["s"], s["c"]), SOME("c", 1)),
      check((graph3, s["s"], s["d"]), SOME("d", 2)) ]

  fun checkS1D2G3() = combineCheck [
      check((graph3, s["s"], s["a","c"]), SOME("a", 0)),
      check((graph3, s["s"], s["a","b"]), SOME("a", 0)),
      check((graph3, s["s"], s["b","c"]), SOME("c", 1)),
      check((graph3, s["s"], s["a","d"]), SOME("a", 0)) ]

  fun checkS1D1G4() = combineCheck [
      check((graph4, s["s"], s["a"]), SOME("a", 2)),
      check((graph4, s["s"], s["b"]), SOME("b", 4)) ]

  fun all() = checkS1D1G1() andalso checkS2D1G2() andalso checkS2D2G2() andalso checkS1D1G3() andalso checkS1D2G3() andalso checkS1D1G4()

  (* 


  fun run2() = [
      passes((graph2,"a","b"), SOME 10),
      passes((graph2,"a","c"), SOME 7),
      passes((graph2,"c","c"), SOME 0),
      passes((graph2,"b","d"), SOME 2),
      passes((graph2,"a","d"), SOME 1),
      passes((graph2,"d","a"), SOME 16),
      passes((graph2,"d","b"), SOME 26),
      passes((graph2,"d","c"), SOME 23),
      passes((graph2,"a","h"), SOME 30)
      ]

  fun run2_n() = [
      passes_n((graph2,"a","b"), (SOME 10, 3)),
      passes((graph2,"a","c"), SOME 7),
      passes((graph2,"c","c"), SOME 0),
      passes((graph2,"b","d"), SOME 2),
      passes((graph2,"a","d"), SOME 1),
      passes((graph2,"d","a"), NONE),
      passes((graph2,"d","b"), NONE),
      passes((graph2,"d","c"), NONE)
      ]

*)
end

