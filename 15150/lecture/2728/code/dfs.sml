signature GRAPH =
sig
    type graph
    structure NodeSet : SET
    type node = NodeSet.El.t
    val successors : graph -> node -> NodeSet.set
end

structure IntGraph : GRAPH =
struct
    structure NodeSet = Set (IntLt)
    type graph = int -> NodeSet.set
    type node = NodeSet.El.t
    fun successors f x = f x
end

signature REACHABILITY =
sig
    structure G : GRAPH
    val reachable : G.graph -> G.node -> G.node -> bool
end

functor Test(R : sig
                     val reachable : IntGraph.graph -> IntGraph.node -> IntGraph.node -> bool
                 end) = 
struct
    val set = IntGraph.NodeSet.fromList
    val testg = fn 1 => set [2,3] | 2 => set [1,3] | 3 => set [4] | 4 => set []
    val true  = R.reachable testg 1 4
    val false = R.reachable testg 1 5
end

(* benign in sequential, but not parallel, contexts *)
functor ReachBenignSeq (G : GRAPH) : REACHABILITY = 
struct
    structure G = G    
    structure Visited = Set(G.NodeSet.El)

    val visited : Visited.set ref = ref Visited.empty

    fun reachable g start goal = 
        let 
          val () = visited := Visited.empty

          fun dfs (cur : G.node) : bool = 
              case G.NodeSet.El.compare (cur, goal) of 
                  EQUAL => true
                | _ => case Visited.member (!visited) cur of 
                      true => false
                    | false => (visited := (Visited.insert (! visited) cur);
                                (G.NodeSet.exists dfs (G.successors g cur)))
        in
            dfs start
        end
end
structure T = Test(ReachBenignSeq (IntGraph))

(* benign in all contexts *)
functor ReachBenignPar (G : GRAPH) : REACHABILITY =
struct
    structure G = G    
    structure Visited = Set(G.NodeSet.El)
        
    fun reachable g start goal = 
     let 
       val visited = ref Visited.empty

       fun dfs (cur : G.node) : bool = 
           case G.NodeSet.El.compare (cur, goal) of 
               EQUAL => true
             | _ => case Visited.member (!visited) cur of 
                   true => false
                 | false => (visited := (Visited.insert (! visited) cur);
                             (G.NodeSet.exists dfs (G.successors g cur)))
     in
         dfs start
     end
end
structure T = Test(ReachBenignPar (IntGraph))

(* functional version *)
functor ReachExplicitSP (G : GRAPH) : REACHABILITY =
struct
    structure G = G
    structure NodeSet = G.NodeSet
    structure Node = G.NodeSet.El
    structure Visited = Set(Node)

    type dfsresult = bool * Visited.set (* nodes you've visited so far *)

    fun reachable g start goal = 
        let 
            fun dfs (cur : Node.t) (visited : Visited.set) : dfsresult = 
                case Node.compare (cur, goal) of 
                    EQUAL => (true , visited)
                  | _ => (case Visited.member visited cur of 
                              true => (false , visited)
                            | false => dfs_children (G.successors g cur) (Visited.insert visited cur))
            and dfs_children (cs : NodeSet.set) (visited : Visited.set) : dfsresult = 
                case NodeSet.show cs of 
                    NodeSet.Nil => (false , visited)
                  | NodeSet.Cons(c1, cs) => 
                        case dfs c1 visited of 
                            (true , visited) => (true, visited) 
                          | (false , visited) => dfs_children cs visited

            val (b , _) = dfs start Visited.empty
        in
            b
        end
end
structure T = Test(ReachExplicitSP (IntGraph))

(* functional version using the store-passing monad *)
functor ReachMonadicSP (G : GRAPH) : REACHABILITY =
struct
    structure G = G
    structure Visited = Set(G.NodeSet.El)

    structure SP = StorePassing (struct type state = Visited.set end)
    structure SPUtils = SetMonadUtils (struct structure S = G.NodeSet structure T = SP end)
    open SP
    infix 7 >>=

    fun reachable g start goal = 
        let 
            fun dfs (cur : G.node) : bool comp = 
                case G.NodeSet.El.compare (cur, goal) of 
                    EQUAL => return true
                  | _ => get >>= (fn curVisited => 
                         case Visited.member curVisited cur of 
                              true => return false
                            | false => set (Visited.insert curVisited cur) >>= (fn _ => 
                                       (SPUtils.existsM dfs (G.successors g cur))))
        in
            run (dfs start) Visited.empty 
        end
end
structure T = Test(ReachMonadicSP(IntGraph))
