(* Wrapper for sequence that also provides paren type and a conveinent
 *function for generating test cases.*)
structure ArrayParenPackage : PAREN_PACKAGE =
struct
  structure Seq = ArraySequence
  exception NYI
  datatype paren = OPAREN
                 | CPAREN
end

functor ParenBF(P : PAREN_PACKAGE) =
struct
  structure P = P
  open P

  (* match function from recitation *)
  fun match s =
    if Seq.length s = 0  then false else
      let
        fun match' s =
          case Seq.showt s of
               Seq.EMPTY => (0,0)
             | Seq.ELT OPAREN => (0,1)
             | Seq.ELT CPARENT => (1,0)
             | Seq.NODE (L,R) =>
                 let
                   val ((i,j),(k,l)) =
                     Primitives.par (fn () => match' L, fn () => match' R)
                 in
                   if j > k then (i, l + j - k)
                   else (i + k - j, l)
                 end
      in
        match' s = (0,0)
      end

  (* A simple extention of match, returning true iff seq is closed and 
   * is not a concatenation of two closed strings *)
  (* WORK/SPAN is the same as match in big-O *)
  fun outerMatch s =
    (* if length is at least 2, seq starts with (, ends with ), and matches in
       the middle or the middle is empty, then the outer parens match *)
    if Seq.length s < 2 then false else
      let
        val startsWithO = Seq.nth s 0 = OPAREN
        val endsWithC = Seq.nth s ((Seq.length s)-1) = CPAREN
        val middle = ((Seq.length s) = 2) orelse match (Seq.subseq s (1,(Seq.length s) - 2))
      in
        startsWithO andalso endsWithC andalso middle
      end

  fun parenDist S =
    if match S then
      let
        val length = Seq.length S
        val indexSeq = Seq.flatten
                         (Seq.tabulate
                             ( fn i => Seq.tabulate ( fn len => (i,len) )
                             (length - i + 1)  )
                         length)
        val subseqseq = Seq.map (Seq.subseq S) indexSeq
        val subseqseq = Seq.filter outerMatch subseqseq
        val seqLengths = Seq.map Seq.length subseqseq
      in
        SOME ((Seq.reduce Int.max 0 seqLengths) - 2 )
      end
    else NONE

end

functor ParenDivAndConq(P : PAREN_PACKAGE) =
struct
  structure P = P
  open P
  open Seq

  val par = Primitives.par
  val maxL = List.foldl Int.max 0

  fun parenDist s =
    if length s = 0 then NONE else
    let
      fun longestParenRun s =
        case showt s of
             EMPTY => (0,0,(0,0,0,0))
           | ELT OPAREN => (0,1,(0,0,0,0))
           | ELT CPAREN => (1,0,(0,0,0,0))
           | NODE (L,R) =>
               let
                 val ((i,j,(l1,r1,summ1,maxm1)),(k,l,(l2,r2,summ2,maxm2))) =
                   par (fn () => longestParenRun L, fn () => longestParenRun R)
                 (* i' and j' is what would be returned by match function *)
                 val (i',j') =
                   if j > k then (i, l + j - k)
                   else (i + k - j, l)
                 val (l,r,summ,maxm) =
                   (* First, if j != k, then... *)
                   if j > k then
                     (* L *) (l1,
                     (* R *) l2 + summ2 + r2 + r1 + 2*k,
                     (* M *) summ1, maxm1) (* Keep track of both sum and max *)
                   else if j < k then
                     (* L *) (l1 + summ1 + r1 + l2 + 2*j,
                     (* R *) r2,
                     (* M *) summ2, maxm2) (* Keep track of both sum and max *)
                   (* Else, if j == k then... *)
                   else
                     (* Depends on whether j and k are zero or positive.  *)
                     case j > 0 of
                       true =>
                         let val m = r1 + l2 + 2*j
                         in 
                           (l1,r2,summ1 + summ2 + m, maxL [maxm1,maxm2,m])
                         end
                     | false =>
                         (l1,r2,summ1 + summ2 + r1 + l2, maxL [maxm1,maxm2,r1,l2] )

               in (i',j',(l,r,summ,maxm))
               end
    in
      case longestParenRun s of
           (* Ensure a closed string before returning *)
           (* Subtract 2 is because of the hw definition of parenDist *)
           (0,0,(l,r,_,m)) => SOME( (maxL [l,r,m]) - 2)
         | _ => NONE
    end
end
