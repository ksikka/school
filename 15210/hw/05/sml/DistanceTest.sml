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


  fun check heur ((G,S,D),r) = 
    let
       fun answerString a =
          case a of
            NONE => "NONE"
          | SOME(v,i) => "SOME(" ^ v ^ ", " ^ (Int.toString i)^")"
       val (r',s) = findPath heur G S D
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


  val checkNull = check nullHeuristic

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

  (* Graph with a negative edge weight *)
  val graph3 = genGraph
               [(("a","b"),5),(("b","c"),1),(("a","d"),4),
                (("b","d"),~3),(("d","c"),1)]

  (* Graph with a negative cycle *)
  val graph4 = genGraph
               [(("a","b"),0),(("b","c"),0),(("c","a"),~1),
                (("c","d"),1)]

  fun checkS1D1G1() = combineCheck [
      checkNull((graph1, s["a"], s["a"]), SOME("a", 0)),
      checkNull((graph1, s["a"], s["b"]), SOME("b", 3)),
      checkNull((graph1, s["a"], s["c"]), SOME("c", 1)),
      checkNull((graph1, s["c"], s["b"]), SOME("b", 2)),
      checkNull((graph1, s["b"], s["a"]), NONE),
      checkNull((graph1, s["d"], s["a"]), NONE)
      ]

  fun checkS2D1G2() = combineCheck [
      checkNull((graph2, s["a","b"], s["d"]), SOME("d", 1)),
      checkNull((graph2, s["e","d"], s["h"]), SOME("h", 22)),
      checkNull((graph2, s["c","d"], s["h"]), SOME("h", 29)),
      checkNull((graph2, s["b","e"], s["a"]), SOME("a", 9)) ]

  fun checkMultipleDests() = checkNull((graph2, s["c","d"], s["g","h"]), SOME("g", 12))

  fun checkNegEdgeWeights() = checkNull((graph3, s["a"], s["c"]), SOME("c", 3))

  fun checkNegCycles() = checkNull((graph4, s["a"], s["d"]), NONE)

  (* Designed to take fewer visits with a good heuristic *)
  val graph5 = genGraph
               [(("a","b"),0),
                (("a","c"),0),
                (("a","d"),1),
                (("c","e"),5),
                (("b","e"),5),
                (("d","e"),3)]

  fun customH v = case v of
                       "a" => 6.0
                     | "b" => 5.0
                     | "c" => 5.0
                     | "d" => 3.0
                     | "e" => 0.0
                     | _ => raise Fail "vertex outside of a-e"

  fun checkAStar() = check customH ((graph5, s["a"], s["e"]),(SOME("e",4)))

  val tests = [checkS1D1G1,
               checkS1D1G1,
               checkMultipleDests,
               checkNegEdgeWeights,
               checkNegCycles,
               checkAStar]

  fun all() = List.foldl (fn (a,b) => a() andalso b) true tests

end

