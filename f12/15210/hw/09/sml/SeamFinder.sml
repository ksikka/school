structure SeamFinder :
sig
  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq

  type pixel = { r : real, g : real, b : real }
  type image = { width : int, height : int, data : pixel seq seq }
  type gradient = real

  val generateGradients : image -> gradient seq seq
  val findSeam : image -> int seq
end
=
struct
  structure Seq = ArraySequence
  open Seq

  exception NYI
  type pixel = { r : real, g : real, b : real }
  type image = { width : int, height : int, data : pixel seq seq }
  type gradient = real

  (* tabulates on 2d sequence *)
  fun tabulate2d f (m,n) =
    tabulate (fn i => tabulate (fn j => f (i,j)) m) n

  (* Task 2.1 *)
  fun generateGradients {width, height, data} : gradient seq seq =
    let
      (* Sum of differences squared for each rgb value *)
      fun pixelDiff (p1 as { r = r1, g = g1, b = b1 }
                   , p2 as { r = r2, g = g2, b = b2 }) =
        let
          val sqrd = (fn x => Math.pow (x,2.0))
        in (sqrd (r1-r2)) + (sqrd (g1-g2)) + (sqrd (b1-b2))
        end

      (* easier syntax to get value from 2d seq *)
      fun getData (i,j) = nth (nth data i) j

      (* given index of pixel, return its gradient value *)
      fun pixelGradient (i,j) =
        if i = (height-1) then 0.0
        else if j = (width-1) then Real.posInf
        else Math.sqrt ( (pixelDiff (getData (i,j),getData (i,j+1)))
                       + (pixelDiff (getData (i,j),getData (i+1,j))) )


    in tabulate2d pixelGradient (width,height)
    end

  (* Task 2.5 *)
    (* Generate seam table, which will be a list of
     *  the rows of the table, s.t. head is last row *)
  fun generateSeamCosts {width, height, data} : real seq list =
    let
      val gradients : real seq seq = generateGradients {width=width, height=height, data=data}
      fun updateSeamCosts (oldSeamCosts : real seq list ,rowIndex : int) : real seq list =
        let
          val newRow : real seq = if rowIndex = 0 then nth gradients 0
                                  else tabulate (fn i => 
              let
                val prevRow = List.hd oldSeamCosts
                val gcost = nth (nth gradients rowIndex) i
                fun nthWrap S n = nth S n handle _ => Real.posInf
                val (upleft,up,upright) = (nthWrap prevRow (i-1),nth prevRow i,nthWrap prevRow (i+1))
              in gcost + Real.min (Real.min (upleft,up),upright)
              end ) width
        in
          newRow :: oldSeamCosts
        end
    in iter updateSeamCosts [] (tabulate (fn i => i) height)
    end




  fun findSeam (im as {width, height, data}) : int seq =
    if Seq.length data = 0 then Seq.empty () else
    let
    (* map with item,index as input to function f *)
  fun mapWithIndex f S1 = map2 f S1 (tabulate (fn i => i) (length S1))
  fun minTuple ((a,b),(c,d)) = if a < c then (a,b) else (c,d)
  val zipWithIndex = mapWithIndex (fn i => i)
      val seamCosts = generateSeamCosts im
      
      (* Get the column index of the smallest cost seam cell *)
      val (_,i) = reduce minTuple (Real.posInf,0) (zipWithIndex (List.hd seamCosts))
      fun addToSeam (prevRow, seam) : int list =
        let
          val prevI = List.hd seam (* seam will not be nil *)
          val prevRow' = zipWithIndex prevRow
          fun nthWrap S n = nth S n handle _ => (Real.posInf,0)
          val (upleft,up,upright) = (nthWrap prevRow' (prevI-1),nth prevRow'
          prevI,nthWrap prevRow' (prevI+1))
          val (_,nextI) = minTuple (minTuple (upleft,up),upright)
        in nextI :: seam
        end
    in %(List.foldl addToSeam [i] (List.tl seamCosts))
    end



end
