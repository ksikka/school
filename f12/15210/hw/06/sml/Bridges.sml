functor Bridges(STSeq : ST_SEQUENCE) : BRIDGES =
struct
  structure Seq = STSeq.Seq
  structure Rand = Random210

  type 'a seq = 'a Seq.seq
  type vertex = int
  type edge = vertex * vertex
  type edges = edge seq

  (* Adjacency list structure gives lowest runtime for simple DFS.
   * Table not needed here because vertexes are 0...|V|-1 *)
  type ugraph = (vertex seq) seq

  (* Makes an undirected edge into two directed edges.
   * Then does some stuff to make an Adjacency List. *)
  fun makeGraph (edges : edge seq) : ugraph =
    let val edges' = Seq.flatten (Seq.map
                               (fn (u,v) => Seq.fromList [(u,v),(v,u)])
                                edges)
        val collectedEdges = Seq.sort (fn (x,y) => Int.compare (#1 x,#1 y))
                                      (Seq.collect Int.compare edges')
    in Seq.map (fn (v,adjVs) => adjVs) collectedEdges
    end
    
  fun optMin (o1,o2) =
    case (o1,o2) of
         (NONE,_) => raise Fail "uh oh 1"
       | (_,NONE) => raise Fail "uh oh 2"
       | (SOME x, SOME y) => SOME (Int.min (x,y))

  fun findBridges (G : ugraph) : edge seq =
    if Seq.length G = 0 then Seq.empty ()
    else let
      val nones = STSeq.fromSeq (Seq.tabulate (fn i => NONE) (Seq.length G))

      fun DFS (((dfsOrds : int option STSeq.stseq)
               ,(cycNums : int option STSeq.stseq)
               ,(bridges : edge list)
               ,(count   : int))
             , ((prev : vertex)
               ,(v    : vertex)))
           : (int option STSeq.stseq) * (int option STSeq.stseq) * (edge list) * int=
        case STSeq.nth dfsOrds v of
             SOME _ => (* Already been here.*)
                       (dfsOrds,cycNums,bridges,count)
           | NONE =>
               let
                 val nbrs = Seq.nth G v
                 (* Setting up base case for the following iter *)
                 val dfsOrds' = STSeq.update (v,SOME count) dfsOrds
                 val cycNums' = STSeq.update (v,SOME count) cycNums
                 val count' = count + 1

                 (* This is what to do iteratively accross neigbors *)
                 fun enter (state,nbr) = 
                   if nbr = prev
                     then state (* skip if nbr is predecessor *)
                   else let
                     val (dfsOrds'',cycNums'',bridges',count'')
                                                        = DFS (state,(v,nbr))
                     (* cycNum is min of preorder and neighbor cycnums.
                      * This is essentially doing a min-fold across cycnums.*)
                     val cycNums''' = STSeq.update
                                       (v,optMin
                                           (STSeq.nth cycNums'' v
                                          , STSeq.nth cycNums'' nbr))
                                         cycNums''
                    in (dfsOrds'',cycNums''',bridges',count'')
                    end

                 (* Enter the neighbors in the DFS *)
                 val iterNbrs = Seq.map (fn nbr => (v,nbr)) nbrs
                 val state' = Seq.iter enter
                                         (dfsOrds',cycNums',bridges,count') nbrs

                 (* After updating the cycNums, if this cycNum = dfsOrd,
                  * the edge (prev,v) is not in a cycle. *)
                 val bridges' = if Option.valOf (STSeq.nth (#2 state') v)
                                        = Option.valOf(STSeq.nth (#1 state') v)
                                            (* No bridge on "start" edge case *)
                                            andalso (v <> prev)
                                   then (prev,v) :: (#3 state')
                                   else (#3 state')

               in (#1 state', #2 state', bridges', #4 state')
               end

      val V = Seq.tabulate (fn i => (i,i)) (Seq.length G)
      val (_,_,edges,_) = Seq.iter DFS (nones,nones,[],0) V
    in Seq.fromList edges
    end

end
