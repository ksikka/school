(* ideally, this would be in SeqUtils, 
   but we wanted to separate the code you write into a different file *)

structure LookAndSay : 
 sig
     val look_and_say : ('a * 'a -> bool) -> 'a Seq.seq -> (int * 'a) Seq.seq
 end =
struct
  (* Purpose: An implementation of the look_and_say function using sequences
   * which uses the list view of a sequence. *)
  fun look_and_say (eq : 'a * 'a -> bool) (s : 'a Seq.seq)
      : (int * 'a) Seq.seq =
      let
        fun lasHelp (s : 'a Seq.seq, x : 'a, acc : int) : 'a Seq.seq * int =
            case Seq.showl s of
                Seq.Nil => (s,acc)
              | Seq.Cons(peek,rest) => (case eq(peek,x) of
                                            true => lasHelp(rest,x,acc+1)
                                          | false => (s,acc))
      in
        case Seq.showl s of
             Seq.Nil => Seq.hidel Seq.Nil
           | Seq.Cons(tip,iceberg) => let val (tail,cnt) = lasHelp(iceberg,tip,1)
                                      in (Seq.hidel
                                      (Seq.Cons((cnt,tip),look_and_say eq tail)))
                                      end
      end
end
