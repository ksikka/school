functor RangeCount(Table : ORD_TABLE where type Key.t = int) : RANGE_COUNT =
struct
  structure Table = Table
  structure Seq = Table.Seq
  structure Point = Point2D

  type 'a seq = 'a Seq.seq
  type 'a table = 'a Table.table
  type point = Point.point

  (* This is an ordered table where the key is 
   * an x-coordinate of a point, and the value is
   * { a table where the keys are y-coordinates of
   *   all points which have x values less than or
   *   equal to the outermost key. } *)
  type countTable = (unit table) table

  (* Sorts the points in ascending x order. 
   * Then takes advantage of the sorted property
   * to create the countTable data structure. *)
  fun makeQueryTable (S : point seq) : countTable =
    let
      val S' = Seq.sort (fn ((x1,_),(x2,_)) => Int.compare (x1,x2)) S
      fun addToTable (T,(x,y)) : (unit table) table =
        let
          val prevVal : unit table = case Table.previous T x of
                             NONE => Table.empty ()
                           | SOME (_,yTree) => yTree
          val newVal : unit table = Table.insert (fn _ => raise Fail "")
                                                      (y,()) prevVal
        in Table.insert (fn _ => raise Fail "") (x,newVal) T
        end

    in Seq.iter addToTable (Table.empty ()) S'
    end

  fun countInRange (T : countTable)
                   ((xLeft, yHi) : point, (xRght, yLo) : point) : int  =
    let
      (* Gets the tree of y's which is rightmost to xRight *)
      val yTreeR = case Table.find T xRght of
                        NONE => (case Table.previous T xRght of
                                      NONE => Table.empty ()
                                    | SOME (_,yT) => yT)
                      | SOME yT => yT
      (* Get's the tree of y's which is rightmost but excluding xLeft *)
      val yTreeL = case Table.previous T xLeft of
                      NONE => Table.empty ()
                    | SOME (_,yT) => yT
      (* Restricts the y's of both of them to the y-range *)
      val infLeftBoxR = Table.getRange yTreeR (yLo,yHi)
      val infLeftBoxL = Table.getRange yTreeL (yLo,yHi)
    in
      (* Subtracts sizes of the rectangular regions to get
       * the size of the specified rectangular region. *)
      (Table.size infLeftBoxR) - (Table.size infLeftBoxL)
    end
end
