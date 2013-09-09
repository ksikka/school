signature SPACE = sig

  (* scalars and operations on them *)
  structure Scalar : SCALAR
  type scalar = Scalar.scalar

  (* points and vectors and operations on them *)
  type point
  type vec

  val ++ : vec * vec -> vec    (* v1 ++ v2 evaluates to the sum of the vectors *)
  val ** : vec * scalar -> vec (* v ** c evaluates to the scalar product of v with c *)

  val --> : point * point -> vec (* X --> Y is the vector from X to Y *)
  val origin : point
  val cartcoord : point -> scalar * scalar 
  val fromcoord : scalar * scalar -> point

  val distance : point -> point -> scalar (* Computes the distance between the argument points *)
  val mag : vec -> scalar (* Computes the magnitude of the given vector *)

  val vecToString : vec -> string
  val pointToString : point -> string
  val pointEqual : point * point -> bool (* equality of points *)

end
