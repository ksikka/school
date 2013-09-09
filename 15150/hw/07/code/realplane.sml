structure RealPlane :> SPACE =
struct

    type scalar = real

    val s_plus : scalar * scalar -> scalar = op+
    val s_minus : scalar * scalar -> scalar  = op-
    val s_times : scalar * scalar -> scalar  = op*
    val s_divide : scalar * scalar -> scalar  = op/

    val s_compare = Real.compare

    fun s_fromRatio (x,y) = Real.fromLargeInt x / Real.fromLargeInt y
    val s_toString = Real.fmt (StringCvt.SCI (SOME 4))

    (* Makes a scalar from an integer *)
    fun s_fromInt x = s_fromRatio (x, 1)

    fun s_max (x,y) = case s_compare (x,y)
                     of GREATER => x
                      |_ => y

    fun s_min (x,y) = case s_compare (x,y)
                     of LESS => x
                      |_ => y

    local 
        (* Picked out of a hat. *)
        val epsilon = 1E~2
    in 
     fun s_approx_eq (x, y) =
        (y - x) < epsilon orelse (x - y) < epsilon orelse
        (* This catches the case when x, y are NaNs or infinities. *)
        Real.?= (x, y)
    end

    fun s_lt (x, y) = case s_compare (x,y) of LESS => true | _ => false
    fun s_gt (x, y) = case s_compare (x,y) of GREATER => true | _ => false
    fun s_eq (x, y) = case s_compare (x,y) of EQUAL => true | _ => false
    val s_lte = not o s_gt
    val s_gte = not o s_lt

    val s_zero = s_fromInt 0
    val s_one = s_fromInt 1

    val s_negate : scalar -> scalar = ~
    fun s_invert x = s_divide(s_one , x)

    (* TODO: Make this tail-recursive. *)
    fun s_pow (b, 0) = s_one
      | s_pow (b, 1) = b
      | s_pow (b, n) =
        if Int.< (n, 0) then s_invert (s_pow (b, Int.~ n)) else
        let val subpow = s_pow (b, n div 2)
        in if n mod 2 = 0 then s_times (subpow, subpow) else s_times (s_times (subpow, subpow) , b)
        end


    type point = scalar * scalar
    type vec = scalar * scalar

    infixr 3 ++

    (* v1 ++ v2 evaluates to the sum of the vectors *)
    fun (x1,y1) ++ (x2,y2) : vec = (s_plus (x1, x2), s_plus (y1, y2))

    infixr 4 **
    infixr 4 //

    (* v ** c evaluates to the scalar product of v with c *)
    fun ((x,y) : vec) ** (c : scalar): vec =
        (s_times (x, c), s_times (y, c))

    (* v // c evaluates to the scalar product of v with (1/c) *)
    fun (v : vec) // (c : scalar) : vec = v ** s_invert c

    infixr 3 -->
    (* X --> Y is the vector from X to Y
     * computed by Y - X componentwise
     *)
    fun ((x1, y1) : point) --> ((x2, y2) : point) : vec =
        (s_minus (x2, x1), s_minus (y2, y1))

    val zero : vec = (s_zero, s_zero)
    (* Unit vectors in the x and y direction, respectively *)
    val xunit : vec = (s_one, s_zero)
    val yunit : vec = (s_zero, s_one)

    (* The origin point *)
    val origin : point = (s_zero, s_zero)

    (* Computes the distance between the argument points *)
    fun distance (x1,y1) (x2,y2) =
        let val (dx,dy) = (x2 - x1, y2 - y1)
        in Math.sqrt (dx * dx + dy * dy)
        end

    (* Computes the magnitude of the given vector *)
    fun mag (v : vec) : scalar = distance v origin

    (* distance p v computes the point that results in displacing p by v *)
    (* assumes the vector is in the vector space of the point *)
    fun displace ((x,y) : point, (v1, v2) : vec) : point =
        (s_plus (x, v1), s_plus (y, v2))

    (* Computes the dot product of two vectors *)
    fun dot ((x1, y1) : vec, (x2, y2) : vec) : scalar =
        s_plus (s_times (x1, x2), s_times (y1, y2))

    (* Computes the unit vector in the direction of the given vector *)
    (* Invariant: the argument should not be the zero vector *)
    fun unitVec (v : vec) : vec = v ** s_invert (mag v)

    (* The projection of the vector v onto the vector u *)
    fun proj (u : vec, v : vec) : vec =
       unitVec u ** (s_divide (dot (u,v), mag v))

    fun vecToString ((x,y) : vec) =
       "(" ^ s_toString x ^ ", " ^ s_toString y ^ ")"

    fun pointToString ((x,y) : point) =
      "(" ^ s_toString x ^ ", " ^ s_toString y ^ ")"

    (* Tests two points for equality *)
    fun pointEqual ((x1, y1) : point, (x2, y2) : point) : bool =
      case (s_compare(x1,x2), s_compare(y1,y2)) of
          (EQUAL,EQUAL) => true
         |_ => false

    (* Computes the midpoint of the argument points *)
    fun midpoint ((x1, y1) : point) ((x2, y2) : point) : point =
      (s_divide (s_plus (x1, x2), s_fromInt 2),
       s_divide (s_plus (y1, y2), s_fromInt 2))


    (* Computes the cartesian coordinates of the given point *)
    fun cartcoord ((x, y) : point) : scalar * scalar = (x,y)

    (* Return a point in 2D space with the given Cartesian coordinates *)
    fun fromcoord ((x, y) : scalar * scalar) = (x, y)

    (* Compute the point corresponding to the dispacement by the given vector
     * from the origin
     *)
    fun head (v : vec) : point = displace (origin, v)

    (* Computes the sum of the vectors in the sequence that results from
     * mapping the argument function over the argument sequence
     *)
    fun sum (f : 'a -> vec) : 'a Seq.seq -> vec =
      Seq.mapreduce f zero op++

end
