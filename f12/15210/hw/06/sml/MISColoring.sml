structure MISColoring : COLORING =
struct
  structure Table = Default.IntTable
  structure Set = Table.Set
  structure MIS = TableMIS(Table)
  open MIS

  type color = int

  fun graphColor (E : (vertex * vertex) seq) : (vertex * color) seq =
    let
      val graph = MIS.makeGraph E

      (* Given a graph and a list of colors, use MIS to find a
         coloring if possible. You should give deg(v) + 1 colors. *)
      fun graphColor' (G : MIS.graph) (colorsList : color list) : color Table.table =
        if Table.size G = 0 then Table.empty ()
        else if List.null colorsList then raise Fail "need more colors"
        else let
          (* Independent vertices can get same color *)
          val X = MIS.MIS G
          val coloredX = Table.tabulate (fn v => List.hd colorsList) X

          (* Remove X from G to contract the graph *)
          val V' = Set.difference (Table.domain G, X)
          val G' = Table.map (fn nbr => Set.intersection (nbr, V'))
                                                      (Table.extract (G, V'))
        in
          Table.merge (fn _ => raise Fail "color collision")
                      (coloredX, graphColor' G' (List.tl colorsList))
        end

      val maxDeg = Seq.reduce Int.max 0 (Seq.map Set.size (Table.range graph))
      val colors = List.tabulate (1 + maxDeg, fn i => i)
      val colorTbl = graphColor' graph colors
    in
      Table.toSeq colorTbl
    end
end
