signature GEOMETRY2D =
sig
  type point

  (* new (x,y) returns a point with cooridate (x,y) *)
  val new: int*int -> point

  (* xOf p returns the x coordinate of p *)
  val xOf: point -> int
  (* yOf p returns the y coordinate of p *)
  val yOf: point -> int

  (* dist (p, q) returns theEuclidean distance between p and q *)
  val dist: point * point -> real

  (* dist2 (p, q) returns the squared Euclidean distance between p and q *)
  val dist2: point * point -> int

  (* toString p produces a string representation of p *)
  val toString: point -> string

  (* cmpX (p,q) compares the points p and q on their on x values,
   * breaking ties using their y values.
   *)
  val cmpX: point*point -> order

  (* cmpX (p,q) compares the points p and q on their on y values,
   * breaking ties using their x values.
   *)
  val cmpY: point*point -> order
end

signature CP_PACKAGE =
sig
  structure Seq : SEQUENCE
  structure Point : GEOMETRY2D
end
structure Utils =
struct

 fun optToString toS opt =
   case opt
    of NONE => "NONE"
     | SOME e => "SOME(" ^ (toS e) ^ ")"

 val intOptToString = optToString Int.toString

 fun intPairToString (a, b)=
     "(" ^ Int.toString a ^ "," ^ Int.toString b ^ ")"

 fun join (s1, s2) = s1 ^ " " ^ s2
end

structure Pair =
struct
 fun lexiCmp cmp ((a0, a1), (b0, b1)) =
     case cmp (a0, b0)
      of EQUAL => Int.compare (a1, b1)
       | r => r

 fun swap (a0, a1) = (a1, a0)
 fun map f (a, b) = (f a, f b)
end


structure Point2D : GEOMETRY2D =
struct
  type point = int * int

  exception InvalidDimension

  val new: int*int -> point = fn (x,y) => (x,y)

  (* xOf p returns the x coordinate of p *)
  val xOf: point -> int = fn (x, _) => x
  (* yOf p returns the y coordinate of p *)
  val yOf: point -> int = fn (_, y) => y

  local
      fun sqr v = v * v
  in fun dist2 ((x,y), (x', y')) = sqr(x - x')  + sqr(y - y')
  end

  fun toString p = Utils.intPairToString p

  fun dist (p, q) = Math.sqrt (Real.fromInt (dist2(p, q)))

  val cmpX = Pair.lexiCmp Int.compare
  val cmpY = cmpX o (Pair.map Pair.swap)
end

