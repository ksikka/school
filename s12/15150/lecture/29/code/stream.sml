(* Streams *)
(* Dan Licata and Bob Harper; based on code by Frank Pfenning and Michael Erdmann *)

(* basic stream abstract type,
   which deals with the implementation of memoization
*)
signature STREAM_CORE =
sig

  type 'a stream 
  datatype 'a front = Nil | Cons of 'a * 'a stream
  val expose : 'a stream -> 'a front
  val stream : (unit -> 'a front) -> 'a stream

  exception Blackhole
  val selfreferential : ('a stream -> 'a stream) -> 'a stream
  val fix       : ('a stream -> 'a stream) -> 'a stream
end

structure StreamCore : STREAM_CORE =
struct

  datatype 'a stream = Stream of unit -> 'a front
  and 'a front = Nil | Cons of 'a * 'a stream

  fun expose (Stream d) = d ()

  fun stream d =
      let val memoCell = ref (fn () => raise Fail "invariant violation")  (* temporarily... *)
          val selfmodifying = 
              fn () => let
                           val r = d ()
                           val () = memoCell := (fn () => r)
                       in r end
          val () = (memoCell := selfmodifying)
      in
        Stream (fn () => !memoCell ())
      end

  exception Blackhole
  fun selfreferential f = 
      let 
          val memoCell = ref (Stream (fn () => raise Blackhole))
          val this = Stream (fn () => expose (!memoCell))  (* not the same as !memoCell *)
          val () = memoCell := f this
      in
          this
      end

  fun fix f = f (stream (fn () => expose (fix f)))
end

(* a stream outfitted with a bunch of useful operations *)
signature STREAM =
sig
  include STREAM_CORE

  val memo : 'a Process.process -> 'a stream
  val map    : ('a -> 'b) -> 'a stream -> 'b stream
  val filter : ('a -> bool) -> 'a stream -> 'a stream (* not productive on an infinite stream of elements tgat don't satisfy the predicate *)

  val zip : ('a stream * 'b stream) -> ('a * 'b) stream
  val truncate : int -> 'a stream -> 'a stream

  val tabulate : (int -> 'a) -> 'a stream
  val fromList : 'a list -> 'a stream
  val append : 'a stream -> 'a stream -> 'a stream
  val unfold : ('s -> ('a * 's) option) -> 's -> 'a stream

  val merge : ('a * 'a -> order) -> 'a stream -> 'a stream -> 'a stream   (* coalesce duplicates *)
  val looksay : ('a * 'a -> bool) -> 'a stream -> (int * 'a) stream  (* assumes no infinite runs of equal elements *)

  (* the following operations raise EmptyStream if there are not enough elements;
     they are handy for working with truly infinite streams,
     or for when you know there are enough elements
     *)
  exception EmptyStream
  val hd  : 'a stream -> 'a
  val tl  : 'a stream -> 'a stream
  val nth : 'a stream -> (int -> 'a)
  val take : 'a stream -> int -> 'a list

  val toList : 'a stream -> 'a list (* assumes finite *)
  val length : 'a stream -> int (* assumes finite *)
end

functor StreamUtils (S : STREAM_CORE) : STREAM =
struct
  open S

  fun memo (p : unit -> 'a option) : 'a stream = 
   stream (fn () => case p () of 
                     NONE => Nil
                   | SOME x => Cons (x , memo p))

  fun map f s = 
   stream (fn () => case expose s of
                      Nil => Nil
                    | Cons (x , xs) => Cons (f x , map f xs))

  (* not productive: will loop if you memo for the head of 
     an infinite stream of things that don't satisfy the predicate! *)
  fun filter p s = 
   stream (fn () => case expose s of
                      Nil => Nil
                    | Cons (x,xs) => (case p x of
                                        true => Cons (x, filter p xs)
                                      | false => expose (filter p xs)))

  (* returns a finite stream of length n *)
  fun truncate n s = 
      stream (fn () => case n of 
                0 => Nil
              | _ => case expose s of
                    Nil => Nil
                  | Cons (x,xs) => Cons (x , truncate (n - 1) xs))

  fun zip (a : 'a stream , b : 'b stream) : ('a * 'b) stream = 
      stream (fn () => case (expose a , expose b) of
              (Cons (a , az) , (Cons (b , bz))) => Cons ((a,b), zip(az,bz))
            | _ => Nil)

  fun add1 n = n + 1
  fun tabulate f = stream (fn () => Cons (f 0 , tabulate (f o add1)))

  fun fromList l = stream (fn () => case l of 
                                       [] => Nil
                                     | x :: xs => Cons (x , fromList xs))

  fun append s1 s2 = 
    stream (fn () => case expose s1 of 
                       Nil => expose s2
                     | Cons (x,xs) => Cons (x , append xs s2))


  exception EmptyStream
  fun hd s = case expose s of
      Nil => raise EmptyStream
    | Cons (x,xs) => x
  fun tl s = case expose s of (* eager *)
      Nil => raise EmptyStream
    | Cons (x,xs) => xs
  fun ltl s = stream (fn () => 
                     case expose s of
                         Nil => raise EmptyStream
                       | Cons (x,xs) => expose xs)
  (* 
  fun nth s n = case n of 
      0 => hd s
    | _ => nth (tl s) (n - 1)
  *)
  (* direct impl so we don't have to write hd/tl in lecture *)
  fun nth s n = 
      case expose s of
          Nil => raise EmptyStream
        | Cons(x,xs) => (case n of 
                             0 => x
                           | _ => nth xs (n - 1))
              
  fun take s n = List.tabulate (n , (fn i => nth s i))

  (* assumes s is finite *)
  fun toList s = case expose s of
      Nil => []
    | Cons(x,xs) => x :: toList xs
  fun length s = case expose s of
      Nil => 0
    | Cons(x,xs) => 1 + length xs

  fun unfold (g : 's -> ('a * 's) option) (i : 's) : 'a stream = 
      stream (fn () => case g i of
              NONE => Nil
            | SOME (x , i') => Cons (x , unfold g i'))


  (* coalesce duplicates *)
  fun merge (compare : 'a * 'a -> order) (s1 : 'a stream) (s2 : 'a stream) : 'a stream= 
      stream (fn () => case (expose s1 , expose s2) of
                  (Nil , f) => f
                | (f , Nil) => f
                | (Cons (x , xs), Cons (y , ys)) => 
                      (case compare (x , y) of
                           LESS => Cons (x , merge compare xs s2)
                         | GREATER => Cons (y , merge compare s1 ys)
                         | EQUAL => Cons (x , merge compare xs ys)))


  (* assumes no infinite runs of equal elements 
     
     version that does the recursive call from the helper.  
     *)
  fun looksay (eq : 'a * 'a -> bool) (s : 'a stream) : (int * 'a) stream = 
      let 
          fun ls (count : int , last : 'a) s : (int * 'a) front = 
              case expose s of
                  Nil => Cons ((count , last) , stream (fn () => Nil))
                | Cons (cur , rest) => 
                  (case eq (last,cur) of
                       true => ls (count + 1, last) rest
                    | false => Cons ((count,last), 
                                     stream (fn () => ls (1,cur) rest)))
      in 
          stream (fn () => case expose s of 
                  Nil => Nil
                | Cons (x , xs) => ls (1,x) xs)
      end
 
  (* assumes no infinite runs of equal elements 
     
     version more like the HW3 solution
     *)
  fun looksay (eq : 'a * 'a -> bool) (s : 'a stream) : (int * 'a) stream =
      let 
          fun lasHelp (s : 'a stream, cur : 'a, acc : int)
                      : 'a stream * int =
              case expose s of
                  Nil => (s, acc)
                | Cons(x,xs) => case eq (x, cur) of
                      true => lasHelp (xs, cur, acc + 1)
                    | false => (s, acc)
      in
          stream (fn () => 
                  case expose s of
                      Nil => Nil
                    | Cons(x,xs) => let
                                        val (tail, total) = lasHelp (xs, x, 1)
                                    in
                                        Cons ((total , x), looksay eq tail)
                                    end)
      end

end

structure Stream : STREAM = StreamUtils (StreamCore);


structure Examples = 
struct
  open Stream

  (* buggy (off-by-1) implementation of map *)
  fun map1 f s = 
   case expose s of
       Nil => stream (fn () => Nil)
     | Cons (x , xs) => stream (fn () => Cons (f x , map1 f xs))

  (* for example,
     nth (Examples.map1 String.size (memo Process.stdinLines)) 0 
       incorrectly asks for two inputs
     nth (map String.size (memo Process.stdinLines)) 0 
       correctly asks for one
   *)

  fun intfromstring s = case Int.fromString s of
      NONE => raise Fail "not a string"
    | SOME x => x

  (*
  nth (filter (fn x => Examples.intfromstring x < 0) (memo Process.stdinLines)) 0
    will go on and on if you never type a negative number
  *)

  val odds : int stream = selfreferential (fn os => stream (fn () => Cons (1 , map (fn x => x + 2) os)))
  val nats = selfreferential (fn ns => stream (fn () => (Cons (0 , map (fn x => x + 1) ns))))

  infix divides 
  fun x divides y = y mod x = 0

  fun sieve (s : int stream) : int stream = 
      stream (fn () => case expose s of
              Nil => Nil
            | Cons (x,xs) => Cons (x , sieve (filter (fn y => not (x divides y)) xs)))
                                   (* fun to watch : 
                                   (fn y => let val r = not (x divides y) 
                                                val () = print (Int.toString x ^ " divides " ^ Int.toString y ^ "? " ^ (case r of false => "yes" | true => "no") ^ "\n")
                                               in r end)
                                   *)

  (* val primes : int stream = stream (fn () => Cons (2 , sieve (tl odds))) *)
  val primes : int stream = sieve (tl (tl nats))

  infixr U
  fun x U y = merge Int.compare x y

  val hamming : int stream = selfreferential (fn h => 
    stream (fn () => Cons (1 , (map (fn x => x * 2) h) U
                               (map (fn x => x * 3) h) U
                               (map (fn x => x * 5) h))))

  val [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 30, 32, 36, 40, 45, 48, 50, 54, 60]
      = toList (truncate 26 hamming)

  fun memoSelf p = selfreferential (fn m => stream (fn () => case p () of 
                                           NONE => Nil
                                         | SOME x => Cons (x,m)))

  fun memoFix p = fix (fn m => stream (fn () => case p () of 
                                         NONE => Nil
                                       | SOME x => Cons (x,m)))


  val loops = looksay (op=) (selfreferential (fn os => stream (fn () => Cons (1 , os))))

end

(* open Examples *)

