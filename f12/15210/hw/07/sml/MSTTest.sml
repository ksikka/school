functor MSTTest(structure M : MST where type vertex = int) :
sig
  include TESTS
  structure Seq : SEQUENCE
  type mstinput = (int * int * int) Seq.seq * int
  type mstresult = (int * int * int) Seq.seq

  val spanning : mstresult * int -> bool
  val mstWeight : mstinput -> int
  val grader : mstinput * mstresult -> bool
end =
struct
  open M
  open Seq

  type mstinput = (int * int * int) seq * int
  type mstresult = (int * int * int) seq

  structure Table = Default.IntTable
  structure Set = Table.Set

  (* Updates an element of a normal sequence in O(n) *)
  fun update (i, v) S =
      tabulate (fn i' => if i' = i then v else nth S i') (length S)

  (* Task 2.2 *)
  (* Verifies that the edges in E connect all vertices in [0,n-1] *)
  fun spanning (E, n) : bool = if n < 2 then true else
    let
      val E = map (fn (u,v,_) => (u,v)) E
      (* make an Adjacency Table to do BFS more conveniently *)
      val inclFlipEdges = flatten o (map (fn (u,v) => %[(u,v),(v,u)] ))
      val makeUGraph = (Table.map Set.fromSeq) o Table.collect o inclFlipEdges
      val G = makeUGraph E
      val V = Set.fromSeq (tabulate (fn i => i) n)

      fun BFS (X : Set.set, F : Set.set) =
        if Set.size F = 0 then X
        else
          let
            val Nbrs = Table.reduce Set.union Set.empty
                              (Table.tabulate (Option.valOf o (Table.find G)) F)
            val X' = Set.union (X,F)
            val F' = Set.difference(Nbrs,X')
          in
            BFS (X',F')
          end

      fun reachable G = if Table.size G = 0 then Set.empty
                        else BFS (Set.empty, Set.singleton 0)
    in
      Set.equal (reachable G, V)
    end



  fun sumEdgeWts E = reduce op+ 0 (map (fn (_,_,w) => w) E)

  (* Task 2.3 *)
  (* Computes the MST weight of a graph by running an inefficient
   * implementation of Kruskal's algorithm. You must complete
   * the implementation by replacing each 'raise NotYetImplemented'
   * with your own code.
   *)
  fun mstWeight (E, n) : int =
      let
        fun kruskal ((L, mst), e as (u, v, w)) =
            if nth L u = nth L v then (L, mst)
            else let
              val L' = update (nth L u, nth L v) L
              val L'' = map (nth L') L'
              val mst' = e :: mst
            in (L'',mst')
            end

        val minEdge : edge ord =
          fn ((_,_,w1),(_,_,w2)) => Int.compare (w1, w2)

        val sortedE = sort minEdge E
        val labelV = tabulate (fn v => v) n
        val (_, mst) = iter kruskal (labelV, []) sortedE
      in
        sumEdgeWts (%mst)
      end

  (* Task 2.4 *)
  (* Verify that MST is correct for the given input (E, n) *)
  fun grader (G as (E, n), mst : edge seq) : bool =
    let
      fun maxV E  = reduce Int.max 0 (map (fn (x,y,_) => Int.max (x,y)) E)
      fun noCycles E = maxV mst + 1 = n 
      val a = noCycles G 
      val b = spanning G 
      val c = mstWeight G = sumEdgeWts mst
    in
      a andalso b andalso c
    end


  (* Undirects a sequence containly ONLY directed edges *)
  fun undirect E = flatten (map (fn (u,v,w) => %[(u,v,w),(v,u,w)]) E)

  fun both (a, b) = a andalso b
  fun allTrue S = reduce both true S

  (* complete graph with 5 vertices *)
  val g1 = %[(0,1),(0,2),(0,3),(0,4),(1,2),(1,3),(1,4),(2,3),(2,4),(3,4)]

  (* linked list *)
  val g2 = %[(0,1),(1,2),(2,3),(3,4),(4,5)]

  (* two stars where every member of star A
   * is connected to some member of star B, and vice versa *)
  val g4 = %[(0,1)
           , (0,2)
           , (0,3)
           , (0,4)
           , (0,5)
           , (6,7)
           , (6,8)
           , (6,9)
           , (6,10)
           , (6,11)
           , (6,12)
           , (6,13)
           , (1,7)
           , (2,8)
           , (3,9)
           , (4,10)
           , (5,11)
           , (5,12)
           , (5,13)
           , (0,6)
            ]

  (* Task 2.4 *)
  (* Runs a suite of tests on the argument MST structure *)
  fun all () : bool =
      (* for each graph, call grader. *)
    let
      (* for now just enumerate the weights. *)
      fun assignRandWeight E =
        let fun help E n =
          case showl E of
             NIL => empty ()
           | CONS((u,v),xs) => append (singleton (u,v,n), help xs (n+1))
        in help E 1
        end

      val graphs = map (undirect o assignRandWeight) (%[g1,g2,g4])
      fun maxV G  = reduce Int.max 0 (map (fn (x,y,_) => Int.max (x,y)) G)
      fun test G =
        let
          val b = 1 + (maxV G)
          val out = M.MST (G,b)
        in grader ((G,b),out)
        end
    in
      Seq.iter (fn (a,b) => a andalso test b) true graphs
    end

end

structure BoruvkaTest = MSTTest(structure M = BoruvkaMST)
