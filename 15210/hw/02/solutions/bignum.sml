functor BigNum (S : SEQUENCE) : BIGNUM =
struct
  structure Seq = S
  open Seq

  exception Negative

  datatype bit = ZERO | ONE
  type bignum = bit seq

  infix 6 ++ --

  fun nth' s i = (nth s i) handle Range => ZERO

  (* Task 2.1 *)
  local
    datatype carry = GEN | PROP | STOP

    (* Initial carry bits *)
    fun init (ONE, ONE) = GEN
      | init (ZERO, ZERO) = STOP
      | init _ = PROP

    (* Scan binary operator to propogate carries *)
    fun propogate (x, PROP) = x
      | propogate (_, y) = y

    (* Conversions from carry to bit *)
    val G1 = fn GEN => ONE | _ => ZERO
    val P1 = fn PROP => ONE | _ => ZERO

    infix 6 :+: (* one-bit addition *)
    fun x :+: y = (P1 o init) (x, y)
  in
    (* Computes x + y with bignum representation *)
    fun x ++ y =
        let
          (* Normalize the lengths *)
          val N = Int.max (length x, length y)
          val (x, y) = (tabulate (nth' x) N, tabulate (nth' y) N)
          
          (* Generate and propogate carry bits with scan *)
          val carries = map2 init x y
          val (carries', last) = scan propogate STOP carries

          (* Do addition with final carry state *)
          fun result i =
              let fun ith s = nth s i
              in (ith x) :+: (ith y) :+: (G1 o ith) carries'
              end handle Range => ONE

          (* Add a bit if the last one carried *)
          val N' = N + (fn GEN => 1 | _ => 0) last
        in 
          tabulate result N'
        end
  end

  (* task 2.2 *)
  local
    val b_ONE = %[ONE]
    val flip = fn ONE => ZERO | ZERO => ONE
    (* removes trailing ZEROs from s *)
    fun trim s =
        let fun mark i = if nth s i = ONE then i else 0
          val last_ONE = reduce Int.max 0 (tabulate mark (length s - 1))
        in take (s, last_ONE + 1) 
        end
  in
    (* subtract y from x, assuming both are positive and x >= y *)
    fun x -- y =
        let
          val n = Int.max (length x, length y) + 1
          (* negates y by flipping all bits and adding ONE *)
          val negy = tabulate (flip o (nth' y)) n
          val result = x ++ negy ++ b_ONE
        in trim result
        end
  end

  (* Exporting these infix operators *)
  fun add (x,y) = x ++ y
  fun sub (x,y) = x -- y


  (* IntInf-related helpers *)

  (* Raise 2^z *)
  fun pow2 (z : Int.int) : IntInf.int = IntInf.<<(1, Word.fromInt z)

  (* Converts an arbitrarily long positive integer to a bit sequence *)
  fun fromIntInf (x : IntInf.int) : bignum =
      let
        (* Use math to calculate the ith bit of x *)
        fun ith i =
            case IntInf.andb (IntInf.div (x, pow2 (i)), 1)
              of 1 => ONE
               | _ => ZERO
      in
        case IntInf.compare (x, 0)
          of LESS => raise Negative
           | EQUAL => empty ()
           | GREATER => tabulate ith (IntInf.log2(x) + 1)
      end

  (* Converts a bit sequence to an arbitrarily long number *)
  fun toIntInf (s : bignum) : IntInf.int =
      let
        (* Get the ith bit of s and convert it into an integer *)
        fun ith i = IntInf.*(pow2 i, (fn ZERO => 0 | ONE => 1) (nth s i))
      in
        reduce IntInf.+ 0 (tabulate ith (length s))
      end
end

structure BN = BigNum(ArraySequence)

