structure RatPlane :> SPACE =
struct
    local open IntInf in

    type scalar = int * int

    fun gcd (m, 0) = m
      | gcd (0, n) = n
      | gcd (m, n) = gcd (if m > n then (m mod n, n) else (m, n mod m))

    fun lcm (m : int, n : int) : int =
        let val g = gcd (m, n)
        in m * n div g end

    fun s_negate ((n, d) : scalar) : scalar = (~n, d)

    fun s_fromRatio (n : int, d : int) : scalar =
        let
          val g = case (IntInf.compare (n, 0), IntInf.compare (d, 0)) of
                      (_, EQUAL) => raise Fail "denominator can't be zero"
                    | (EQUAL, _) => d
                    | (LESS, GREATER) => gcd (~n, d)
                    | (GREATER, LESS) => ~(gcd (n, ~d))
                    | (LESS, LESS) => ~(gcd (~n, ~d))
                    | (GREATER, GREATER) => gcd (n, d)
        in
          (n div g, d div g)
        end

    fun s_inverse ((n, d) : scalar) : scalar =
        case IntInf.compare (n, 0) of
            LESS => (~d, ~n)
          | GREATER => (d, n)
          | EQUAL => raise Div

    fun s_plus ((n1, d1) : scalar, (n2, d2) : scalar) : scalar =
        let
          val cdenom = lcm (d1, d2)
        in
          (n1 * cdenom div d1 + n2 * cdenom div d2, cdenom)
        end

    fun s_times ((n1, d1) : scalar, (n2, d2) : scalar) : scalar =
        s_fromRatio (n1 * n2, d1 * d2)

    fun s_divide (r1 : scalar, r2 : scalar) : scalar = s_times (r1, s_inverse r2)

    fun s_minus (r1 : scalar, r2 : scalar) : scalar = s_plus (r1, s_negate r2)

    fun s_compare ((n1, d1) : scalar, (n2, d2) : scalar) : order =
        let
          val cdenom = lcm (d1, d2)
        in
            IntInf.compare (n1 * cdenom div d1, n2 * cdenom div d2)
        end

    fun s_toString (n, 1) = IntInf.toString n
      | s_toString (n, d) = IntInf.toString n ^ "/" ^ IntInf.toString d

    end


    (* Makes a scalar from an integer *)
    fun s_fromInt x = s_fromRatio (x, 1)

    fun s_max (x,y) = case s_compare (x,y)
                     of GREATER => x
                      |_ => y

    fun s_min (x,y) = case s_compare (x,y)
                     of LESS => x
                      |_ => y

    fun s_lt (x, y) = case s_compare (x,y) of LESS => true | _ => false
    fun s_gt (x, y) = case s_compare (x,y) of GREATER => true | _ => false
    fun s_eq (x, y) = case s_compare (x,y) of EQUAL => true | _ => false
    val s_approx_eq = s_eq
    val s_lte = not o s_gt
    val s_gte = not o s_lt

    val s_zero = s_fromInt 0
    val s_one = s_fromInt 1

    fun s_negate x = s_minus (s_zero, x)
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
        let
          fun s_abs x =
              case s_lt (x, s_zero) of
                true => s_negate x
              | false => x

          val dx = s_minus (x2,x1)
          val dy = s_minus (y2,y1)
        in
          s_plus (s_abs dx,  s_abs dy)
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
