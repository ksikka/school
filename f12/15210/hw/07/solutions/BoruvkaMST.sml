structure BoruvkaMST : MST =
struct
  structure Seq = ArraySequence
  structure R = Random210
  open Seq

  type vertex = int
  type weight = int
  type edge = vertex * vertex * weight

  fun MST (E, n) =
      let
        val getSome = (map valOf) o (filter isSome)
        
        fun MST' (L, E, T, seed) =
            if length E = 0 then T
            else let
              val rn = nth L (* Relabels vertices according to L *)

              (* Find minimum out-edge of every vertex *)
              fun indexE (e as (u,v,w)) = (rn u, SOME e)
              val minOpt = inject (map indexE E) (map (fn _ => NONE) L)
              val minEdges = getSome minOpt
              
              (* Identify hook edges from tails to heads *)
              val F = R.flip seed n
              fun isHook (u,v,_) = nth F (rn u) = 0 andalso nth F (rn v) = 1
              val hooks = filter isHook minEdges
              
              (* Update vertex labels *)
              val L' = inject (map (fn (u,v,_) => (rn u, rn v)) hooks) L
              val L'' = map (nth L') L'
              val rn' = nth L''
              
              (* Identify contracted edges and add to MST *)
              fun contracted (u,v,w) = nth L'' (rn u) = (rn v)
              val inMST = filter contracted hooks
              val T' = append (T, inMST)
              val E' = filter (fn (u,v,_) => rn' u <> rn' v) E
            in
              MST' (L'', E', T', R.next seed)
            end

        val maxEdge : edge ord = 
          fn ((_,_,w1),(_,_,w2)) => Int.compare (w2, w1)

        val sortedE = sort maxEdge E 
        val labelV = tabulate (fn v => v) n
      in
        MST' (labelV, sortedE, empty (), R.fromInt 210)
      end
end
