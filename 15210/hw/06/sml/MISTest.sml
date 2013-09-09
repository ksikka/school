functor MISRunner(MIS : MIS where type vertex = int) :
sig
  structure Seq : SEQUENCE

  (* Generates test results on graphs with n vertices *)
  val results : int -> int Seq.seq Seq.seq
end =
struct
  structure Seq = MIS.Seq
  open Seq

  type edge = MIS.vertex * MIS.vertex
  type testcase = edge seq

  (* Generates a sequence of test cases on n vertices including but not
   * limited to: a cycle graph, a star graph, and a complete graph.
   *)
  fun genCases (n : int) : testcase seq =
    %[
      (* Cycle Graph *)
      Seq.append (Seq.singleton (0,n-1), Seq.tabulate (fn i => (i,i+1)) (n-1)),

      (* Star Graph *)
      Seq.tabulate (fn i => (0,i+1)) (n-1),

      (* Complete Graph *)
      Seq.filter (fn (x,y) => x < y)
        (Seq.flatten
          (Seq.tabulate (fn i => Seq.tabulate (fn j => (i,j)) n) n))

      (* Feel free to add more *)
     ]

  val MIS : testcase -> MIS.vertex seq =
    (Seq.sort Int.compare) o MIS.verticesToSeq o MIS.MIS o MIS.makeGraph

  fun results (n : int) =
      map MIS (genCases n)
end

structure SeqMIS = MISRunner(SequenceMIS(STArraySequence))
structure TabMIS = MISRunner(TableMIS(Default.IntTable))

structure MISTest : TESTS =
struct
  open ArraySequence
  (* string utility... *)
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

  fun seqEq elemEq (X, Y) =
      reduce (fn (a, b) => a andalso b) true (map2 elemEq X Y)

  fun testCaseEq (X,Y) =
    if seqEq (fn (a,b) => a = b) (X,Y) then true
    else let
           val () = print (strInject "X: 0\nY:1\n\n" [toString Int.toString X,
                                                      toString Int.toString Y])
         in false
         end

  fun all () =
    let
      val testSizes = fromList [4,8,16,300]
      val tabImplResults = map TabMIS.results testSizes
      val seqImplResults = map SeqMIS.results testSizes
      val testResults = map2 (seqEq testCaseEq) tabImplResults seqImplResults
    in reduce (fn (a,b) => a andalso b) true testResults
    end
end
