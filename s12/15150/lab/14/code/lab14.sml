structure MutableList =
struct

  datatype 'a cell = Nil
                   | Cons of 'a * 'a llist
  withtype 'a llist = ('a cell) ref

  fun tolist (l1 : 'a llist) : 'a list =
    case l1 of
         ref Nil        => []
       | ref (Cons(x,xs)) => x::tolist(xs)

  val example1 : int llist = ref Nil
  val example2 : int llist = ref (Cons (1, example1))
  val [1] = tolist example2
  val () = example1 := (Cons (2, ref Nil))
  val [1,2] = tolist example2


  fun map (f : 'a -> 'a) (l : 'a llist) : unit =
    case l of
         ref Nil => ()
       | ref (Cons(x,xs)) => let
                               val () = l := Cons((f x),xs)
                             in
                               map f xs 
                             end
                             

  fun filter (p : 'a -> bool) (l : 'a llist) : unit =
    case l of
         ref Nil => ()
       | ref (Cons(x,xs)) => let
                               val () = filter p xs
                             in 
                               case p x of
                                  true => l := !xs
                                | false => l := Cons(x,xs)
                             end

  (* modify l1 by putting l2 at the end of l1, leaving l2 unchanged.
     should run in constant space: no new ref's or Nil/Cons-es
     *)
  fun append (l1 : 'a llist, l2 : 'a llist) : unit =
    case l1 of
        ref Nil          => l1 := !l2 
      | ref (Cons(x,xs)) => append (xs,l2)
                          

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

  fun samebox (l : 'a llist, l' : 'a llist) = l = l'
  fun cyclic(l : 'a llist) : bool =
    case l of
        ref Nil => false
      | ref (Cons(x,xs)) => let
                              fun contained (x : 'a llist, xs : 'a llist) =
                                case xs of
                                     ref Nil => false
                                   | ref (Cons(y,ys)) => (x=xs) orelse (contained (x,ys))
                            in contained(l,xs) orelse (cyclic xs)
                            end

end
