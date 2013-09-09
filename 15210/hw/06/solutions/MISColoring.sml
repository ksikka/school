structure MISColoring : COLORING =
struct
  structure Table = Default.IntTable
  structure Set = Table.Set
  structure MIS = TableMIS(Table)
  open MIS

  type color = int

  (* From a graph G = (V, E) extract a subset of vertices V' 
   * and the edges between them.
   *)
  fun subGraph (G, V') =
      Table.map (fn nbrs => Set.intersection (nbrs, V')) 
                (Table.extract (G, V'))

  fun graphColor E =
      let
        (* colors the MIS of G with n, recursing on the subgraph minus
         * the MIS with color n + 1.
         *)
        fun color (C, G, n) =
            if Table.size G = 0 then C
            else let
              val M = verticesToSeq (MIS G)
              val V' = Set.difference (Table.domain G, Set.fromSeq M)
              val G' = subGraph (G, V')
              val C' = Seq.append(C, Seq.map (fn v => (v, n)) M)
            in color (C', G', n + 1)
            end
      in color (Seq.empty (), makeGraph E, 0)
      end
end
