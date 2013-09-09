functor RangeCount(Table : ORD_TABLE where type Key.t = int) : RANGE_COUNT = 
struct
  structure Table = Table
  structure Seq = Table.Seq
  structure Point = Point2D
  structure R = Real

  type 'a seq = 'a Seq.seq
  type 'a table = 'a Table.table
  type point = Point.point

  type countTable = unit table table
  open Table
  exception NYI
 
  (* Assumes points do not have duplicate x or duplicate y values *)
  fun makeQueryTable (S : point seq) : countTable =
      let
          (* Table mapping x to y *)
          val xT =  Table.fromSeq S

          fun firstArg (a, b) = a 

          (* adds in y value into table yT *)
          fun addIn (yT, (_,y)) = Table.insert firstArg (y, ()) yT

          (* Table mapping x to a Table mapping y' to () for all points 
           * (x', y') such that x' <= x *)         
          val (th,t) = Table.iterh addIn (Table.empty ()) xT
      in
          th
      end
        
  fun countInRange (xT : countTable) ((xLeft, yHi) : point, (xRght, yLo) : point) : int  =
      let
          fun prevVal T k =
              case previous T k
               of NONE => NONE
                | SOME(_,v) => SOME v

          fun prevInclVal T k = 
              case find T k  
               of NONE => prevVal T k
                | vOpt => vOpt

          fun getCount T (lo, hi) =
            case T
             of NONE => 0
              | SOME T' => size (getRange T' (lo, hi))

          val szLeft = getCount (prevVal xT xLeft) (yLo, yHi)
          val szRight = getCount (prevInclVal xT xRght) (yLo, yHi)
      in
          szRight - szLeft
      end
end
