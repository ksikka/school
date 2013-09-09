signature ST_SEQUENCE =
sig
  structure Seq : SEQUENCE

  type 'a seq = 'a Seq.seq
  type 'a stseq

  (* LATEX
   *
   * \sml{Range} is raised whenever an invalid index into a sequence is
   * used. The specifications for the individual functions state when this
   * will happen more precisely.
   *
   * This is the only exception that the functions in a module ascribing to
   * \sml{SEQUENCE} raise. An expression applying such a function to
   * appropriate arguments may raise other exceptions, but it will do so
   * only because one of the arguments in that application raised the other
   * exception.
   *)
  exception Range

  (* LATEX
   *
   * If \sml{s} is a sequence value and \sml{i} is an $\tint$ value and $i$
   * is a valid index into $s$, then \smlp{nth s i} evaluates to $s_i$.
   *
   * This application raises \sml{Range} if $i$ is not a valid index.
   *)
  val nth : 'a stseq -> int -> 'a

  (* LATEX
   *
   * The call \sml{insert (i,v) S} replaces the $i^{th}$ location of $S$
   * with $v$ returning a new sequence.   
   * Will raise \sml{Range} if $i$ is out of bounds, i.e., $i < 0$ or 
   * $i \geq |S|$.
   *)
  val update : (int * 'a) -> 'a stseq -> 'a stseq


  (* LATEX
   *
   * Let \sml{ind} and \sml{s} be sequence values and let $$occ(i) := \fcp{j
   * | ind_j = (i,x) \text{ for some x}}$$ \smlp{inject ind s} evaluates to
   * the sequence $s'$ with length $\seql{s}$, where for all valid indicies
   * $i$ into $s$
   *
   * \begin{align*}
   *   s'_i = \left \{
   *   \begin{array}{ll}
   *     s_i & occ(i) = \{\}\\
   *     x & j = \max \left ( occ(i) \right ) \wedge ind_j = (i,x)\\
   *   \end{array}
   *   \right .
   * \end{align*}
   *
   * This application will raise \sml{Range} if any element of
   * $\mathit{ind}$ has a first component that is not a valid index into
   * $s$.
   *)
  val inject : (int*'a) seq -> 'a stseq -> 'a stseq

  val fromSeq : 'a seq -> 'a stseq
  val toSeq : 'a stseq -> 'a seq
end
