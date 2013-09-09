functor MSTTest(structure M : MST where type vertex = int) :
sig
  include TESTS
  structure Seq : SEQUENCE
  type mstinput = (int * int * int) Seq.seq * int
  type mstresult = (int * int * int) Seq.seq

  val spanning : mstresult * int -> bool
  val mstWeight : mstresult * int -> int
  val grader : mstinput * mstresult -> bool
end =
struct
  structure Seq = M.Seq
  open Seq

  type mstinput = (int * int * int) Seq.seq * int
  type mstresult = (int * int * int) Seq.seq

  fun both (a, b) = a andalso b
  fun allTrue S = reduce both true S
  fun undirect E = flatten (map (fn (u,v,w) => %[(u,v,w),(v,u,w)]) E)

  fun spanning (E, n) =
      let
        val E' = map (fn (u,v,_) => (u,v)) (undirect E)
        val updates = collect Int.compare E'
        val G = inject updates (tabulate (fn _ => empty ()) n)
        fun BFS X F =
            if length F = 0 then allTrue X
            else let
              val X' = inject (map (fn v => (v, true)) F) X
              val F' = filter (not o (nth X')) (flatten (map (nth G) F))
            in BFS X' F'
            end
      in n = 0 orelse BFS (tabulate (fn _ => false) n) (singleton 0)
      end

  fun update (i, v) S =
      tabulate (fn i' => if i' = i then v else nth S i') (length S)

  fun sumEdgeWts E = reduce op+ 0 (map (fn (_,_,w) => w) E)

  fun mstWeight (E, n) : int =
      let
        fun kruskal ((L, mst), e as (u, v, w)) =
            if nth L u = nth L v then (L, mst)
            else let
              val L' = update (nth L u, nth L v) L
              val L'' = map (nth L') L'
              val mst' = e::mst
            in (L'', mst')
            end

        val minEdge =
          fn ((_,_,w1),(_,_,w2)) => Int.compare (w1, w2)

        val sortedE = sort minEdge E
        val labelV = tabulate (fn v => v) n
        val (_, mst) = iter kruskal (labelV, []) sortedE
      in
        sumEdgeWts (%mst)
      end

  fun grader ((E, n), MST) =
      spanning (MST, n) andalso
      (n = 0 orelse length MST = n-1) andalso
      sumEdgeWts MST = mstWeight (E, n)

  val simpleTests =
    map (fn (E, n) => (undirect E, n))
    (%[
      (%[], 0),
      (%[], 1),
      (%[(0,1,1000000000)], 2),
      (%[(0,1,5),(1,2,1),(0,2,3)], 3),
      (* OPTIONAL: edge weights not unique *)
      (%[(0,1,3),(0,2,6),(1,3,2),(1,4,9),
         (2,3,2),(2,6,9),(3,5,8),(4,5,8),
         (4,9,18),(5,6,7),(5,8,9),(6,8,5),
         (6,7,4),(7,8,1),(7,9,4),(8,9,3)], 10)
    ])

  fun all () =
      allTrue (map (fn test => grader (test, M.MST test)) simpleTests)

end

structure BoruvkaTest = MSTTest(structure M = BoruvkaMST)
