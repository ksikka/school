functor SequenceMIS(STSeq : ST_SEQUENCE) : MIS =
struct
  structure Seq = STSeq.Seq
  structure Rand = Random210
  open Seq

  type vertex = int
  type vertices = int seq
  type edge = vertex * vertex
  type graph = vertices seq

  fun makeGraph (e : edge seq) : graph =
      let
        (* Max label is |V|-1 *)
        val n = 1 + reduce Int.max 0 (map Int.max e)

        (* Duplicate edges in both directions *)
        val dup = map (fn (u,v) => %[(u,v),(v,u)]) e

        val updates = collect Int.compare (flatten dup)
      in inject updates (tabulate (fn _ => empty ()) n)
      end

  fun verticesToSeq V = V

  local
    (* Tags vertices as either in the MIS (YES),
     * not in the MIS (NO), or to be decided (RE i)
     * reindexed as i in V and G
     *)
    datatype mislabel = YES | NO | RE of int
    val SOME minInt = Int.minInt
    exception NoVertex

    (* If v \in V, idx L v ==> index of v in V *)
    fun idx L v =
        case STSeq.nth L v
          of RE i => i
           | _ => raise NoVertex

    (* Evaluates to true iff v \in V *)
    fun inV L v = (idx L v = idx L v) handle NoVertex => false

    (* Tags all vertices in V with the mislabel x *)
    fun decide (x : mislabel, V) = STSeq.inject (map (fn v => (v, x)) V)
  in
    fun MIS (G : graph) : vertices =
        let
          val n = length G
          val allV = tabulate (fn v => v) n

          (* MIS' (L, V, G, seed)
           *
           *  L : mislabel stseq - stores the state of each vertex
           *  V : vertex seq - current vertices; if V[i] = v then L[v] = RE i
           *  G : vertices seq - current subgraph; reindexed w.r.t. V
           *  seed : rand - Random210 seed value
           *)
          fun MIS' (L, V, G, seed) =
              if length V = 0 then
                filter (fn v => STSeq.nth L v = YES) allV
              else let
                fun nbrs v = nth G (idx L v)
                val R = Rand.hashInt seed

                fun isLocalMax v =
                    let val nbrVals = map R (nbrs v)
                    in R(v) > reduce Int.max minInt nbrVals
                    end

                (* Decide vertices in MIS for this round *)
                val inMIS = filter isLocalMax V
                val outV = flatten (map nbrs inMIS)
                val L' = decide (YES, inMIS) (decide (NO, outV) L)

                (* Build subgraph using L' *)
                val V' = filter (inV L') V
                val G' = map (filter (inV L') o nbrs) V'

                (* Reindex each v \in V' with its index in V' *)
                val reindex = tabulate (fn i => (nth V' i, RE i)) (length V')
                val L'' = STSeq.inject reindex L'
              in
                MIS' (L'', V', G', Rand.next seed)
              end

          val L = STSeq.fromSeq (tabulate RE n)
        in MIS' (L, allV, G, Rand.fromInt 0)
        end
  end
end
