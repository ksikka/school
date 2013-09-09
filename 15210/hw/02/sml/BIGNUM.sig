signature BIGNUM =
sig

  datatype bit = ZERO | ONE
  structure Seq : SEQUENCE

  (* A bignum x is a bit sequence where x_0 is the least significant
   * bit. We adopt the convention that if x represents the number 0,
   * x is a empty sequence. Furthermore, if x > 0, the right-most bit
   * of x must be ONE (i.e., there cannot be trailing zeros at the end)
   *)
  type bignum = bit Seq.seq

  (* convert to and from Standard ML's IntInf *)
  val fromIntInf : IntInf.int -> bignum
  val toIntInf : bignum -> IntInf.int

  (* add (x,y) computes x + y. *)
  val add : bignum * bignum -> bignum

  (* sub (x,y) computes x - y assuming x >= y. *)
  val sub : bignum * bignum -> bignum

end
