structure RealPlane : SPACE =
struct

  (* note that this module does not have an explicit signature ascription *)
  structure Scalar  =
  struct
    datatype hidden = R of real
    type scalar = hidden

    fun plus (R x, R y) = R(x + y)
    fun minus (R x, R y) = R(x - y)
    fun times (R x, R y) = R(x * y)
    fun divide (R x, R y) = R(x / y)

    fun compare (R x, R y) = Real.compare(x,y)

    fun fromRatio (x,y) = R(Real.fromLargeInt x / Real.fromLargeInt y)
    fun toString (R x) =  Real.fmt (StringCvt.SCI (SOME 4)) x
  end

  type scalar = Scalar.scalar

  datatype coord = Coord of scalar * scalar
  datatype vector = Vec of scalar * scalar

  type point = coord
  type vec = vector

  infixr 3 ++

  (* v1 ++ v2 evaluates to the sum of the vectors *)
  fun (Vec (x1,y1)) ++ (Vec (x2,y2)) : vec =
      Vec (Scalar.plus (x1, x2), Scalar.plus (y1, y2))

  infixr 4 **

  (* v ** c evaluates to the scalar product of v with c *)
  fun (Vec (x,y) : vec) ** (c : scalar): vec =
      Vec (Scalar.times (x, c), Scalar.times (y, c))

  infixr 3 -->
  (* X --> Y is the vector from X to Y
   * computed by Y - X componentwise
   *)
  fun (Coord (x1, y1) : point) --> (Coord (x2, y2) : point) : vec =
      Vec (Scalar.minus (x2, x1), Scalar.minus (y2, y1))

  (* The origin point *)
  val origin : point = Coord (Scalar.fromRatio (0,1), Scalar.fromRatio (0,1))

  (* Computes the cartesian coordinates of the given point *)
  fun cartcoord (Coord (x, y) : point) : scalar * scalar = (x,y)

  (* Return a point in 2D space with the given Cartesian coordinates *)
  fun fromcoord ((x, y) : scalar * scalar) = Coord (x, y)

  (* Computes the distance between the argument points *)
  fun distance (Coord (Scalar.R x1, Scalar.R y1))
               (Coord (Scalar.R x2, Scalar.R y2)) =
      let
        val (dx,dy) = (x2 - x1, y2 - y1)
      in
        Scalar. R(Math.sqrt (dx * dx + dy * dy))
      end

  (* Computes the magnitude of the given vector *)
  fun mag (Vec (x, y) : vec) : scalar = distance (Coord (x, y)) origin

  fun vecToString (Vec (x,y) : vec) =
     "(" ^ Scalar.toString x ^ ", " ^ Scalar.toString y ^ ")"

  fun pointToString (Coord (x,y) : point) =
    "(" ^ Scalar.toString x ^ ", " ^ Scalar.toString y ^ ")"

  (* Tests two points for equality *)
  fun pointEqual (Coord (x1, y1) : point, Coord (x2, y2) : point) : bool =
    case (Scalar.compare(x1,x2), Scalar.compare(y1,y2)) of
        (EQUAL,EQUAL) => true
       |_ => false

end
