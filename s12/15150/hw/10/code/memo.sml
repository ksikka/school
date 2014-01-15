(* Task 5.1 *)
(* Purpose: a functor which takes a dictionary and returns a structure
* ascribing to Fibo. The fib function inside is memoized. *)
functor MemoedFibo (D : DICT where type Key.t = IntInf.int) : FIBO =
struct
  (* Create a persistent dictionary reference *)
  val dict : IntInf.int D.dict ref = ref D.empty 

  (* Purpose: a memoized fib function, mutually recursive *)
  fun fib (n : IntInf.int) : IntInf.int =
      case D.lookup (!dict) n of
          SOME v => v
        | NONE   => let
                      val result = calculate n
                      val () = dict := D.insert (!dict) (n,result)
                    in
                      result
                    end

  and calculate (n : IntInf.int) : IntInf.int =
      case n of 
          0 => 0 
        | 1 => 1 
        | _ => fib(n-2) + fib(n-1)
end

structure FibMemoTest = MemoedFibo(TreeDict(IntInfLt))
(* Speed Test: This happens in a few seconds 
val () = print (IntInf.toString (MemoTest.fib 10000))*)
(* Correctness Test (passed in the repl)*)
(*val true = (FibMemoTest.fib 20) = (Fibo.fib 20);
*val true = (FibMemoTest.fib 0) = (Fibo.fib 0);
*val true = (FibMemoTest.fib 0) = (Fibo.fib 0);*)

(* Task 5.3 *)
(* a functor which takes a dictionary type and produces a structure
 * ... a structure which has a function memo and a dictionary hist *)
functor Memoizer (D : DICT) : MEMOIZER =
struct
  structure D = D
  (* a function which takes in a transformation on a function and returns
   * a function *)
  fun memo (g :(D.Key.t -> 'a)-> (D.Key.t -> 'a)) : D.Key.t -> 'a =
      let
        val hist : 'a D.dict ref = ref D.empty
        fun f_memoed (x : D.Key.t) : 'a =
            case D.lookup (!hist) x
             of SOME(b) => b
              | NONE =>
                let
                  val res : 'a = g f_memoed x
                  val () = (hist := D.insert (!hist) (x,res))
                in
                  res
                end
      in
        f_memoed
      end

end

(* Task 5.4 *)
(* Purpose: A structure which contains a memoized fib function
 * The fib function in here was memoized by the function in the 
 * above functor *)
structure AutoMemoedFibo : FIBO =
struct
  structure FibMemo = Memoizer(TreeDict(IntInfLt))

  (* The memoized fib function which calls upon 
   * the automemoizer to define itself *)
  fun fib x = 
    let
      fun fibmemo (f : IntInf.int -> IntInf.int) : 
                  IntInf.int -> IntInf.int = 
        fn n => case n of
            0 => 0
          | 1 => 1
          | _ => f (n-2) + (f (n-1))
    in FibMemo.memo fibmemo x
    end
end
(* TESTS *)
val true = (FibMemoTest.fib 20) = (AutoMemoedFibo.fib 20)
val true = (FibMemoTest.fib 1000) = (AutoMemoedFibo.fib 1000)

(* Task 5.6 *)
structure AutoMemoedLCS : LCS =
struct
  structure Memo = Memoizer(TreeDict(DnaPairOrder))

  fun lcs (s1 : Base.t list, s2 : Base.t list)
      : Base.t list =
    let
      fun lcsmemo f = fn (s1,s2) =>
        case (s1, s2)
          of ([], _) => []
           | (_, []) => []
           | (x :: xs, y :: ys) =>
             case Base.eq (x, y)
               of true => x :: lcs (xs, ys)
                | false => Base.longerDnaOf (
                    f (s1, ys),
                    f (xs, s2))
    in Memo.memo lcsmemo (s1,s2)
    end

end

(* Task 5.7 *)
structure SpeedExampleLCS =
struct
  val speedExample : (Base.t list * Base.t list) =
     (Base.dnaFromString "ATCGATCGATCGATCGATCGATCAAT",
      Base.dnaFromString "GATCGATCGATCGATCGATCGATCGATCGATCGATC")
end
val EQUAL = String.compare(
              Base.dnaToString (SlowLCS.lcs       SpeedExampleLCS.speedExample),
              Base.dnaToString (AutoMemoedLCS.lcs SpeedExampleLCS.speedExample))

