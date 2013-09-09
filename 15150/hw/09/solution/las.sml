structure LookAndSay : sig
  val look_and_say : ('a * 'a -> bool) -> 'a Seq.seq -> (int * 'a) Seq.seq
end = struct
  fun look_and_say (eq : 'a * 'a -> bool) (s : 'a Seq.seq)
      : (int * 'a) Seq.seq =
      let fun lasHelp (s : 'a Seq.seq, x : 'a, acc : int) =
              case Seq.showl s
               of Seq.Nil => Seq.singleton (acc, x)
                | Seq.Cons (y, ys) =>
                  case eq (x,y)
                   of true => lasHelp (ys, x, acc+1)
                    | false => Seq.cons (acc, x) (lasHelp (ys, y, 1))
      in case Seq.showl s
          of Seq.Nil => Seq.empty ()
           | Seq.Cons (x, xs) => lasHelp (xs, x, 1)
      end
end
