structure Random210 : RANDOM210 =
struct
   structure Seq = ArraySequence

   type rand = Word.word

   fun next r = Word.*(0wx50356BCB,Word.+(r,0w1))

   fun fromInt i = next(Word.fromInt i)

   fun split r = (next(r),next(Word.+(r,0wx3A9DB073)))

   fun hashString r s =
    let
        fun subs i = Word.fromInt (Char.ord (String.sub(s,i)))
        val c = 0w65599
        fun hash'(i,h) = 
        if (i < 0) then h
        else hash'(i-1, (subs i) + h * c)
    in Word.toIntX (hash'((String.size s)-1, r)) end

   fun hashInt r i = Word.toIntX(next(Word.+(Word.fromInt i, r)))

   fun randomReal r v = 
      let 
        val SOME(mint) = Int.maxInt;
      in 
        Real.fromInt(Int.abs(hashInt r v))/Real.fromInt(mint)
      end

   local 
       structure R = Random
       open Seq 
   in
       (* note that this is sequential to ensure thread safety. it's fast *)
       fun flip (seed : rand) (length : int) : int seq = 
       let
           (*(* this may be (it is) badly inefficient to call repeatedly *) 
           val yield_stateless = 
        fn (i) => let val r = R.rand (seed, i) 
              in R.randRange(0,1) r
              end*)
           val r = R.rand (Word.toIntX seed, Word.toIntX(0wx2c0ffee))
           val yield = fn () => R.randRange (0,1) r 
       in
           let val yield_wrapper = fn (_,_) => yield ()
           val (s, _) = iterh yield_wrapper (yield ()) 
                (tabulate (fn _ => ()) length)
           in s end
       end
   end
end
