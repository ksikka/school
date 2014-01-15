functor SequenceMIS(STSeq : ST_SEQUENCE) : MIS =
struct
  structure Seq = STSeq.Seq
  structure Rand = Random210

  type 'a seq = 'a Seq.seq

  type vertex = int
  type vertices = int seq
  type edge = (vertex * vertex)


  (* Adjacency list,
       acts as vertex -> seq of neighbors with O(1) lookup.
     If graph[i] is NONE, then i is not a vertex in the graph. *)
  type graph = ((vertex seq) option) seq

  fun verticesToSeq V = V

  (* Usage: exampleSet[i] = true iff i is in the set *)
  type arrSet = bool seq

  (* UTILITY FUNCTIONS FOR A BIT VECTOR IMPLEMENTATION OF A SET *)

  fun arrSetFind S e = Seq.nth S e

  fun arrSetUnion (S1 : arrSet) (S2 : arrSet) =
    let
      val maxLen = Int.max (Seq.length S1, Seq.length S2)
      fun extendSeq (S : 'a seq) (n : int) (b : 'a) =
                  Seq.tabulate (fn i => Seq.nth S i handle _ => b) n
      val S1' = extendSeq S1 maxLen false
      val S2' = extendSeq S2 maxLen false
    in
      Seq.map2 (fn (a,b) => a orelse b) S1' S2'
    end

  fun arrSetIntrsct (S1 : arrSet) (S2 : arrSet) = 
                                     Seq.map2 (fn (a,b) => a andalso b) S1 S2

  fun arrSetDiff (S1 : arrSet) (S2 : arrSet) =
                                     Seq.map2 (fn (a,b) =>
                                                if b then false else a) S1 S2

  fun emptyArrSet n = Seq.tabulate (fn _ => false) n

  fun vSeqToArrSet (V : vertex seq) : arrSet =
    let
      val max = Seq.reduce Int.max 0 V
    in Seq.inject (Seq.map (fn v => (v,true)) V) (emptyArrSet (1 + max))
    end

  fun arrSetToVSeq (Vset : arrSet) : vertices =
                  Seq.filter (arrSetFind Vset)
                             (Seq.tabulate (fn i => i) (Seq.length Vset))
  (* END ARRSET FUNCTIONS *)


  fun subGraph (G : graph, V : arrSet) : graph =
    Seq.map2 (fn (NONE, _) => NONE 
               | (SOME nbrs, inclP) =>
                   if inclP then SOME (Seq.filter (arrSetFind V) nbrs)
                   else NONE) G V


  (* Makes an undirected edge into two directed edges.
   * Then does some stuff to make an Adjacency List.
   * Sorts neighbors for O(V) merge between neighbors *)
  fun makeGraph (edges : edge seq) : graph =
    let val edges' = Seq.flatten (Seq.map
                               (fn (u,v) => Seq.fromList [(u,v),(v,u)])
                                edges)
        val collectedEdges = Seq.sort (fn (x,y) => Int.compare (#1 x,#1 y))
                                      (Seq.collect Int.compare edges')
    in Seq.map (fn (v,adjVs) => SOME(Seq.sort Int.compare adjVs)) collectedEdges
    end

  (* The neighbors of a single vertex,
     throws exception if v is not in the graph. *)
  fun N (G : graph, v : vertex) : vertex seq = Option.valOf (Seq.nth G v)

  fun N' (G : graph, V : vertex seq) : vertex seq =
    let
      val nbrSeqs = Seq.map (fn v => N (G,v)) V
    in
      Seq.reduce (fn (s1,s2) => Seq.merge Int.compare s1 s2)
                 (Seq.empty ())
                 nbrSeqs
    end

  (* Returns a maximal independent set of the graph G. *)
  fun MIS(G : graph) : vertices =
    let
      (* Returns a maximal independent set of the graph G based on
       * a random source rand.
       *)
      fun MIS' (G : graph, X : arrSet, rand : Rand.rand) : arrSet =
        let
          val Vset : arrSet = Seq.map Option.isSome G
          val V = arrSetToVSeq Vset
        in if Seq.length V = 0 then X
          else let
            val R = Rand.hashInt rand
            val SOME minInt = Int.minInt

            fun isLocalMax (v : vertex) =
                let val nbrVals = Seq.map R (N (G, v))
                in R v > Seq.reduce Int.max minInt nbrVals
                end

            (* Select vertices that are a local maximum with respect to R. *)
            val inMIS = Seq.filter isLocalMax V

            (* Remove inMIS and their neighbors from V. *)
            val nbrs = N' (G,inMIS)

            val (nbrSet,inMISSet) = (vSeqToArrSet nbrs, vSeqToArrSet inMIS)
            val Vset' = arrSetDiff Vset (arrSetUnion inMISSet nbrSet)
          in
            MIS' (subGraph (G, Vset'), arrSetUnion X inMISSet, Rand.next rand)
          end
        end
    in
      arrSetToVSeq (MIS' (G, Seq.empty (), Rand.fromInt 0))
    end

end
