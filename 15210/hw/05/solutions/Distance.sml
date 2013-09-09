functor Distance(Table : TABLE) : DISTANCE =
struct
  structure Table = Table
  structure Set = Table.Set
  structure Seq = Table.Seq
  structure PQ = Default.RealPQ

  open Table

  type vertex = Table.key
  type weight = real
  type distance = real
  type heuristic = vertex -> real
  type edge = vertex * vertex * weight

  (* This type maps each vertex u to [a map of each v such that (u,v) in E
   * to w(u,v)], notes whether any edge weights are negative, and keeps a
   * total vertex and total edge count. The edge count is not used by this
   * algorithm; it is present for auto-grading purposes. *)
  type graph = (weight table) table * bool * int * int

  fun makeGraph (edges : edge Seq.seq) : graph = let
    (* Take note of the presence of any negative edges *)
    fun any f S = Seq.reduce (fn (a,b) => a orelse b) false (Seq.map f S)
    val hasNeg = any (fn (_,_,w) => w < 0.0) edges
    
    (* Make sure to include vertices without outgoing edges! *)
    val forward = collect (Seq.map (fn (u,v,w) => (u,(v,w))) edges)
    val backward = fromSeq (Seq.map (fn (_,u,_) => (u, Seq.empty ())) edges)
    val seqTable = merge #1 (forward, backward)
  in
    (map fromSeq seqTable, hasNeg, size seqTable, Seq.length edges)
  end

  fun findPath (h : heuristic) (G as (g, hasNeg, n, m) : graph) S T = let
    (* Return minimum target in visited set X, if any is present. *)
    fun minTarget X = let
      val S = toSeq (extract (X, T))
      fun red (a as (_,d1), b as (_,d2)) = if d2 < d1 then b else a
    in
      if Seq.length S = 0 then NONE
      else SOME(Seq.reduce red (Seq.nth S 0) S)
    end
    
    (* Q0 is a PQ of (dist(v)+h(v), v, edges used in dist(v)) *)
    fun findPath' X Q0 steps =
      case PQ.deleteMin Q0
        of (NONE, _) => (minTarget X, steps)
         | (SOME (_, (v, dist, path)), Q) => 
            if not hasNeg andalso Set.find T v then
              (* For non-negative edge weights only, we can break out early. *)
              (SOME (v, dist), steps + 1)
            else if path > n then
              (* A path length of over n is at the front of the queue,
               * which implies that the path contains a negative cycle. *)
              (NONE, steps)
            else let
              val X' = insert #2 (v, dist) X
              
              fun relax (q, (u, w)) = let 
                val udist = dist + w
              in
                (* Only insert if not already visited with a shorter distance. *)
                if getOpt(find X' u, Real.posInf) <= udist then q
                else PQ.insert (udist + h(u), (u, udist, path+1)) q
              end
              val Q' = iter relax Q (valOf (find g v))
            in
              findPath' X' Q' (steps+1)
            end

    (* Initial queue contains the sources at dist 0 with 0 edges used. *)
    fun addSource (Q, s) = PQ.insert (h(s), (s, 0.0, 0)) Q
    val Q = Set.iter addSource (PQ.empty ()) S
  in
    findPath' (Table.empty ()) Q 0
  end
end

