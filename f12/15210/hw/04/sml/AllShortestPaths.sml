functor AllShortestPaths (Table : TABLE) : ALL_SHORTEST_PATHS =
struct

  structure Table = Table
  structure Set = Table.Set
  structure Seq = Table.Seq

  type vertex = Table.key
  type edge = vertex * vertex
  type path = vertex Seq.seq
  type graph = {
                 gtable: Set.set Table.table
               , numE : int
               , numV : int
               }
  (* graph is an adjacency table where the key is a vertex
           and the value is a set of the out-neighbors.
           The table data structure makes for quick neighbor lookups,
           and having the values as sets will allow for union with other
           sets in sub-linear time. important feature for the makeASP function.
           Also the number of edges is cached. *)
  
  type parentTable = Set.set Table.table
  type asp = parentTable
  (* asp is a table from a child vertex to its parents in the 
         BFS tree. This is feasible to build during makeASP,
         and allows the implementation of report to be within
         cost bounds. *)

  (* Task 2.1 *)
  fun makeGraph (E : edge Seq.seq) : graph =
    let
      val gt = Table.map Set.fromSeq (Table.collect E)
      val nE = Seq.length E
      (*
      val nV = Set.size (Set.union ((Set.fromSeq (map (fn x => #1 x)
      E)),(Set.fromSeq (map (fn x => #2 x) E)))) *)
      val nV = let val first = (Set.fromSeq (Seq.map (fn (a,_) => a) E))
                   val second = (Set.fromSeq (Seq.map (fn (_,b) => b) E))
                   val verts = Set.union (first,second)
               in Set.size verts end
                  
    in {  gtable = gt
        , numE = nE
        , numV = nV }
    end

  (* Task 2.2 *)
  fun numEdges (G : graph) : int = #numE G
    
  fun numVertices (G : graph) : int = #numV G

  (* Task 2.3 *)
  fun outNeighbors (G : graph) (v : vertex) : vertex Seq.seq =
    case Table.find (#gtable G) v of
         NONE => Seq.empty ()
       | SOME vs => Set.toSeq vs

  (* Task 2.4 *)
  fun taggedNgh (G : graph) (F : Set.set) : parentTable =
    let
      (* given a vertex v, will return a table from neighbor to a singleton
       * set of v*)
      fun tagLocalNgh v = Table.tabulate (fn _ => Set.singleton v)
                                         (Set.fromSeq (outNeighbors G v))
      (* want this table for all vertices in the frontier, and then want them 
       * to merge. *)
      val vNghMap = Table.tabulate tagLocalNgh F
    in
      (* this takes the table of tables, and squashes all the values into
         the desired table. *)
      Table.reduce (Table.merge Set.union) (Table.empty ()) vNghMap
    end

  (* Do a BFS, and at each node, modify the asp to produce a
       BFS tree table. *)
  fun makeASP (G : graph) (v : vertex) : asp =
    let
      fun makeBFStree (X : parentTable) (F : parentTable) : parentTable =
        if Table.size F = 0 then X
        else let
          (* mark frontier nodes as visited, and if they are already visited,
             then union their parents together. *)
          val X' = Table.merge Set.union (X,F)
          val neighborhood = taggedNgh G (Table.domain F)
          val F' = Table.erase(neighborhood, Table.domain X')
            in makeBFStree X' F'
            end
    in makeBFStree (Table.empty ()) (Table.singleton (v,Set.singleton v))
    end

  (* Task 2.5 *)
  fun report (bfsTree : asp) (destV : vertex) : (vertex Seq.seq Seq.seq) =
    let
      fun report' (vs : vertex Seq.seq) : vertex list Seq.seq =
        let
          fun pathsToVertex v : vertex list Seq.seq =
            case Table.find bfsTree v of
                 NONE => Seq.singleton []
               | SOME parents =>
                  if (Set.size parents = 1) andalso (Set.find parents v)
                    then Seq.singleton [v]
                  else
                    Seq.map (fn path => v :: path) (report' (Set.toSeq parents))
        in Seq.flatten (Seq.map pathsToVertex vs)
        end
      fun reverse r = Seq.tabulate (fn i => Seq.nth r (Seq.length r - 1 - i))
                                                          (Seq.length r)
    in Seq.map (reverse o Seq.fromList) (report' (Seq.singleton destV))
    end

end

structure IntASP = AllShortestPaths(Default.IntTable)
structure RealASP = AllShortestPaths(Default.RealTable)
structure StringASP = AllShortestPaths(Default.StringTable)
