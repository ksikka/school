functor MISColoringTest(MIS : MIS where type vertex = int) : TESTS =
struct

  structure MISColoring = MISColoring
  structure Seq = MISColoring.Seq

  (* * *           Utilities          * * *)
  fun genGraph edgeList =
    Seq.fromList edgeList

  (* strInject: Similar to the format function in python but not as cool.
   * Example:
   *   strInject "0, 12" ["Hello","World","!"]
   *     => "Hello, World!"
   * Note: If the highest 0-9 char is "n", then the list should be size n.
   * *)
  fun strInject str S =
    let
      fun f (ch : char) : string =
        case Int.fromString (String.str ch) of
             NONE => String.str ch
          |  SOME n => List.nth (S,n)
    in String.translate f str
    end

  (* edgeSeqToString: Given an (int * int) seq,
   *                  returns the string representation.
   * Example:
   *   edgeSeqToString (Seq.fromList [(1,2)(3,4)])
   *     => "<{1,2},{3,4}>"
   *)
  val edgeSeqToString =
    let
      fun edgeToString (x,y) =
        strInject "{0,1}" [Int.toString x, Int.toString y]
    in
      Seq.toString edgeToString
    end

  (*
   *       1 = 2 = 3 = 0
   *)
  val graph1 = genGraph [(1,2),(2,3),(3,0)]

  (*
   *       + - - - - - +
   *       |           |
   *       1 - 2 - 3 - 0
   *)
  val graph2 = genGraph [(1,2),(2,3),(3,0),(0,1)]

  val graph3 = genGraph [(0,1),(2,3),(1,2),(1,3),(3,4),(4,5),(2,6)]

  val tests = [ graph1
              , graph2
              , graph3
              ]

  fun seqContains S x =
    case Seq.showl S of
         Seq.NIL => false
       | Seq.CONS(y,ys) => if x = y then true else seqContains ys x

  (* Returns true iff V x V \intersection E = {} *)
  fun testIndependence E V =
    let
      val allPossibleEdges = Seq.flatten
        (Seq.tabulate
          (fn i => Seq.tabulate
             (fn j => (Seq.nth V i,Seq.nth V j)) (Seq.length V))
          (Seq.length V))
      val edgeExistsSeq = Seq.map (not o seqContains E) allPossibleEdges
    in
      Seq.reduce (fn (x,y) => x andalso y) true edgeExistsSeq
    end


  fun execTest E =
    let
      val coloring = MISColoring.graphColor E (* vertex , color *)
      val colorClasses = Seq.collect Int.compare
                                     (Seq.map (fn (v,c) => (c,v)) coloring)
      val indepSeq = Seq.map (testIndependence E)
                             (Seq.map (fn (_,V) => V) colorClasses)
    in
      if Seq.reduce (fn (a,b) => a andalso b) true indepSeq then
        true
      else
        let val () = print (strInject
                              "Failed Test:  \n  E: 0  \n"
                              [edgeSeqToString E])
        in false end
    end

  fun all () = List.foldl (fn (a,b) => b andalso execTest a) true tests
end
