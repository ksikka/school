(********** TASK 2.1 **********)
signature PLANE_ARGS = sig
  structure Scalar : SCALAR
  val distance : (Scalar.scalar * Scalar.scalar) 
              -> (Scalar.scalar * Scalar.scalar) 
              -> Scalar.scalar
end

(********** TASK 2.2 **********)
functor MakePlane(P : PLANE_ARGS) : SPACE = struct

  structure Scalar = P.Scalar

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
  fun distance (Coord x) (Coord y) = P.distance x y

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


(********** TASK 2.3 **********)
structure RealPlaneArg : PLANE_ARGS = struct
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

  (* Computes the distance between the argument points *)
  fun distance (Scalar.R x1, Scalar.R y1)
               (Scalar.R x2, Scalar.R y2) =
      let
        val (dx,dy) = (x2 - x1, y2 - y1)
      in
        Scalar.R(Math.sqrt (dx * dx + dy * dy))
      end

end

structure RatPlaneArg : PLANE_ARGS = struct
  structure Scalar  =
  struct

    open IntInf

    datatype rat = Frac of int * int
    type scalar = rat

    fun gcd (m, 0) = m
      | gcd (0, n) = n
      | gcd (m, n) = gcd (if m > n then (m mod n, n) else (m, n mod m))

    fun lcm (m : int, n : int) : int =
        let val g = gcd (m, n)
        in m * n div g end

    fun negate (Frac (n, d) : scalar) : scalar = Frac (~n, d)

    fun fromRatio (n : int, d : int) : scalar =
        let
          val g = case (IntInf.compare (n, 0), IntInf.compare (d, 0)) of
                      (_, EQUAL) => raise Fail "denominator can't be zero"
                    | (EQUAL, _) => d
                    | (LESS, GREATER) => gcd (~n, d)
                    | (GREATER, LESS) => ~(gcd (n, ~d))
                    | (LESS, LESS) => ~(gcd (~n, ~d))
                    | (GREATER, GREATER) => gcd (n, d)
        in
          Frac (n div g, d div g)
        end

    fun inverse (Frac (n, d) : scalar) : scalar =
        case IntInf.compare (n, 0) of
            LESS => Frac (~d, ~n)
          | GREATER => Frac (d, n)
          | EQUAL => raise Div

    fun plus (Frac (n1, d1) : scalar, Frac (n2, d2) : scalar) : scalar =
        let
          val cdenom = lcm (d1, d2)
        in
          Frac (n1 * cdenom div d1 + n2 * cdenom div d2, cdenom)
        end

    fun minus (r1 : scalar, r2 : scalar) : scalar = plus (r1, negate r2)

    fun times (Frac (n1, d1) : scalar, Frac (n2, d2) : scalar) : scalar =
        fromRatio (n1 * n2, d1 * d2)

    fun divide (r1 : scalar, r2 : scalar) : scalar = times (r1, inverse r2)

    fun compare (Frac (n1, d1) : scalar, Frac (n2, d2) : scalar) : order =
        let
          val cdenom = lcm (d1, d2)
        in
          IntInf.compare (n1 * cdenom div d1, n2 * cdenom div d2)
        end

    fun toString (Frac (n, 1)) = IntInf.toString n
      | toString (Frac (n, d)) = IntInf.toString n ^ "/" ^ IntInf.toString d
  end

  (* Computes the distance between the argument points *)
  fun distance (x1,y1) (x2,y2) =
      let
        fun abs x =
            case Scalar.compare (x, Scalar.fromRatio(0,1)) of
              LESS => Scalar.negate x
            | _ => x

        val dx = Scalar.minus (x2,x1)
        val dy = Scalar.minus (y2,y1)
      in
        Scalar.plus (abs dx,  abs dy)
      end

end

(********** TASK 2.4 **********)
structure RealPlane = MakePlane(RealPlaneArg)
structure RatPlane = MakePlane(RatPlaneArg)
