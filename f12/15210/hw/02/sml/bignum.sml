functor BigNum (S : SEQUENCE) : BIGNUM =
struct

  structure Seq = S

  exception ImpossibleOccurred
  exception Negative

  datatype bit = ZERO | ONE
  type bignum = bit Seq.seq

  datatype carry = GEN | PROP | STOP

  infix 6 ++ -- **

  (* notBit : bit -> bit 
   *   not b returns the negation of bit b. *)
  fun notBit bit = case bit of ONE => ZERO | ZERO => ONE

  (* xor : bit * bit -> bit
   *   xor (b1,b2) returns the XOR of b1 and b2 *)
  fun xor (bit1,bit2) = case (bit1,bit2) of
                          (ONE, ONE)  => ZERO
                        | (ZERO,ZERO) => ZERO
                        |  _          => ONE
  
  (* extendZeros : bit seq * int
   *   extendZeros (S,n) returns S with n zeroes appended to it. 
   *   n must be nonnegative, and it can be zero.  *)
  fun extendZeros (S,n) =
    case n of 0 => S | _ =>
      let
        val zeroes = Seq.tabulate (fn _ => ZERO) n
      in Seq.append (S,zeroes) end

  (* scanI : ('a * 'a -> 'a) -> 'a -> 'a seq -> 'a seq
   *   Inclusive scan. Output sequence will be same length as input sequence *)
  fun scanI f b s =
    let
      val (s', v) = Seq.scan f b s
      val s' = Seq.subseq s' (1,(Seq.length s') -1)
    in Seq.append (s', Seq.singleton v)
    end

  fun bitString S = Seq.toString (fn ZERO => "0" | ONE => "1") S

  (* bitPairToCarryType : bit * bit -> carry
   *   Given two bits, this function returns what the carry will be
   *   if the bits are added. *)
  fun bitPairToCarryType (b1,b2) = case (b1,b2) of
                                      (ZERO,ZERO)  => STOP
                                    | (ONE, ONE )  => GEN
                                    | ( _ , _   )  => PROP
  (* normalizeLengths : bit Seq * bit Seq -> bit Seq * bit Seq 
   *   When called with (s1,s2), it will return (s1',s2') such
   *   that |s1'| = |s2'| = max(s1,s2) + 1 . 
   *   The extra entries in the sequences will be filled with ZEROs *)
  fun normalizeLengths (s1,s2) =
    let
      val (xLength, yLength) = (Seq.length s1, Seq.length s2)
      val lengthOfEach = (Int.max (xLength, yLength)) + 1
      val s1 = extendZeros (s1,lengthOfEach - xLength)
      val s2 = extendZeros (s2,lengthOfEach - yLength)
    in (s1,s2) end

  (* add : bit seq * bit seq -> bit seq
   *   add (n1,n2) is the result of adding two binary bit sequences.
   *   Work: O(|n1| + |n2|)
   *   Span: O(log(|n1| + |n2|))
   *   Output sequence will have length of at most 1 + max(|n1| + |n2|) *)
  fun x ++ y =
    let
      (* Cap sequences with a zero to allow for increase in number of bits *)

      val (x,y) = normalizeLengths(x,y)

      (* Each bit pair represents GEN | PROP | STOP *)
      val ripples = Seq.map2 bitPairToCarryType x y

      (* Copy-scan to determine when carrying occurs *)
      val done_rippling = scanI (fn (r1,r2) =>
                            case r2 of
                              PROP => r1
                            | _    => r2) STOP ripples
      (* Shift over by one so GEN represents carry bit of 1, STOP = 0 *)
      val done_rippling = Seq.append ((Seq.singleton STOP),done_rippling)
      val done_rippling = Seq.map (fn GEN => ONE
                                    | STOP => ZERO
                                    | _ => raise ImpossibleOccurred) done_rippling

      (* Results of XORing bits in the bit pairs *)
      val ripples = Seq.map (fn GEN => ZERO | PROP => ONE | STOP => ZERO) ripples
      
      (* XOR the carry bit with the bit-pair XOR result *)
      val done_rippling2 = Seq.map2 xor ripples done_rippling

      (* Trim off the extra zero if it exists *)
      val length = Seq.length done_rippling2
      val last_element =  Seq.nth done_rippling2 (length - 1)
      val done_rippling2 = case last_element of
                    ZERO => Seq.subseq done_rippling2 (0,length - 1)
                  | ONE  => done_rippling2
    in
      done_rippling2
    end


  (* compare : bit Seq * bit Seq -> order
   *   Returns GREATER iff x > y
   *   Returns LESS iff x < y
   *   Returns EQUAL iff x = y
   *   Requires that the inputs are valid! *)
  fun compare (x,y) =
    let
      val xLength = Seq.length x
      val yLength = Seq.length y
    in case Int.compare (xLength,yLength) of
           GREATER => GREATER
         | LESS    => LESS
         | EQUAL   => 
              let
                val zipped = Seq.map2 (fn (a,b) => (a,b)) x y
                val differing_bits = Seq.filter (fn (ONE,ONE) => false
                                                  | (ZERO,ZERO) => false
                                                  | (_,_) => true) zipped
              in
                if (Seq.length differing_bits) = 0 then EQUAL else
                  case Seq.nth differing_bits ((Seq.length differing_bits) - 1) of
                  (ONE,ZERO) => GREATER
                | (ZERO,ONE) => LESS | (_,_) => raise ImpossibleOccurred
              end
    end

  (* flipBits : bit Seq -> bit Seq 
   *   if the input is x, then this
   *   function returns ~x in C notation *)
  fun flipBits S = Seq.map notBit S
                
  fun x -- y =
    case compare(x,y) of
        LESS => raise Negative
      | EQUAL => Seq.empty ()
      | GREATER => let
                     val (x,y) = normalizeLengths (x,y)
                     val beforeTrunc = x ++ (flipBits y) ++ (Seq.singleton ONE)
                   in Seq.subseq beforeTrunc (0,(Seq.length beforeTrunc) - 1)
                   end

  (* Exporting these infix operators *)
  fun add (x,y) = x ++ y
  fun sub (x,y) = x -- y

(* IntInf-related helpers *)
  local
    open S
  in
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

end

structure BN = BigNum(ArraySequence)

