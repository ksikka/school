signature SPACE = sig

  (* scalars and operations on them *)

  type scalar

  val s_plus : scalar * scalar -> scalar (* s_plus(s1,s2) means s1 + s2 *) 
  val s_minus :  scalar * scalar -> scalar (* s_minus(s1,s2) means s1 - s2 *) 
  val s_times : scalar * scalar -> scalar (* s_times(s1,s2) means s1 * s2 *) 
  val s_divide :  scalar * scalar -> scalar (* s_divide(s1,s2) means s1 / s2 *) 

  val s_compare : scalar * scalar -> order (* compare two scalars *)

  val s_fromRatio : IntInf.int * IntInf.int -> scalar (* s_fromRatio(x,y) is x/y as a scalar *)
  val s_toString : scalar -> string 

  val s_fromInt : IntInf.int -> scalar  (* s_fromInt means n as a scalar *)
  val s_zero : scalar                   (* 0 as a scalar *)
  val s_one : scalar                    (* 1 as a scalar *)
  val s_max : scalar * scalar -> scalar (* s_max(s1,s2) is the max of s1 and s2 *)
  val s_min : scalar * scalar -> scalar (* s_min(s1,s2) is the min of s1 and s2 *)
  val s_lt : scalar * scalar -> bool    (* s_lt(s1,s2) means s1 < s2 *)
  val s_gt : scalar * scalar -> bool    (* s_gt(s1,s2) means s1 > s2 *)
  val s_lte : scalar * scalar -> bool   (* s_lte(s1,s2) means s1 <= s2 *)
  val s_gte : scalar * scalar -> bool   (* s_gte(s1,s2) means s1 >= s2 *)
  val s_eq  : scalar * scalar -> bool   (* s_eq(s1,s2) means s1 = s2 *)
  val s_negate : scalar -> scalar       (* s_negate(s) means -s *)
  val s_invert : scalar -> scalar       (* s_invert(s) means 1/s *)
  val s_pow : scalar * int -> scalar    (* s_pow(s,n) means s^n *)

  (* Students, please don't use this in your implementation.
     For some scalars, it is useful to test for "approximate equality";
     e.g. reals up to some threshold.  But no particular behavior should 
     be expected from this function.  
     *)
  val s_approx_eq  : scalar * scalar -> bool   


  (* points and vectors and operations on them *)

  type point
  type vec

  val vecToString : vec -> string
  val pointToString : point -> string

  val ++ : vec * vec -> vec    (* v1 ++ v2 evaluates to the sum of the vectors *)
  val ** : vec * scalar -> vec (* v ** c evaluates to the scalar product of v with c *)
  val // : vec * scalar -> vec (* v // c evaluates to the scalar product of v with (1/c) *)

  val --> : point * point -> vec (* X --> Y is the vector from X to Y *)

  val zero : vec (* the zero vector *)
  val xunit : vec (* Unit vectors in the x and y direction, respectively *)

  val yunit : vec
  val origin : point (* The origin point *)

  val displace : point * vec -> point (* displace a point by a vector *)

  val unitVec : vec -> vec (* the unit vector in the direction of the given vec *)
                           (* argument should not be the zero vector *)


  val proj : vec * vec -> vec (* The projection of the vector v onto the vector u *)
  val dot : vec * vec -> scalar (* Computes the dot product of two vectors *)
  val mag : vec -> scalar (* Computes the magnitude of the given vector *)

  val pointEqual : point * point -> bool (* equality of points *)
  val midpoint : point -> point -> point (* the midpoint of the argument points *)
  val distance : point -> point -> scalar (* Computes the distance between the argument points *)

  val head : vec -> point (* where the head of the vector would be
                             if the tail were at the origin *)

  val sum : ('a -> vec) -> 'a Seq.seq -> vec (* sum f xs means \Sigma_{x in xs}(f x) *)

  (* Students, please avoid using these functions except to write tests.
     They covert a point to and from cartesian coordinates.
  *)
  val cartcoord : point -> scalar * scalar
  val fromcoord : scalar * scalar -> point

end
