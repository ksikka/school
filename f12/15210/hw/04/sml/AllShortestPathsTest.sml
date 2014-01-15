structure AllShortestPathsTest =
struct
  structure IntASP = IntASP
  structure Set = Default.IntSet
  structure StringSeqSet = Default.StringSeqTable.Set
  open IntASP
  (* 1. List of edges which desribe the graph,
     2. Start of all shortest paths
     3. End of all shortest paths *)
  type input = edge list * vertex * vertex

  (* 1. Num Edges
     2. Num Vertices
     3. All shortest paths *)
  type output = int * int * (vertex list list)
  type testbundle = input * output
  val tests : testbundle list =
    [
      (* Base Case*)
      (([],0,0),(0,0,[[0]])),

      (* One directed edge, two vertices*)
      (([(1,2)],1,2),(1,2,[[1,2]])),

      (* One directed edge, two vertices*)
      (([(2,1)],1,2),(1,2,[[]])),

      (* One bidirectional edge, two vertices*)
      (([(1,2),(2,1)],1,2),(2,2,[[1,2]])),

      (* Crazy-ass graph *)
      (([(1,2),
         (1,3),
         (2,4),
         (2,5),
         (3,6),
         (3,7),
         (4,9),
         (5,9),
         (6,8),
         (7,8),
         (9,10),
         (8,10)],1,10),(12,10,[[1,2,4,9,10],
                               [1,2,5,9,10],
                               [1,3,6,8,10],
                               [1,3,7,8,10]])),

      (* Crazy-ass graph *)
      (([(1,2),
         (1,3),
         (2,4),
         (2,5),
         (3,6),
         (3,7),
         (4,9),
         (5,9),
         (6,8),
         (7,8),
         (9,10),
         (8,10)],1,9),(12,10,[[1,2,4,9],
                              [1,2,5,9]])),

      (* Crazy-ass graph *)
      (([(1,2),
         (1,3),
         (2,4),
         (2,5),
         (3,6),
         (3,7),
         (4,9),
         (5,9),
         (6,8),
         (7,8),
         (9,10),
         (8,10)],1,7),(12,10,[[1,3,7]]))
    ]

  fun listToString f l : string =
    List.foldl (fn (a,b) => (f a) ^ ", " ^ b) "" l
  fun tupleToString (a,b) = "(" ^ (Int.toString a)^ "," ^ (Int.toString b) ^ ")"

  fun numETest anumE enumE =
    if anumE = enumE then true
    else let 
     val () = print ("numEdges returned " ^ (Int.toString anumE) ^ "\n")
     in false end

  fun numVTest anumV enumV =
    if anumV = enumV then true
    else let 
     val () = print ("numVertices returned " ^ (Int.toString anumV) ^ "\n")
     in false end

  (* Converts int seq seq to string seq seq, and then does a set compare. *)
  fun aspTest aasp easp =
    let
      val aasp = Seq.map (Seq.map Int.toString) aasp
      val easp = Seq.map (Seq.map Int.toString) easp
      val aasp = StringSeqSet.fromSeq aasp
      val easp = StringSeqSet.fromSeq easp
    in if StringSeqSet.equal (aasp,easp) then true
       else let val () = print ("report returned "
                                ^ (StringSeqSet.toString aasp) ^ "\n")
            in false end
    end
    
  fun test ((given, expected) : testbundle) : bool =
    let
      val (edges, v1, v2) = given
      val (enumE, enumV, easp) = expected
      val (edges, easp) = (Seq.fromList edges
                        , Seq.fromList (List.map Seq.fromList easp))
      val () = print ("Testing:"
          ^ "\tE = " ^ (Seq.toString tupleToString edges)
        ^ "\n\tv1 = " ^ (Int.toString v1)
        ^ "\n\tv2 = " ^ (Int.toString v2) ^ "\n")
      val G = makeGraph edges
      val (anumE, anumV) = (numEdges G, numVertices G)
      val asp = makeASP G v1
      val aasp = report asp v2
    in
      (numETest anumE enumE) andalso (numVTest anumV enumV)
        andalso (aspTest aasp easp)
    end


  fun all () = let val () = print "Beginning tests: \n\n"
    in
      List.foldl (fn (a,b) => (test a) andalso b) true tests
    end
end

