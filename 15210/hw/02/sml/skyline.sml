functor Skyline (S : SEQUENCE) : SKYLINE =
struct

  structure Seq = S 

  open Primitives

  exception Impossible

  (* scanI : ('a * 'a -> 'a) -> 'a -> 'a seq -> 'a seq
   *   Inclusive scan. Output sequence will be same length as input sequence *)
  fun scanI f b s =
    let
      val (s', v) = Seq.scan f b s
      val s' = Seq.subseq s' (1,Seq.length s' - 1)
    in Seq.append (s', Seq.singleton v)
    end

  (* skyline : ( int * int * int ) Seq -> ( int * int ) Seq 
   *   Given a list of buildings (in l,h,r form), skyline 
   *   returns a list of points, sorted by x value, such 
   *   that you can draw the skyline. Redundant points 
   *   are omitted. See the homework2 handout of the F12 semester 
   *   for a more formal definition. *)
  fun skyline S = 
    let
      fun skyline' S' =
        case Seq.showt S' of
            Seq.EMPTY => Seq.empty ()
          | Seq.ELT (l,h,r) => Seq.fromList [(l,h),(r,0)]
          | Seq.NODE (L,R) =>
              let
                val (skyA,skyB) = par ((fn () => skyline' L),(fn () => skyline' R))
                (* Each is guaranteed to be sorted by x-value as well as
                 * guaranteed to be a well formed skyline. *)
                val xFromA = Seq.map (fn (x,_) => (x,NONE)) skyA
                val xFromB = Seq.map (fn (x,_) => (x,NONE)) skyB
                val skyA = Seq.map (fn (x,y) => (x, SOME y)) skyA
                val skyB = Seq.map (fn (x,y) => (x, SOME y)) skyB
                (* tupleOrdering : (int * int) * (int * int) -> order *)
                fun tupleOrdering ((x,_),(y,_)) = Int.compare (x,y)
                (* By merging, you are bringing the x-points back together again *)
                val skyAMerged = Seq.merge tupleOrdering skyA xFromB
                val skyBMerged = Seq.merge tupleOrdering skyB xFromA
                (* Sorting invariant maintained *)
                fun optionCopy ((_,y),(z,w)) =
                  case w of
                    NONE => (z,y)
                  | SOME _ => (z,w)
                (* copy-scan to replace NONE with the closest SOME to its left.
                 *   Represents filling in the skyline. *)
                val skyAMerged = scanI optionCopy (0,SOME 0) skyAMerged
                val skyBMerged = scanI optionCopy (0,SOME 0) skyBMerged
              in
                (* Guaranteed a correspondence between elements in the
                 *   two sequences. They will have the same x values.
                 *   Taking the max of the y's is where the skyline is made. *)
                Seq.map2 (fn ((a,SOME b),(_, SOME d)) => (a,Int.max(b,d))) skyAMerged skyBMerged
              end
      
      val points = skyline' S

      (* Omit redundant points *)

      (* prevSameHeight : ( int * int ) Seq -> int -> ( ( int * int ) * bool ) Seq 
       *   returns itself in a tuple, but adds a field which will be true
       *   iff the building behind it does not have the same height as it. *)
      fun prevSameHeight points i =
        if i = 0 then
          (Seq.nth points i,true)
        else
          let
            val (currX,currY) = Seq.nth points i
            val (_    ,prevY) = Seq.nth points (i-1)
          in
            ((currX,currY),(currY <> prevY))
          end
      val points = Seq.tabulate (prevSameHeight points)  (Seq.length points)
      val points = Seq.filter (fn (_,pred) => pred) points
      val points = Seq.map (fn (pt,_) => pt) points
    in
      points
    end
end
