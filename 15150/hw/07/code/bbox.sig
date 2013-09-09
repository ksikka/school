signature BBOX = sig

  type bbox
  val toString : bbox -> string

  (* contained p bb evaluates to true if and only if the point p is in b *)
  val contained : Plane.point * bbox -> bool

  (* Returns the four corners of the bounding box in top left, top right,
   * bottom left, bottom right order *)
  val vertices : bbox -> Plane.point Seq.seq

  (* addPoint (p, bb) returns the smallest bounding box containing both
   * p and all the points in bb
   *)
  val addPoint : Plane.point * bbox -> bbox

  (* fromPoint p returns the smallest bounding box containing p
   * Namely, it returns the box consisting of the single point p
   *)
  val fromPoint : Plane.point -> bbox

  (* outerBox (bb1, bb2) returns the smallest bounding box containing both
   * all the points in bb1 and all the points in bb2
   *)
  val outerBox : bbox * bbox -> bbox

  (* fromPoints (p1, p2) returns the smallest bounding box containing both
   * p1 and p2
   *)
  val fromPoints : Plane.point * Plane.point -> bbox

  (* Computes the center point of the bounding box *)
  val center : bbox -> Plane.point

  (* Computes the minimum bounding box of a sequence of points,
     or returns NONE if the sequence is empty.
     *)
  val rectHull : Plane.point Seq.seq -> bbox option

end
