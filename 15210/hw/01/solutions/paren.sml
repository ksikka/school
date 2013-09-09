(* Wrapper for Sequence that also provides paren type and a convenient
 * function for generating test cases.*)
structure ArrayParenPackage : PAREN_PACKAGE =
struct
  structure Seq = ArraySequence
  exception NYI
  datatype paren = OPAREN
                 | CPAREN
end

(*Defines a handful of useful option operations.*)
structure OC =
struct
  fun optbinop_or _ (NONE, SOME x) = SOME x
    | optbinop_or _ (SOME x, NONE) = SOME x
    | optbinop_or _ (NONE, NONE)   = NONE
    | optbinop_or oper (SOME x, SOME y) = SOME(oper (x,y))

  fun optbinop_and oper (SOME x, SOME y) = SOME(oper (x,y))
    | optbinop_and _ _ = NONE

  val omin = optbinop_or Int.min
  val omax = optbinop_or Int.max

  val ominus = optbinop_and (op -)
  val oplus = optbinop_and (op +)
end

(* The Brute Force Solution *)
functor ParenBF(P : PAREN_PACKAGE) : PAREN =
struct
  structure P = P
  open P
  open Seq

  (* From Recitation 1 *)
  fun match' s =
    case (showt s)
      of EMPTY => (0,0)
       | ELT OPAREN => (0,1)
       | ELT CPAREN => (1,0)
       | NODE(L, R) =>
         let
             val (L', R') = Primitives.par(fn () => match' L,
                                           fn () => match' R)
             val (lcloses, lopens) = L'
             val (rcloses, ropens) = R'
         in if lopens >= rcloses then
               (lcloses, ropens + lopens - rcloses)
            else
               (lcloses + rcloses - lopens, ropens)
         end

  fun match s = (match' s) = (0, 0)

  (* Checks that the outermost two parentheses match each other  *)
  fun outerMatch S =
    if (length S) >= 2 andalso (match S)
       andalso (match (subseq S (1,(length S)-2)))
    then (length S)
    else 0

  fun parenDist S =
    let
      (* The following generates all subsequences of S *)
      fun allPrefixes S = tabulate (fn i => take(S, (i+1))) (length S)
      fun allSuffixes S = tabulate (fn i => drop(S, i)) (length S)
      fun allSubseqs S =  flatten (map allSuffixes (allPrefixes S))

      (* And this returns the maximum length matching subsequence *)
      val maxLen = (reduce Int.max 0 (map outerMatch (allSubseqs S)))
    in
      if (match S) andalso (maxLen > 0)
      then SOME(maxLen-2)
      else NONE
    end
end

(* A linear work, linear span sequential solution *)
functor ParenSequential(P : PAREN_PACKAGE) : PAREN =
struct
  structure P = P
  exception NYI

  open OC
  open P

  (*parenDist : paren seq -> int option
   *
   *[parenDist S] evaluates to NONE if `S` is not a closed string and
   *to `SOME d` otherwise, where d = min\{j - i - 1|(i, j) \in M_s\}.
   *This function is just a thin wrapper around pd'. This is the way a
   *physicist would implement this in FORTRAN 77.
   *
   *W(n) \in O(n), S(n) \in O(n)*)
  fun parenDist (S : paren Seq.seq) : int option =
      let
        (*pd' : (int * int list * int option) option * paren
         *[pd' (SOME (i, L, max), P)] is a standard iter function which
         *passes along the following state:
         * -> i : The current position in the sequence.
         * -> L : The list of the positions of all unclosed OPAREN.
         * -> max : The maximum paren distance encountered so far.
         *
         *Note that scan does not work on this function, so the divide
         *and conquer funciton is not purely academic.*)
        fun pd' (NONE, _) = NONE
          | pd' (SOME (i, L, max), OPAREN) = SOME (i + 1, i::L, max)
          | pd' (SOME (i, [], max), CPAREN) = NONE
          | pd' (SOME (i, j::js, max), CPAREN) =
            SOME (i + 1, js, omax (max, SOME (i - j - 1)))
      in
        case (Seq.iter pd' (SOME (0, [], NONE)) S) of
          SOME (_, [], max) => max
        | _ => NONE
      end

end

(* A linear work, logarithmic span divide-and-conquer solution *)
functor ParenDivAndConq(P : PAREN_PACKAGE) : PAREN =
struct

  open OC
  structure P = P
  open P

  (*parenDist : paren seq -> int option
   *
   *[parenDist S] evaluates to NONE if `S` is not a closed string and
   *to `SOME d` otherwise, where d = min\{j - i - 1|(i, j) \in M_s\}.
   *
   *W(n) \in O(n), S(n) \in O(log^2 n)*)
  fun parenDist (S : paren Seq.seq) : int option =
      let
        (*parenDist' : paren seq -> (int option * (int option * int option)
         *                          * (int * int))
         *
         *[parenDist' S] evaluates to (max, (OD, CD), (Os Cs)), where
         *`max` is the largest distance between two paired parentheses within
         *`S`, `OD` is the distance between the leftmost unmatched opening
         *parenthesis in `S` and the right end of `S` (is such a value
         *exists), `CD` is the same value fo closing parentheses, and
         *and `(Os, Cs)` are the number of unmatched opening and closing
         *parnetheses in `S`, respectively.
         *
         *`S` is recured upon and the above invariants are perserved upon
         *recombination of let and right halves.*)
        fun parenDist' (S : paren Seq.seq) =
            case Seq.showt S of
              Seq.EMPTY => (NONE, (NONE, NONE), (0, 0))
            | Seq.ELT OPAREN => (NONE, (SOME 0, NONE), (1, 0))
            | Seq.ELT CPAREN => (NONE, (NONE, SOME 0), (0, 1))
            | Seq.NODE(L, R) =>
              let
                val (L', R') = Primitives.par(fn () => parenDist' L,
                                              fn () => parenDist' R)
                val (Lmax, (LOD, LCD), (LO, LC)) = L'
                val (Rmax, (ROD, RCD), (RO, RC)) = R'

                val prevMax = omax(Lmax, Rmax)

                (*This line is identical to recitation 1's solution.*)
                val (Os, Cs) = if LO < RC then (RO, RC - LO + LC)
                               else (LO - RC + RO , LC)

                val (CD, OD, currMax) =
                    if LO = RC then
                      (LCD, ROD, oplus(LOD, RCD))
                    else if LO > RC then
                      (LCD, oplus(LOD, SOME(Seq.length R)), prevMax)
                    else if LO < RC then
                      (oplus(RCD, SOME(Seq.length L)), ROD, prevMax)
                    else
                      (LCD, ROD, prevMax)
              in
                (omax(prevMax, currMax), (OD, CD), (Os, Cs))
              end

        val (maxDist, _, (Os, Cs)) = parenDist' S
      in
        if (0, 0) = (Os, Cs) then maxDist else NONE
      end
end
