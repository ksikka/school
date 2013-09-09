functor TableMIS(Table : TABLE where type Key.t = int) : MIS =
struct
  structure Rand = Random210
  open Table

  type 'a seq = 'a Seq.seq
  type vertex = key (* int *)
  type vertices = set
  type graph = vertices table

  (* Creates a graph from an edge seq. Includes edges in both directions. *)
  fun makeGraph (eF : (vertex * vertex) seq) : graph =
      let val eB = Seq.map (fn (u, v) => (v, u)) eF
      in map Set.fromSeq (collect (Seq.append (eF, eB)))
      end

  fun verticesToSeq (V : vertices) : vertex seq =
      Set.toSeq V

  (* The neighbors of a single vertex *)
  fun N (G : graph, v : vertex) =
      case find G v
        of NONE => Set.empty
         | SOME nbr => nbr

  (* The neighbors of a set of vertices. *)
  fun N' (G : graph, V : vertices) : vertices =
      reduce Set.union Set.empty (extract (G, V))

  (* Form a graph G = (V,E) and extract a subset of vertices V'
   * and the edges between them.
   *)
  fun subGraph(G : graph, V' : vertices) : graph =
      map (fn nbr => Set.intersection (nbr, V')) (extract (G, V'))

  (* Returns a maximal independent set of the graph G. *)
  fun MIS(G : graph) : vertices =
      let
        (* Returns a maximal independent set of the graph G based on
         * a random source rand.
         *)
        fun MIS' (G : graph, X : vertices, rand : Rand.rand) : vertices =
            if size G = 0 then X
            else let
              val V = domain G
              val R = Rand.hashInt rand
              val SOME minInt = Int.minInt

              fun isLocalMax (v : vertex) =
                  let val nbrVals = tabulate R (N (G, v))
                  in R v > reduce Int.max minInt nbrVals
                  end

              (* Select vertices that are a local maximum with respect to R. *)
              val inMIS = Set.filter isLocalMax V

              (* Remove inMIS and their neighbors from V. *)
              val V' = Set.difference (V, Set.union (inMIS, N' (G, inMIS)))
            in
              MIS' (subGraph (G, V'), Set.union (X, inMIS), Rand.next rand)
            end
      in
        MIS' (G, Set.empty, Rand.fromInt 0)
      end
end
