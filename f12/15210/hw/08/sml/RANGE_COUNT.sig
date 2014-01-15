signature RANGE_COUNT =
sig
   structure Table : ORD_TABLE where type Key.t = int

   type countTable

   val makeQueryTable: Point2D.point Table.Seq.seq -> countTable
   val countInRange: countTable -> Point2D.point*Point2D.point -> int
end

