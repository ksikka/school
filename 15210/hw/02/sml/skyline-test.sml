functor SkylineTest (SKLN : SKYLINE) : TESTS =
struct
  
  structure Skyline = SKLN

fun testSkyline inputList outputList tf=
    let
      val inputSeq = SKLN.Seq.fromList inputList
      val outputSeq = SKLN.skyline inputSeq
      val actualOutputList = SKLN.Seq.iter (fn (x,y) => x@[y]) [] outputSeq
      val result = (outputList = actualOutputList) = tf
      in result
      end

  val tests = [ 
                ([(1,3,4),
                  (3,2,11),
                  (6,6,8),
                  (7,4,10)],[(1,3),
                             (4,2),
                             (6,6),
                             (8,4),
                             (10,2),
                             (11,0)],
                                    true),
                ([(1,3,4),
                  (3,2,11),
                  (6,6,8),
                  (7,4,10)],[(1,3),
                             (6,6),
                             (8,4),
                             (10,2),
                             (11,0)],
                                    false),
                ([],[],true),
                ([(0,1000,5000),
                  (0,5,10), 
                  (50,55,100), 
                  (100,65,104), 
                  (150,85,1234), 
                  (200,95,3244)],[(0,1000),(5000,0)],true)]

  fun all () = let
                   val () = print "Testing Skyline\n"
                   val testResult = List.foldr (fn ( (a,b,c), res ) => (testSkyline a b c) andalso res) true tests
               in testResult
               end

end
