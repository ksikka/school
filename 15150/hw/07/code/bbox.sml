structure BoundingBox :> BBOX =
struct

  type bbox = Plane.point * Plane.point
           (* (ll, ur) where ll is the lower left corner of the box and
            *                ur is the upper right corner of the box
            *)

  fun toString ((p1, p2) : bbox) : string =
      "(" ^ (Plane.pointToString p1) ^ ", " ^ (Plane.pointToString p2) ^ ")"

  (* contained p bb evaluates to true if and only if the point p is in b *)
  fun contained (p : Plane.point, (lowleft, upright) : bbox) : bool =
      let
        val (x, y) = Plane.cartcoord p
        val (xleft, ylow) = Plane.cartcoord lowleft
        val (xright, yup) = Plane.cartcoord upright
      in
        Plane.s_gte (x, xleft) andalso Plane.s_lte (x, xright) andalso
        Plane.s_gte (y, ylow) andalso Plane.s_lte (y, yup)
      end

  (* Returns the four corners of the bounding box in top left, top right,
   * bottom left, bottom right order *)
  fun vertices ((lowleft, upright) : bbox)
      : Plane.point Seq.seq =
      let
        val (xleft, ylow) = Plane.cartcoord lowleft
        val (xright, yup) = Plane.cartcoord upright
      in
        Seq.tabulate (fn 0 => Plane.fromcoord (xleft, yup)
                       | 1 => upright
                       | 2 => lowleft
                       | 3 => Plane.fromcoord (xright, ylow)
                       | _ => raise Fail "out of range")
                     4
      end

  (* addPoint (p, bb) returns the smallest bounding box containing both
   * p and all the points in bb
   *)
  fun addPoint (p : Plane.point, (lowleft, upright) : bbox) : bbox =
      let
        val (x, y) = Plane.cartcoord p
        val (xleft, ylow) = Plane.cartcoord lowleft
        val (xright, yup) = Plane.cartcoord upright
      in
        (Plane.fromcoord (Plane.s_min (x, xleft), Plane.s_min (y, ylow)),
         Plane.fromcoord (Plane.s_max (x, xright), Plane.s_max (y, yup)))
      end

  (* fromPoint p returns the smallest bounding box containing p
   * Namely, it returns the box consisting of the single point p
   *)
  fun fromPoint (p : Plane.point) : bbox = (p, p)

  (* outerBox (bb1, bb2) returns the smallest bounding box containing both
   * all the points in bb1 and all the points in bb2
   *)
  fun outerBox ((lowleft1, upright1) : bbox,
                (lowleft2, upright2) : bbox) : bbox =
      let
        val (xleft1, ylow1) = Plane.cartcoord lowleft1
        val (xright1, yup1) = Plane.cartcoord upright1
        val (xleft2, ylow2) = Plane.cartcoord lowleft2
        val (xright2, yup2) = Plane.cartcoord upright2
      in
        (Plane.fromcoord (Plane.s_min (xleft1, xleft2),
                          Plane.s_min (ylow1, ylow2)),
         Plane.fromcoord (Plane.s_max (xright1, xright2),
                          Plane.s_max (yup1, yup2)))
      end

  (* fromPoints (p1, p2) returns the smallest bounding box containing both
   * p1 and p2
   *)
  fun fromPoints (p1 : Plane.point, p2 : Plane.point) : bbox =
      outerBox (fromPoint p1, fromPoint p2)

  (* Computes the center point of the bounding box *)
  fun center ((lowleft, upright) : bbox) : Plane.point =
      Plane.midpoint lowleft upright

  (* Computes the minimum bounding box of a sequence of points.
     or returns NONE if the sequence is empty
     *)
  fun rectHull (s : Plane.point Seq.seq) : bbox option =
      let fun join (b, NONE) = b
            | join (NONE, b) = b
            | join (SOME b1, SOME b2) = SOME (outerBox (b1,b2))
      in Seq.mapreduce (SOME o fromPoint) NONE join s
      end

end
