functor Bridges(STSeq : ST_SEQUENCE) : BRIDGES =
struct
  structure Seq = STSeq.Seq
  open Seq

  type vertex = int
  type ugraph = vertex seq seq
  type edge = vertex * vertex
  type edges = edge seq

  fun makeGraph (e : edges) : ugraph =
      let
        (* Max label is |V|-1 *)
        val n = 1 + reduce Int.max 0 (map Int.max e)

        (* Duplicate edges in both directions *)
        val dup = map (fn (u,v) => %[(u,v),(v,u)]) e

        val updates = collect Int.compare (flatten dup)
      in inject updates (tabulate (fn _ => empty ()) n)
      end

  fun findBridges (g : ugraph) : edges =
      let
        val n = length g
        fun N(u) = nth g u
        fun visited X v = isSome (STSeq.nth X v)
        
        (* dfs p ((B, X, c, m), u)
         *
         *  p : vertex - parent of current vertex in dfs search tree
         *  u : vertex - current vertex being searched
         *
         *  -----STATE-----
         *  B : edge list - accumulate bridges
         *  X : int option stseq - stores dfs search order
         *  c : int - incrementing counter for dfs search order
         *  m : int - minimum vertex touched in dfs subtree
         *)
        fun dfs p ((B, X, c, m), u) =
            if visited X u then
              (B, X, c, Int.min (m, valOf (STSeq.nth X u)))
            else let
              val X' = STSeq.update (u, SOME c) X

              (* don't touch the parent vertex p *)
              val toVisit = filter (fn v => v <> p) (N(u))
              val (B', X'', c', m') = iter (dfs u) (B, X', c+1, n) toVisit

              (* if the lowest numbered vertex reachable from the dfs search
               * tree rooted at u is >= u, then (p, u) is a bridge.
               *)
              val B'' = if p <> u andalso m' >= c
                        then (p, u)::B' else B'
            in (B'', X'', c', Int.min (m, m'))
            end

        val V = tabulate (fn i => i) n
        val X = STSeq.fromSeq (tabulate (fn _ => NONE) n)
        val (B, _, _, _) = iter (dfs 0) ([], X, 0, 0) V
      in %B
      end
end
