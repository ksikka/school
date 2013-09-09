functor BridgesTest(B : BRIDGES where type vertex = int) : TESTS =
struct
  structure Seq = B.Seq

  (* * *           Utilities          * * *)
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

  fun genGraph (edgeList : (int * int) list) : B.ugraph =
    B.makeGraph (Seq.fromList edgeList)

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

  (*
   *       + - - - - - +   + - - - - - +
   *       |           |   |           |
   *       1 - 2 - 3 - 4 = 5 - 6 - 7 - 0
   *)
  val graph3 = genGraph [ (1,2),(2,3),(3,4),(4,1)
                        , (4,5)
                        , (5,6),(6,7),(7,0),(0,5) ]

  (*
   *       + - - - - - +   + - - - - - +   + - - - - - +   + - - - - - +
   *       |           |   |           |   |           |   |           |
   *       1 - 2 - 3 - 4 = 5 - 6 - 7 - 8 = 9 - 10- 11- 12= 13- 14- 15- 0
   *)
  val graph4 = genGraph [ (1,2),(2,3),(3,4),(4,1)
                        , (4,5)
                        , (5,6),(6,7),(7,8),(8,5)
                        , (8,9)
                        , (9,10),(10,11),(11,12),(12,9)
                        , (12,13)
                        , (13,14),(14,15),(15,0),(0,13) ]

  val tests = [ (graph1, [(1,2),(2,3),(3,0)])
              , (graph2, [])
              , (graph3, [(4,5)])
              , (graph4, [(4,5),(8,9),(12,13)])
              ]


  (* Checks if E1 is subset of E2, and vice versa.
      inefficient, but easy to write *)
  fun cmpEdgeSeqs (E1,E2) : bool =
    let
      (* Normalize the order of ints within tuples in an (int * int) seq *)
      val fixEdgeOrd = Seq.map (fn (a,b) => if (a <= b) then (a,b) else (b,a))
      val (E1,E2) = (fixEdgeOrd E1, fixEdgeOrd E2)
      fun membership S x =
        case Seq.showl S of
             Seq.NIL => false
           | Seq.CONS(y,ys) => if x = y then true else membership ys x
    in Seq.reduce (fn (a,b) => a andalso b) true
         (Seq.append (Seq.map (membership E2) E1, Seq.map (membership E1) E2))
    end

  fun execTest (G,expOut) =
    let
      val expOut = Seq.fromList expOut
      val actOut = B.findBridges G
    in
      if cmpEdgeSeqs (expOut,actOut) then
        true
      else
        let val () = print (strInject
                       "Failed Test:  \n  Expected: 0  \n  Result: 1  \n"
                       [edgeSeqToString expOut, edgeSeqToString actOut])
        in false end
    end

  fun all () = List.foldl (fn (a,b) => b andalso execTest a) true tests
end
