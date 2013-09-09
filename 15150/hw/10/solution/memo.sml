(* Task 5.1 *)
functor MemoedFibo (D : DICT where type Key.t = IntInf.int) : FIBO =
struct
  val hist : IntInf.int D.dict ref = ref D.empty

  fun fib 0 : IntInf.int = 0 : IntInf.int
    | fib 1 = 1
    | fib n =
      let
        val x = loc (n - 1)
      in
        x + loc (n - 2)
      end

  and loc n =
    case D.lookup (!hist) n
     of SOME b => b
      | NONE =>
        let
          val res = fib n
        in
          (* Since hist is a ref to a persistent dictionary and not
             an ephemeral dictionary, if solving the problem for n also solved
             some subproblems, we need to look at the latest version of the
             ref to see those solutions. *)
          hist := D.insert (!hist) (n, res);
          res
        end
end

(* Task 5.3 *)
functor Memoizer (D : DICT) : MEMOIZER =
struct
  structure D = D

  fun memo (f : ((D.Key.t -> 'a) -> (D.Key.t -> 'a))) : (D.Key.t -> 'a) =
      let
        val hist : 'a D.dict ref = ref D.empty
        
        fun wrapper x =
          case D.lookup (!hist) x
           of SOME v => v
            | NONE =>
              let
                val res = f' x
              in
                hist := D.insert (!hist) (x, res);
                res
              end
        
        and f' x = f wrapper x
      in
        f'
      end
end

functor Memoizer2 (D : DICT) : MEMOIZER =
struct
  structure D = D

  fun memo (f : ((D.Key.t -> 'a) -> (D.Key.t -> 'a))) 
      : (D.Key.t -> 'a) =
      let
        val hist : 'a D.dict ref = ref D.empty

        fun wrapper x =
          case D.lookup (!hist) x
           of SOME v => v
            | NONE => let val res = f wrapper x 
                      in
                          hist := D.insert (!hist) (x, res); 
                          res
                      end
      in 
          wrapper 
      end
end

(* Task 5.4 *)
structure AutoMemoedFibo : FIBO =
struct
  structure TreeIntInfMemoizer = Memoizer(TreeDict(IntInfLt))

  fun fib _ (0 : IntInf.int) = (0 : IntInf.int)
    | fib _ 1 = 1
    | fib f n = f (n - 1) + f (n - 2)

  val fib = TreeIntInfMemoizer.memo fib
end

(* Task 5.6 *)
structure AutoMemoedLCS : LCS =
struct
  structure DnaPairMemoizer = Memoizer (TreeDict (DnaPairOrder))

  val lcs =
      let fun lcsRecurse f (s1 : Base.t list, s2 : Base.t list)
          : Base.t list =
          case (s1, s2)
           of ([], _) => []
            | (_, []) => []
            | (x :: xs, y :: ys) =>
                case Base.eq (x, y)
                 of true => x :: f (xs, ys)
                  | false => Base.longerDnaOf (f (s1, ys), f (xs, s2))
      in
          DnaPairMemoizer.memo lcsRecurse
      end
end

(* Task 5.7 *)
structure SpeedExampleLCS =
struct
  open Base

  (* makeCycle count list next prepends a repeating pattern of c bases
   * to list starting with next. *)
  fun makeCycle c l n =
      case c
       of 0 => l
        | _ => case n
          of A => makeCycle (c - 1) (n :: l) T
           | T => makeCycle (c - 1) (n :: l) C
           | C => makeCycle (c - 1) (n :: l) G
           | G => makeCycle (c - 1) (n :: l) A

  (* a rather long cycle *)
  val bigCycle = makeCycle 22 [] A

  (* a rather long cycle with another iteration prepended *)
  val bigCycleNoShift = [G, C, T, A] @ bigCycle

  (* a rather long cycle with *almost* another iteration prepended *)
  val bigCycleShift = [C, T, A] @ bigCycle

  val speedExample : (Base.t list * Base.t list) =
      (bigCycle, bigCycleShift)

  val speedExampleNoShift : (Base.t list * Base.t list) =
      (bigCycle, bigCycleNoShift)
end

functor TestLongestCommonSubsequence (L : LCS) =
struct
  (* lcsString (a, b) returns the string representation of the
   * longest common subsequence of the two base lists a and b. *)
  val lcsString = Base.dnaToString o L.lcs

  val dna1 = Base.dnaFromString "AGAG"
  val dna2 = Base.dnaFromString "GA"
  val dna3 = Base.dnaFromString "GGCGAT"
  val dna4 = Base.dnaFromString "CAGGT"
  val dna5 = Base.dnaFromString "AGATT"
  val dna6 = Base.dnaFromString "AGTCCAGT"
  
  (* Other subsequences may exist, but these are the ones the
     above implementations find. *)
  val "GA" = lcsString (dna1, dna2)
  val "CAT" = lcsString (dna3, dna4)
  val "AGTT" = lcsString (dna5, dna6)

  (* timedExample (a, b) times the computation of lcsString on
   * the base lists (a, b). *)
  fun timedExample (a : Base.t list, b : Base.t list) : Time.time =
      let
          val tStart = Time.now ()
          val _ = lcsString (a, b)
          val tEnd = Time.now ()
      in
          Time.- (tEnd, tStart)
      end
  
  (* longExample times lcsString on two example cases involving
   * three lists of bases: bigCycle, a long list of repetitions of
   * four bases; bigCycleNoShift, bigCycle with another repetition
   * prepended; and bigCycleShift, bigCycleNoShift with the first
   * base popped off. *)
  fun longExample () =
      let
          val noshift = timedExample SpeedExampleLCS.speedExampleNoShift
          val shift = timedExample SpeedExampleLCS.speedExample
      in
          print ("no shift " ^ (Time.toString noshift) ^ " / shift " ^
              (Time.toString shift) ^ "\n")
      end
end

structure SlowSS = TestLongestCommonSubsequence (SlowLCS)
structure MemoSS = TestLongestCommonSubsequence (AutoMemoedLCS)
