structure MutableList =
struct

  datatype 'a cell = Nil
                   | Cons of 'a * 'a llist
  withtype 'a llist = ('a cell) ref

  (* Create an 'a list from an 'a llist *)
  fun tolist (l1 : 'a llist) : 'a list =
      case l1 of
        ref Nil => []
      | ref (Cons(x,xs)) => x :: tolist xs

  val example1 : int llist = ref Nil
  val example2 : int llist = ref (Cons (1, example1))
  val [1] = tolist example2
  val () = example1 := (Cons (2, ref Nil))
  val [1,2] = tolist example2

  fun map (f : 'a -> 'a) (l : 'a llist) : unit =
      case l of
        ref Nil => ()
      | ref (Cons (x,xs)) => (map f xs; l := Cons(f x,xs))

  local
      val test1 = ref (Cons (1, ref (Cons (2, ref (Cons (3, ref Nil))))))
      val () = map (fn x => x + 1) test1
  in
      val [2,3,4] = tolist test1
  end

  (* Mutates l to include each element a iff. p a *)
  fun filter (p : 'a -> bool) (l : 'a llist) : unit =
      case l of
        ref Nil => ()
      | ref (Cons(x,xs)) =>
        let val () = filter p xs
        in
          case p x of
            true => ()
          | false => l := !xs
        end

  local
      val test1 = ref (Cons (1, ref (Cons (2, ref (Cons (3, ref Nil))))))
      val () = filter (fn x => (x mod 2) = 1) test1
  in
      val [1,3] = tolist test1
  end

  (* modify l1 by putting l2 at the end of l1, leaving l2 unchanged.
     should run in constant space: no new ref's or Nil/Cons-es
     *)
  fun append (l1 : 'a llist, l2 : 'a llist) : unit =
      case l1 of
        ref Nil => l1 := !l2
      | ref (Cons(x,xs)) => append (xs, l2)

  local
      val test1 = ref (Cons (1, ref (Cons (2, ref (Cons (3, ref Nil))))))
      val test2end = ref Nil
      val test2 = ref (Cons (4, ref (Cons (5, ref (Cons (6, test2end))))))
      val () = append(test1,test2)
  in
      val [1,2,3,4,5,6] = tolist test1
      val [4,5,6] = tolist test2

      val () = test2end := Cons (7, ref Nil)
      val [4,5,6,7] = tolist test2
      val [1,2,3,4,5,6,7] = tolist test1
  end

  (* a different solution with slighty different semantics:
     updates to l2 itself will then affect l1.
     assumes l1 is not empty.
     *)
  fun append' (l1 : 'a llist, l2 : 'a llist) : unit =
      case l1 of
        ref Nil => raise Fail "empty"
      | ref (Cons(x,ref Nil)) => l1 := Cons(x,l2)
      | ref (Cons(x,xs)) => append' (xs, l2)

  local
      val test1 = ref (Cons (1, ref (Cons (2, ref (Cons (3, ref Nil))))))
      val test2 = ref (Cons (4, ref (Cons (5, ref (Cons (6, ref Nil))))))
      val () = append(test1,test2)
      val () = test2 := Nil

      val test1a = ref (Cons (1, ref (Cons (2, ref (Cons (3, ref Nil))))))
      val test2a = ref (Cons (4, ref (Cons (5, ref (Cons (6, ref Nil))))))
      val () = append'(test1a,test2a)
      val () = test2a := Nil
  in
      val [1,2,3,4,5,6] = tolist test1
      val [1,2,3] = tolist test1a
  end

  local
      val testend = ref Nil
      val testmid = ref (Cons (3, ref (Cons (2, ref (Cons (9, testend))))))
      val () = testend := !testmid
  in
      val testcyclic = ref (Cons (4, testmid))
  end

  fun printelts (l : int llist) : unit =
      case l of
        ref Nil => ()
      | ref (Cons(x,xs)) => (print (Int.toString x); printelts xs)

  (* val loops = tolist testcyclic *)
  (* val () = printelts testcyclic *)

  (* test whether two references are equal,
     in the sense that they are literally the same box *)
  fun samebox (l : 'a llist, l' : 'a llist) = l = l'

  fun cyclic(l : 'a llist) : bool =
      case l of
        ref Nil => false
      | ref (Cons(_, l_tail)) =>
        let
          fun loop (t : 'a llist) (h : 'a llist) : bool =
              (samebox(h,t)) orelse
              (case h of
                 ref Nil => false
               | ref (Cons (_ , ref Nil)) => false
               | ref (Cons (_, ref (Cons (_ , h')))) =>
                 case t of
                   ref Nil => raise Fail "tortoise should be behind hare"
                 | ref (Cons (_,t')) => loop t' h')
        in
          loop l l_tail
        end
end
