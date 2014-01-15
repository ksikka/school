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

  (* Task 4.1 *)
  (* Compute the barycenter of a sequence of point-masses *)
  (* Invariant: The total mass of the points is positive *)
  fun barycenter (s : (Plane.scalar * Plane.point) Seq.seq) :
      Plane.scalar * Plane.point =
      let
        val totmass = Seq.mapreduce (fn (m, _) => m) Plane.s_zero Plane.s_plus s
        val weighted_sum = Plane.sum scale_point s
      in
        (totmass, Plane.head (weighted_sum ** (Plane.s_invert totmass)))
      end

  val // = Plane.//
  infixr 3 //

  (* Testing hint: use seqFromList and Plane.s_eq and
     Plane.pointEqual to make at least one test case.
     You may find the points defined above to be helpful.
     Use Plane.s_fromInt to make scalars from ints.
     *)
  local
      val (barymass,baryloc) =
          barycenter (seqFromList [(Plane.s_one,p00), (Plane.s_one,p02)])
  in
      val true = Plane.s_eq(barymass, Plane.s_fromInt 2)
      val true = Plane.pointEqual(baryloc, p01)
  end

  (* Task 4.2 *)
  (* Compute the sequence of the four quadrants of the bounding box *)
  fun quarters (bb : BB.bbox) : BB.bbox Seq.seq =
      let
        val corners = BB.vertices bb
        val c = BB.center bb
      in
        Seq.map BB.fromPoints (Seq.zip (corners,
                                        Seq.tabulate (fn _ => c) 4))
      end

  (* Testing hint: use seqFromList and seqEq and bboxEq
     to make at least one test case.
     You may find the bboxes defined above to be helpful. *)
  val true = seqEq bboxEq
                   (seqFromList [bb0, bb1, bb2, bb3])
                   (quarters(bb4))

  (* Task 4.3 *)
  (* firstMatch bbs p evaluates to i if BB.contained (p, Seq.nth bbs i) is true
   * and for every j, 0<=j<i, BB.contained (p, Seq.nth bbs j) is false.
   * If BB.contained (p, Seq.nth bbs i) is false for every i from 0 to
   * Seq.length i, firstMatch raises an exception
   *)
  fun firstMatch (bbs : BB.bbox Seq.seq) (p : Plane.point) : int =
      let
        val len = Seq.length bbs

        fun matchFrom (i : int) : int =
            case Int.compare (i, len) of
                LESS =>
                (case BB.contained (p, Seq.nth i bbs) of
                     true => i
                   | false => matchFrom (i+1))
              | _ => raise Fail "Invariant violation"
      in
        matchFrom 0
      end

  (* Testing hint: use seqFromList and the bounding boxes and points
     defined above to make a couple of tests. *)
  val 2 = firstMatch (seqFromList [bb0, bb1, bb2, bb3]) p11
  val 1 = firstMatch (seqFromList [bb0, bb1, bb2, bb3]) p33


  (* Projects the mass and center from the root node of a bhtree *)
  fun center_of_mass (T : bhtree) : Plane.scalar * Plane.point =
      case T of
          Empty => (Plane.s_zero, Plane.origin)
        | Single (m, p, _) => (m, p)
        | Cell (com, _, _) => com

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
        Seq.mapreduce useMatch emptyseqs ((Seq.map appendPair) o Seq.zip) s
      end

  (* Task 4.4 *)
  (* Computes the Barnes-Hut tree for the bodies in the given sequence.
   * Invariant: all the bodies are contained in the given bounding box *)
  fun compute_tree (s : body Seq.seq) (bb : BB.bbox) : bhtree =
      (case Seq.length s of
           0 => Empty
         | 1 => Single (Seq.nth 0 s)
         | _ =>
               let
                 val quadrants : BB.bbox Seq.seq = quarters bb
                 val compquad : Plane.point -> int = firstMatch quadrants

                 val quadbodies : body Seq.seq Seq.seq =
                     seqPartition (compquad o position) s 4

                 (* Do the recursive calls in parallel *)
                 val subtrees : bhtree Seq.seq =
                     Seq.map (fn (s', bb') => compute_tree s' bb')
                             (Seq.zip (quadbodies, quadrants))


                 val (m, center) = barycenter (Seq.map center_of_mass subtrees)
               in
                   Cell ((m, center), bb, subtrees)
               end)

  (* Testing hint: write at least one test case by
     working out the answer for (compute_tree bseq bb4).
     *)
  local
      val bseq = seqFromList [body1, body2, body3]

      val subtree = Cell ((Plane.s_fromInt 2, p13), bb0,
                          seqFromList [Single body3, Empty, Empty, Single body2])

      val resulttree = Cell ((Plane.s_fromInt 3, p22), bb4,
                             seqFromList [subtree, Empty, Empty, Single body1])
  in
      val true = bhtreeEq (compute_tree bseq bb4, resulttree)
  end

  (* Task 4.5 *)
  (* too_far p1 (m, p2) t determines if a group of points with total mass m and
   * barycenter p2 is can be treated as a single pseudo particle when computing
   * the acceleration on p1 using the threshold t.
   *)
  fun too_far (p1 : Plane.point) (m : Plane.scalar, p2 : Plane.point)
              (t : Plane.scalar) : bool =
      Plane.s_lte (Plane.s_divide (m, Plane.distance p1 p2), t)

  (* Task 4.6 *)
  (* Computes the acceleration on b from the tree T using the Barnes-Hut
   * algorithm with threshold t
   *)
  fun bh_acceleration (T : bhtree) (t : Plane.scalar) (b as (_, p, _))
      : Plane.vec =
      case T of
          Empty => Plane.zero
        | Single (mass, loc, _) => accOnPoint (p, (mass, loc))
        | Cell ((mass, loc), box, qseq) =>
              case (not (BB.contained (p, box))) andalso
                   (too_far p (mass, loc) t) of
                  true => accOnPoint (p, (mass, loc))
                | false =>
                  Plane.sum (fn quad => bh_acceleration quad t b) qseq

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
