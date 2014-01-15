structure BoruvkaMST : MST =
struct
  structure STSeq = STArraySequence
  structure Seq = STSeq.Seq
  structure Rand = Random210
  open Seq

  type vertex = int
  type weight = int
  type edge = vertex * vertex * weight
  (* uniquely labeled edge *)
  type elabel = int
  type uedge = vertex * vertex * weight * elabel
 
  (* Some utility functions *)
  fun mapwIndex f S = (Seq.map2 f S (tabulate (fn i => i) (length S)))

(* Task 2.1 *)
fun MST (E,n) = let
  (* Sorted in desc. weight order for convenient use of inject *)
  val E = sort (fn (x,y) => Int.compare (#3 y, #3 x)) E

  (* Since weights are distinct, we know 2 edges of the same undirected
   * edge are next to each other in E. We will take every other Edge 
   * and enumerate them to form a labelling. *)
   (* serves as a table from label to edge *)
  val uniqE = Seq.tabulate (fn i => nth E (2*i)) (length E div 2)
  val enummedE = mapwIndex (fn ((u,v,w),i) => (u,v,w, i div 2)) E

  val getSome = (map Option.valOf) o (filter Option.isSome)

    fun MST' (L : vertex seq)
             (E : uedge seq)
             (mst : elabel seq list)
             (seed : Rand.rand) : elabel seq =
      if length E = 0 then Seq.flatten (Seq.fromList mst)
      else let
        (* Create a "table" where key is vertex and value is a 3-tuple
         * (nearest out neighbor, distance, unique label of connecting edge). *)
        val updates = map (fn (u,v,w,l) => (u,SOME (u,v,w,l))) E
        val minVMap = inject updates (tabulate (fn i => NONE) n)

        (* Add a sequence of min-edges to the MST. *)
        val minE : uedge seq = getSome minVMap
        val mst' : elabel seq list = (map (fn (_,_,_,l) => l) minE) :: mst

        (* star contract on the forest formed by min-edges *)
        val vflips = Rand.flip seed n
        fun isHook (u,v) = nth vflips u = 0 andalso nth vflips v = 1
        val hooks = filter isHook (map (fn (u,v,_,_) => (u,v)) minE)
        val L' = inject hooks L 
        val L'' = map (nth L') L'

        (* update E to have the new labels, and remove self loops *)
        fun relabel (u,v,w,l) = (nth L'' u, nth L'' v, w, l)
        fun notLoop (u,v,_,_) = u <> v
        val rake = (filter notLoop) o (map relabel) (* so functional! *)
        val E' = rake E
      
      in MST' L'' E' mst' (Rand.next seed)
      end

    (* Get the labels of the edges in the MST using helper function *)
    val mstUEdges = MST' (tabulate (fn i => i) n) enummedE [] (Rand.fromInt 0)

    (* Use inject to get *)
    val getSome = (map Option.valOf) o (filter Option.isSome)
    val mstEdges = getSome
                     (inject (map (fn l => (l, SOME (nth uniqE l))) mstUEdges)
                     (Seq.tabulate (fn _ => NONE) (length uniqE)))
  in mstEdges
  end


end
