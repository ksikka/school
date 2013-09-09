functor Distance(Table : TABLE) : DISTANCE =
struct
  structure Table = Table
  structure Set = Table.Set
  structure Seq = Table.Seq
  structure PQ = Default.RealPQ

  type vertex = Table.key
  type weight = real
  type edge = vertex * vertex * weight
  type heuristic = vertex -> real

(* graph
     #1 is a vertex -> (vertex -> weight) table
     #2 is true if and only if there exists an edge with negative weight
     #3 is a vertex -> #_of_in_neighbors table *)
  type graph = ((weight Table.table) Table.table * bool * int Table.table)

(* makeGraph edges
     makes a vertex -> (vertex -> weight) table
     also checks if there exists a negative edge
     also creates a vertex -> #_of_in_neighbors table *)
  fun makeGraph (edges : edge Seq.seq) : graph =
    let
      fun edgeSeqToGraph es =
        let
          val es' = Seq.map (fn (a,b,c) => (a,(b,c))) edges
          val t = Table.collect es'
        in Table.map Table.fromSeq t
        end

      (* are there any negative edges? *)
      val noNegEdges = Seq.reduce
                         (fn (a,b) => a andalso b)
                         true
                         (Seq.map (fn (_,_,w) => w >= 0.0) edges)

      (* transpose to get in-neighbor count *)
      val transpEdges = Seq.map (fn (a,b,c) => (b,a,c)) edges

    in (edgeSeqToGraph edges,
        noNegEdges,
        Table.map (fn a => Table.size a) (edgeSeqToGraph transpEdges))
    end

(* addNodesToPQ nodeWeightPairs Q b
     Adds the nodeWeightPairs to the Q
     Adds b to every weight (for A* and Dijkstra's) *)
  fun addNodesToPQ S Q offset : (vertex * real) PQ.pq =
      Seq.iter
        (fn (pq,(v,w)) => PQ.insert (offset + w,v) pq)
        Q S

(* outNeighbors G v
     Returns outneighbors of v, in a sequence, along with their weights *)
  fun outNeighbors (G : graph) v =
    case Table.find (#1 G) v of
         NONE => Seq.empty ()
       | SOME T => Table.toSeq T

(* findPath h G S T
     Works as advertised in the handout *)
  fun findPath h G S T : ((vertex * weight) option * int) =
    let
      val distances : real Table.table = Table.empty ()
      val pq = addNodesToPQ
                 (Seq.map (fn v => ((v,0.0),h v)) (Set.toSeq S))
                 (PQ.empty ()) 0.0
      val noNegEdges : bool = #2 G
      val inNeighborCt : int Table.table = #3 G

    (* decrement (I,v)
         Returns I with the value of v decreased.
         Returns it with a false if the value of v goes below ~1
         The previous condition indicates negative cycle in Dijkstra's *)
      fun decrement (I,v) : int Table.table * bool =
        case Table.find I v of
             NONE => (Table.insert Int.min (v,0) I, false)
           | SOME n => (Table.insert Int.min (v,n - 1) I, n < ~1)


    (* dijkstra X F I c
         Runs an iteration of dijkstra's algorithm with
           X as the distance table, F as the PQ, I as a
           negative cycle detection table, and c as a
           count of visited nodes. *)
      fun dijkstra (X : real Table.table) (* Distances *)
                   (F : (vertex * real) PQ.pq)     (* Priority Q Frontier *)
                   (I : int Table.table)  (* Exp. visit ct (cycle detection) *)
                   (c : int)              (* Running total of visited nodes *)
                      : (real Table.table * int Table.table) option * int =
        if PQ.isEmpty F then (SOME (X,I),c) (* Base Case *)
        else
          let
            (* prioritized on A* function, but d' is the distance to currNode *)
            val (SOME (d,(currNode,d')), F')  = PQ.deleteMin F
              (* guaranteed to return SOME because of the prior if statement *)
            val dPrev = Table.find X currNode
          in
                (* Check if current d is less than a value in the table,
                 * because this is possible in a graph with negative edges *)
            if not (Option.isSome dPrev) orelse
                                d' < (Option.valOf dPrev) then
            (* Visit *)
               let
                 val X' = Table.insert Real.min (currNode,d') X
                 val ngh = Seq.map
                             (fn (v,w) => ((v,d'+w),w)) (* hack to make A* work *)
                             (outNeighbors G currNode) 
                 val F'' = if noNegEdges andalso Set.find T currNode
                             (* Stop algorithm early if a target is found *)
                             then PQ.empty ()
                           else
                             (* "Relax" Edges *)
                             addNodesToPQ ngh F' (d' + (h currNode))
                 (* Decrement number of in-neighbors for cycle-detection *)
                 val (I',negCycle) = decrement (I,currNode)
               in if negCycle then
                    (NONE, (c+1))
                  else
                    dijkstra X' F'' I' (c + 1)
               end
            else
            (* Skip since this node is already visited. *)
              dijkstra X F' I c
          end

    in case dijkstra distances pq inNeighborCt 0 of
            (NONE, visits) => (NONE, visits)
          | (SOME (distances,_), visits) =>
              let
                (* Post processing to get the final answer *)
                val distances = Table.toSeq (Table.extract (distances, T))
              (* minVertexDist
                   Return the v,weight pair with the smaller w
                   Return SOME in favor of NONE *)
                val minVertexDist =
                      (fn (NONE,x) => x
                        | (x, NONE) => x
                        | (SOME (v1,w1),SOME (v2,w2)) =>
                                if w1 < w2 then SOME (v1,w1) else SOME (v2,w2))
                val answer = Seq.reduce minVertexDist NONE
                                 (Seq.map (fn x => SOME x) distances)
              in
                (answer, visits)
              end
    end

end
