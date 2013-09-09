functor RangeCountTest (structure R : RANGE_COUNT) :> TEST =
struct
  structure Table = R.Table
  structure Seq = Table.Seq
  val testgrid = Seq.fromList [ (1,1)
                              , (~2,2)
                              , (~3,~3)
                              , (4,~4)
                              , (5,5)
                              , (~6,6)
                              , (~7,~7)
                              ]
  val qt = R.makeQueryTable testgrid

  val testCases =[ 
                   (((0,2),(2,0)),1)
                 , (((~3,3),(2,0)),2)

                 (* a bunch of edge cases *)
                 , (((~3,3),(1,0)),2)
                 , (((~2,3),(2,0)),2)
                 , (((~3,2),(2,0)),2)
                 , (((~3,3),(2,1)),2)

                 , (((~10,10),(10,~10)),7)
                 , (((~100,10),(~90,~10)),0)
                 ]

  fun runTestCase ( ((xLeft,yHi), (xRight,yLow)) , count) =
    let
      val count' = R.countInRange qt ((xLeft,yHi), (xRight,yLow))
      val pass = count = count'

      val () = if pass then () else
                print ("Failed Test: (" ^ (Int.toString xLeft) ^ "," ^ (Int.toString yHi) ^ ")"
                                ^ ",(" ^ (Int.toString xRight) ^ "," ^ (Int.toString yLow) ^ ")"
                                  ^ " returned " ^ (Int.toString count')
                                  ^ " instead of " ^ (Int.toString count) ^ "\n")
    in pass
    end

  fun all () = List.foldl (fn (b,a) => a andalso (runTestCase b)) true testCases
end
structure B = BSTOrderedTable(structure Tree = Treap(Default.IntHashKey)
                              structure Seq = ArraySequence);
structure R = RangeCount(B);

(* Use this for testing *)
structure TestPartTwo = RangeCountTest(structure R = R);
