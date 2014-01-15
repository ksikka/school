signature SCALAR = sig

  type scalar

  val plus : scalar * scalar -> scalar (* plus(s1,s2) means s1 + s2 *)
  val minus :  scalar * scalar -> scalar (* minus(s1,s2) means s1 - s2 *)
  val times : scalar * scalar -> scalar (* times(s1,s2) means s1 * s2 *)
  val divide :  scalar * scalar -> scalar (* divide(s1,s2) means s1 / s2 *)

  val compare : scalar * scalar -> order (* compare two scalars *)

  val fromRatio : IntInf.int * IntInf.int -> scalar (* fromRatio(x,y) is x/y as a scalar *)
  val toString : scalar -> string

end
