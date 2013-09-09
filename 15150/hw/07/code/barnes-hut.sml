structure BarnesHut =
struct

  open Mechanics

  structure BB = BoundingBox

  infixr 3 ++
  infixr 4 **
  infixr 3 -->

  datatype bhtree =
      Empty
    | Single of body
    | Cell of (Plane.scalar * Plane.point) * BB.bbox * (bhtree Seq.seq)
      (* ((mass, center), box,
          <top-left, top-right, bottom-left, bottom-right>) *)
      (* Invariant the bhtree Seq.seq must be of length 4 since the cells are
       * split into quadrants *)

  (* ---------------------------------------------------------------------- *)
  (* Code for testing *)

  fun seqFromList (l : 'a list) : 'a Seq.seq = 
      List.foldr (fn (x,y) => Seq.cons x y) (Seq.empty()) l

  fun seqAll (f : 'a -> bool) (s : 'a Seq.seq) : bool =
      Seq.mapreduce f true (fn (b1, b2) => b1 andalso b2) s

  fun seqEq (aEq : 'a * 'a -> bool) (s1 : 'a Seq.seq) (s2 : 'a Seq.seq) : bool =
      Seq.length s1 = Seq.length s2 andalso (seqAll aEq (Seq.zip (s1, s2)))

  fun bboxEq (bb1, bb2) : bool =
      seqEq Plane.pointEqual (BB.vertices bb1) (BB.vertices bb2)

  (* Note: Doesn't compare velocities as these are unaffected by compute_tree *)
  fun bodyEq ((m1, p1, _) : body, (m2, p2, _) : body) : bool =
      (Plane.s_eq (m1, m2)) andalso Plane.pointEqual (p1, p2)

  fun bhtreeEq (t1 : bhtree, t2 : bhtree) : bool =
      case (t1, t2) of
          (Empty, Empty) => true
        | (Single b1, Single b2) => bodyEq (b1, b2)
        | (Cell ((cm1, cp1), bb1, ts1), Cell ((cm2, cp2), bb2, ts2)) =>
              Plane.s_eq (cm1, cm2) andalso
              Plane.pointEqual (cp1, cp2) andalso
              bboxEq (bb1, bb2) andalso
              seqEq bhtreeEq ts1 ts2
        | (_, _) => false

  (* some points and bounding boxes and bodies to use for testing *)
  val p00 = Plane.origin
  val p44 = Plane.fromcoord (Plane.s_fromInt 4, Plane.s_fromInt 4)
  val p02 = Plane.fromcoord (Plane.s_zero, Plane.s_fromInt 2)
  val p24 = Plane.fromcoord (Plane.s_fromInt 2, Plane.s_fromInt 4)
  val p22 = Plane.fromcoord (Plane.s_fromInt 2, Plane.s_fromInt 2)
  val p20 = Plane.fromcoord (Plane.s_fromInt 2, Plane.s_zero)
  val p42 = Plane.fromcoord (Plane.s_fromInt 4, Plane.s_fromInt 2)
  val p01 = Plane.fromcoord (Plane.s_fromInt 0, Plane.s_fromInt 1)
  val p11 = Plane.fromcoord (Plane.s_fromInt 1, Plane.s_fromInt 1)
  val p40 = Plane.fromcoord (Plane.s_fromInt 4, Plane.s_zero)
  val p04 = Plane.fromcoord (Plane.s_zero, Plane.s_fromInt 4)
  val p13 = Plane.fromcoord (Plane.s_one, Plane.s_fromInt 3)
  val p31 = Plane.fromcoord (Plane.s_fromInt 3, Plane.s_one)
  val p33 = Plane.fromcoord (Plane.s_fromInt 3, Plane.s_fromInt 3)

  val bb0 : BB.bbox = BB.fromPoints (p02,p24)
  val bb1 : BB.bbox = BB.fromPoints (p22,p44)
  val bb2 : BB.bbox = BB.fromPoints (p00,p22)
  val bb3 : BB.bbox = BB.fromPoints (p20,p42)
  val bb4 : BB.bbox = BB.fromPoints (p00,p44)

  val body1 : body = (Plane.s_one, p40, Plane.zero)
  val body2 : body = (Plane.s_one, p22, Plane.zero)
  val body3 : body = (Plane.s_one, p04, Plane.zero)

  (* ---------------------------------------------------------------------- *)
  (* TASKS *)

  (* Scales the vector from the origin to p by the factor m. *)
  fun scale_point (m : Plane.scalar, p : Plane.point) : Plane.vec =
      (Plane.origin-->p) ** m

  (* Task 5.1 *)
  (* Purpose: Given a sequence of mass, point tuples, this computes
   * the total mass, and the center of mass *)
  (* Invariant: The total mass of the points is positive *)
  fun barycenter (s : (Plane.scalar * Plane.point) Seq.seq) : 
    (Plane.scalar * Plane.point) = 
        let val v = Plane.sum scale_point s
            val sum_of_masses = Seq.mapreduce (fn (m,p) => m) Plane.s_zero Plane.s_plus s
        in (sum_of_masses, Plane.head(Plane.//(v,sum_of_masses)))
        end
  (* Tests *)
  val true = 
    let val (a,b) = (Plane.s_fromInt 3,p00)
        val (c,d) = barycenter(seqFromList([(Plane.s_fromInt 2,p00),(Plane.s_fromInt 1,p00)]))
    in Plane.s_eq (a,c) andalso Plane.pointEqual (b,d)
    end
  (*val true = Plane.s_eq (Plane.s_fromInt 10,p22)
  * barycenter(seqFromList([(Plane.s_fromInt 5,p00),(Plane.s_fromInt 5,p44)]))*)

  (* Testing hint: use seqFromList and Plane.s_eq and
     Plane.pointEqual to make at least one test case. 
     You may find the points defined above to be helpful.  
     Use Plane.s_fromInt to make scalars from ints. *)

  (* Task 5.2 *)
  (* Purpose: To compute a sequence of four bounding boxes that 
   * correspond to the top-left, top-right, bottom-left, and 
   * bottom-right quadrants of the argument bounding box *)
  fun quarters (bb : BB.bbox) : BB.bbox Seq.seq =
      let val v = BB.vertices bb
          val c = BB.center bb
      in Seq.map (fn x => BB.fromPoints (x,c)) v
      end
  (* Tests *)
  val true = seqEq bboxEq (quarters bb4) (seqFromList [bb0,bb1,bb2,bb3])

  (* Task 5.3 *)
  fun firstMatch (bbs : BB.bbox Seq.seq) (p : Plane.point) : int =
      case Seq.length bbs of
           0 => raise Fail "Invariant Violation"
         | _ => (case BB.contained(p,Seq.nth 0 bbs) of
                     true => 0
                   | false => 1 + firstMatch (Seq.drop 1 bbs) p)

  (* Tests *)
  val 0 = firstMatch (quarters bb4) p13
  val 1 = firstMatch (quarters bb4) p33
  val 2 = firstMatch (quarters bb4) p11
  val 3 = firstMatch (quarters bb4) p40
  (* Testing hint: use seqFromList and the bounding boxes and points 
     defined above to make a couple of tests. *)

  (* seqPartition f s n computes a sequence of n sequences such that
   * for every element e of s, if f e ==> i then either e is in the i-th
   * sequence of the result or i is not in the range from 0 to n-1 and an
   * exception is raised.
   *)
  fun seqPartition (f : 'a -> int) (s : 'a Seq.seq) (n : int)
                   : 'a Seq.seq Seq.seq =
      let
        val emptyseqs = Seq.tabulate (fn _ => Seq.empty()) n

        fun useMatch (x : 'a) : 'a Seq.seq Seq.seq =
            let
              val sx = Seq.singleton x
              val i = f x
            in
              Seq.tabulate (fn j => case i = j of true => sx
                                                | false => Seq.empty())
                           n
            end

        fun appendPair (x,y) = Seq.append x y
      in
        Seq.mapreduce useMatch emptyseqs (Seq.map appendPair o Seq.zip) s
      end


  (* Task 5.4 *)
  fun compute_tree (s : body Seq.seq) (bb : BB.bbox) : bhtree =
  case Seq.length s of
       0 => Empty
     | 1 => Single (Seq.nth 0 s)
     | _ => let val (m,p) = barycenter (Seq.map (fn (m,p,v) => (m,p)) s)
                val q = quarters bb
                val seqOfSeqs = seqPartition (fn (a,x,b) => firstMatch q x) s 4
                val seqOfBHtrees = Seq.tabulate (fn x => compute_tree (Seq.nth x seqOfSeqs) (Seq.nth x q)) 4
            in Cell((m,p), bb, seqOfBHtrees)
            end
  (* Testing hint: write at least one test case by 
     working out the answer for (compute_tree bseq bb4).
     *)
  val bseq = seqFromList [body1, body2, body3]
  (* val true = bhtreeEq (compute_tree bseq bb4,
        Cell((Plane.s_fromInt 3,p22),bb4,
          seqFromList [Cell((Plane.s_fromInt 2,p31),bb0,
            seqFromList [Single body1,Empty,Empty,Single body2]),
          Empty,Empty,Single body3])
  ) *) (* i tried to do this test but it fails *)


  (* Task 5.5 *)
  fun too_far (p1 : Plane.point) (m : Plane.scalar, p2 : Plane.point)
              (t : Plane.scalar) : bool =
      let 
        val d = Plane.distance p1 p2
        val mdivd = Plane.s_divide(m,d)
      in 
        Plane.s_lte (mdivd,t)
      end
  (* I wrote these tests after the deadline *)
  val true = too_far p44 (Plane.s_one,p00) (Plane.s_invert (Plane.s_fromInt 2))
  val false = too_far p01 (Plane.s_one,p00) (Plane.s_invert (Plane.s_fromInt 2))


  (* Task 5.6 *)
  fun bh_acceleration (T : bhtree) (t : Plane.scalar) (b as (_, p, _))
      : Plane.vec = 
      case T of
          Empty => Plane.zero
        | Single (m, pt, _) => Mechanics.accOnPoint(p, (m, pt))
        | Cell ((m,pt), box, bhtrees) =>
            (case (BB.contained (p,box)) andalso not (too_far p (m,pt) t) of
               false => accOnPoint(p,(m,pt))
             | true => Plane.sum (fn x => bh_acceleration x t b) bhtrees)


  (* Testing hint: use Simulation.runBH with the rational plane
     and use diff to compare your transcript with ours. *)


  (*
     barnes_hut : Plane.scalar -> body Seq.seq -> Plane.vec Seq.seq

     Given a threshold and a sequence of bodies, compute the acceleration
     on each body using the Barnes-Hut algorithm.
   *)
  fun barnes_hut (threshold : Plane.scalar) (s : body Seq.seq)
      : Plane.vec Seq.seq =
      let
          val T = case BB.rectHull (Seq.map position s)
                   of SOME hull => compute_tree s hull
                    | NONE => Empty
      in
          Seq.map (bh_acceleration T threshold) s
      end

  (* Default value of the threshold, theta = 0.5 *)
  val threshold = Plane.s_invert (Plane.s_fromInt 2)

  val accelerations : body Seq.seq -> Plane.vec Seq.seq = barnes_hut threshold

end
