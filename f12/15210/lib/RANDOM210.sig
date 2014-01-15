signature RANDOM210 = 
sig
   structure Seq : SEQUENCE = ArraySequence

   type rand
   val fromInt : int -> rand
   val split : rand -> (rand * rand)
   val next: rand -> rand
   val hashInt : rand -> int -> int
   val randomReal : rand -> int -> real
   val hashString : rand -> string -> int
   val flip : rand -> int -> int Seq.seq
end
