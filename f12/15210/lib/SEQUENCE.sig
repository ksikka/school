signature SEQUENCE =
sig
  (* LATEX
   *
   * This is the abstract type that represents the notion of a sequence
   * described in section \ref{seq:abs}.
   *)
  type 'a seq

  (* LATEX
   *
   * $\alpha \type{treeview}$ provides a view of the abstract $\alpha
   * \type{seq}$ type as a binary tree.
   *)
  datatype 'a treeview = EMPTY
                       | ELT of 'a
                       | NODE of ('a seq * 'a seq)

  (* LATEX
   *
   * $\alpha \type{listiew}$ provides a view of the abstract $\alpha
   * \type{seq}$ type as a list.
   *)
  datatype 'a listview = NIL
                       | CONS of ('a * 'a seq)

  (* LATEX
   *
   * The type $\alpha \type{ord}$ represents an ordering on the type
   * $\alpha$ as a function from pairs of elements of $\alpha$ to
   * $\mathit{order}$.
   *)
  type 'a ord = 'a * 'a -> order

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
   * \smlp{empty ()} evaluates to $\seq{}$.
   *)
  val empty : unit -> 'a seq

  (* LATEX
   *
   * If \sml{x} is a value, then \smlp{singleton x} evaluates to $\seq{x}$.
   *)
  val singleton : 'a -> 'a seq

  (* LATEX
   *
   * If \sml{s} is a sequence value, then \smlp{length s} evaluates to
   * $\seql{s}$.
   *)
  val length : 'a seq -> int

  (* LATEX
   *
   * If \sml{s} is a sequence value and \sml{i} is an $\tint$ value and $i$
   * is a valid index into $s$, then \smlp{nth s i} evaluates to $s_i$.
   *
   * This application raises \sml{Range} if $i$ is not a valid index.
   *)
  val nth : 'a seq -> int -> 'a

  (* LATEX
   *
   * If \sml{f} is a function and \sml{n} is an $\tint$ value, then
   * \smlp{tabulate f n} evaluates to a sequence $s$ such that $\seql{s} =
   * n$ and, for all valid indicies $i$ into $s$, $s_i$ is the result of
   * evaluating \smlp{f i}.
   *
   * Note that the evaluation of this application will only terminate if
   * $f$ terminates on all valid indices into the result sequence $s$.
   *)
  val tabulate : (int -> 'a) -> int -> 'a seq

  (* LATEX
   *
   * If \sml{l} is a list value, then \smlp{fromList l} evaluates to the
   * index preserving sequence representation of $l$. That is to say,
   * \sml{fromList} is logically equivalent to
   *
   * \begin{code}
   *  fn l => tabulate (fn i => List.nth(l,i)) (List.length l)
   * \end{code}
   *)
  val fromList : 'a list -> 'a seq


  (* LATEX
   *
   * If \sml{ord} is an ordering on the type $\alpha$, \sml{collate ord}
   * evaluates to an ordering on the type $\alpha \type{seq}$ derived
   * lexicographically from \sml{ord}.
   *)
  val collate : 'a ord -> 'a seq ord

  (* LATEX
   *
   * If \sml{f} is a function and \sml{s} is a sequence value such that
   * $\seql{s} = n$, then \smlp{map f s} evaluates to the sequence $r$ such that
   * $\seql{r} = n$ and, for all valid indicies $i$ into $s$, $r_i$ is the
   * result of evaluating \smlp{f $s_i$}.
   *
   * Note that the evaluation of this application will only terminate if
   * \sml{f} terminates on $s_i$ for all valid indicies $i$.
   *)
  val map : ('a -> 'b) -> 'a seq -> 'b seq

  (* LATEX
   *
   * If \sml{f} is a function and $s_1$ and $s_2$ are sequence values, then
   * \smlp{map2 f $s_1$ $s_2$} evaluates to the sequence $r$ such that
   * $r_i$ is the result of evaluating $f ~({s_1}_i, {s_2}_i)$ for all $i$
   * that are valid indices into both $s_1$ and $s_2$.
   *
   * It follows from the definition of a valid index and the above
   * specification that $$\seql{r} = \min (\seql{s_1}, \seql{s_2})$$
   *
   * Note that the evaluation of this application will only terminate if
   * $f$ terminates on $({s_1}_i, {s_2}_i)$ for all $0 \leq i < \seql{r}$.
   *)
  val map2 : (('a * 'b) -> 'c) -> 'a seq -> 'b seq -> 'c seq

  (* val mapprod : (('a * 'b) -> 'c) -> 'a seq -> 'b seq -> 'c seq *)
  (* val mapsum : (('a * 'b) -> 'c) -> 'a seq -> 'b seq -> 'c seq *)

  (* LATEX
   *
   * To define the behaviour of \sml{reduce}, we'll first define a type of
   * non-empty binary trees, then a mapping from non-empty sequences to
   * those trees, then an analog to \sml{reduce} on trees, and finally
   * \sml{reduce} on sequences.
   *
   * The type of non-empty trees we'll use is
   *
   * \begin{code}
   *   datatype 'a tree = Leaf of 'a
   *                    | Node of ('a tree * 'a tree)
   * \end{code}
   *
   * Assume that \sml{prevpow2} is a function with type
   * $\tarr{\tint}{\tint}$ such that if \sml{x} is an $\tint$ value then
   * \sml{prevpow2 x} evaluates to the maximum element of the set $$\fcp{y
   * | y < x \pand \exists i \in \mathbb{N}. y = 2^i}$$
   *
   * With these two assumptions, we define a mapping from non-empty
   * sequences to trees as
   *
   * \begin{code}
   * fun toTree s =
   *    case $\seql{s}$
   *     of 1 => Leaf($s_0$)
   *      | n => Node(toTree (take (s, prevpow2 $\seql{s}$)),
   *                  toTree (drop (s, prevpow2 $\seql{s}$)))
   * \end{code}
   *
   * The result of this is a nearly-balanced tree where the number of
   * leaves to the left of any internal node is the greatest power-of-two
   * less than the total number of leaves below that node. The structure of
   * such trees depends only on the length of the input sequence. An
   * example tree is shown in Figure \ref{seq:fig:tree}.
   *
   * We'll now define the function \sml{reducet} for the tree type.
   * \sml{reducet} has type $$((\alpha \times \alpha) \to \alpha) \to
   * \alpha \type{tree} \to \alpha$$ and is defined as
   *
   * \begin{code}
   * fun reducet f (Leaf x) = x
   *   | reducet f (Node(l,r)) = f(reducet l, reducet r)
   * \end{code}
   *
   * Finally, if \sml{f} is a function, \sml{b} a value, and \sml{s} a
   * sequence value, there are two cases:
   * \begin{itemize}
   * \item If $\seql{s} = 0$ then \smlp{reduce f b s} evaluates to \sml{b}.
   *
   * \item If $\seql{s} > 0$, and \smlp{reducet f (toTree s)} evaluates to
   * some value \sml{v}, then \smlp{reduce f b s} evaluates to $f(b,v)$.
   * \end{itemize}
   *
   * Note that this definition does \emph{not} require that \sml{f} is
   * associative. The transformation to trees and \sml{reduce} on trees are
   * both well-defined without respect to any associativity of \sml{f}. The
   * tree structure defined by \sml{toTree} defines a particular
   * association of \sml{f} on any sequence: if we use $\oplus$ as infix
   * notation for \sml{f}, the tree corresponds to exactly one of the many
   * ways to parenthesize the expression $$\fp{s_0 \oplus s_1 \oplus \ldots
   * \oplus s_{\seqmi{s}}} \oplus b$$ If \sml{f} happens to be associative,
   * all of the possible ways to parenthesize this expression result in the
   * same computation.
   *
   * It follows that if \sml{f} is associative and \sml{b} is a value such
   * that $b$ is the identity of $f$, \sml{reduce f b} is logically
   * equivalent to \sml{iter f b}.
   *)
  val reduce : (('a * 'a) -> 'a) -> 'a -> 'a seq -> 'a

  (* LATEX
   *
   * If \sml{S} is a sequence of type $alpha$ and  \sml{f} defines a total 
   * ordering on the elements of type $\alpha$, then \sml{argmax f S} returns
   * an index (location in the sequence) of a maximal value in \sml{S}.
   * Maximal is defined with respect to \sml{f}.
   *
   * This function raises \sml{Range} if the \sml{S} is empty.
   *)
  val argmax : 'a ord -> 'a seq -> int

  (* LATEX
   *
   * If \sml{f} is an associative function, and \sml{b} a value such that
   * $b$ is an identity of $f$, \smlp{scan f b} is logically equivalent to
   * \begin{code}
   *  fn s =>
   *   (tabulate (fn i => reduce f b (take(s,i))) (length s),
   *    reduce f b s)
   * \end{code}
   *)
  val scan : (('a * 'a) -> 'a) -> 'a -> 'a seq -> ('a seq * 'a)

  (* LATEX
   *
   * If $p$ is a predicate and $s$ is a sequence value, then \smlp{filter p
   * s} evaluates to the longest subsequence $s'$ of $s$ such that $p$
   * holds for every element of $s'$.
   *)
  val filter : ('a -> bool) -> 'a seq -> 'a seq

  (* LATEX
   *
   * \sml{iter} is logically equivalent to \sml{iterate}, defined below.
   *
   * \begin{code}
   *   fun iterate f b s =
   *       case showl s
   *        of NIL => b
   *         | CONS (x,xs) => iter f (f(b,x)) xs
   * \end{code}
   *
   * Less formally, if \sml{f} is a function, \sml{b} is a value, and \sml{s}
   * is a sequence value, then \smlp{iter f b s} computes the iteration of
   * \sml{f} on \sml{s} with left-association and \sml{b} as the base case.
   * We can write this iteration as $$f(f(\ldots f(b,s_0), \ldots
   * s_{\seql{s}-2}), s_{\seqmi{s}})$$ or, using $\oplus$ as infix notation
   * for $f$, $$(\ldots(((b \oplus s_0) \oplus s_1) \oplus s_2)\oplus
   * \ldots \oplus s_{\seqmi{s}})$$
   *)
  val iter : ('b * 'a -> 'b) -> 'b -> 'a seq -> 'b

  (* LATEX
   *
   * \sml{iterh} is a generalization of \sml{iter} that also computes the
   * sequence of all partial results produced by the iterated application
   * of the functional argument. Specifically, \smlp{iterh f b} is
   * logically equivalent to
   *
   * \begin{code}
   *   fn s => (tabulate (fn i => iter f b (take (i,s))) ($\seql{s}$),
   *            iter f b s)
   * \end{code}
   *)
  val iterh : ('b * 'a -> 'b) -> 'b -> 'a seq -> ('b seq * 'b)

  (* LATEX
   *
   * \sml{flatten} is logically equivalent to \smlp{iter append (empty
   * ())}.
   *
   * Less formally, if \sml{s} is a sequence value of sequence values, then
   * \smlp{flatten s} evaluates to the concatenation of the sequences in
   * $s$ in the order that they appear in $s$.
   *)
  val flatten : 'a seq seq -> 'a seq

  (* LATEX
   *
   * If \sml{I} is an $\tint$ sequence value and \sml{s} is a sequence
   * value, then \smlp{partition I s} evauluates to a sequence of sequences
   * \sml{p} such that $\seql{p} = \seql{I}$ and, for every $i$ that's a
   * valid index of $I$, $p_i$ is a subsequence of $s$ of length $I_i$
   * starting at index$$\sum_{j=0}^{i-1} I_j$$ in $s$.
   *
   * That is to say, \sml{partition} produces a sequence of adjacent
   * subsequence of $s$ with lengths specified by the elements of $I$.
   *
   * Let $$l := \sum_i I_i$$ \sml{partition} has the property that for
   * any sequence $s$,
   * \begin{code}
   * (flatten (partition I s))
   * \end{code}
   * is the first subsequence of $s$ of length $l$. In particular, if $l =
   * \seql{s}$, this means that
   * \begin{code}
   * fn ss => \sml{(partition (map length ss) (flatten ss))}
   * \end{code}
   * is functionally equivalent to the identity function on
   * $\tseq{tseq{\alpha}}$.
   *)
  val partition : int seq -> 'a seq -> 'a seq seq

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
  val inject : (int*'a) seq -> 'a seq -> 'a seq

  (* LATEX
   *
   * If \sml{s1} and \sml{s2} are sequence values, then \smlp{append (s1,
   * s2)} evaluates to a sequence $s$ with length $\seql{s_1} + \seql{s_2}$
   * such that the subsequence of $s$ starting at index $0$ with length
   * $\seql{s_1}$ is $s_1$ and the subsequence of $s$ starting at index
   * $\seql{s_1}$ with length $\seql{s_2}$ is $s_2$.
   *)
  val append : 'a seq * 'a seq -> 'a seq

  (* LATEX
   *
   * If \sml{s} is a sequence value and \sml{n} is an integer, then
   * \smlp{take (s,n)} evaluates to the first subsequence of $s$ of length
   * $n$. This application will raise \sml{Range} if $n > \seql{s}$.
   *)
  val take : 'a seq * int -> 'a seq

  (* LATEX
   *
   * If \sml{s} is a sequence value and \sml{n} is an integer, then
   * \smlp{drop (s,n)} evaluates to the last subsequence of $s$ of length
   * $\seql{s} - n$. This application will raise \sml{Range} if $n >
   * \seql{s}$.
   *)
  val drop : 'a seq * int -> 'a seq

  (*
   *
   * If \sml{s} is a sequence value and \sml{(start,end,step)} is a triple
   * of $\tint$ values, then \smlp{rake s (start,end,step)} evaluates to the
   * subsequence $s'$ of $s$ of length
   * $\frac{(\mathit{end}-\mathit{start})}{\mathit{step}}$ such that $$s'_i
   * = s_{\mathit{start} + i \cdot \mathit{step}}$$ for all valid indicies
   * $i$ into $s'$.
   *
   * This application will raise \sml{Range} if $\mathit{start}$ or
   * $\mathit{end}$ are not valid indicies into $s$.
   *)
  val rake : 'a seq -> (int * int * int) -> 'a seq

  (* LATEX
   *
   * If \sml{s} is a sequence value and $\sml{j}$ and \sml{len}
   * $\tint$ are values such that $j+len \leq |s|$, then \smlp{subseq s
   * (j, len)} evaluates to the subsequence $s'$ of $s$ of length
   * $len$ such that $s'_i = s_{i+j}$ for all \sml{i} $<$ \sml{len}.
   *
   * This application will raise \sml{Range} if the subsequence
   * specification is invalid.
   *)
  val subseq : 'a seq -> (int * int) -> 'a seq

  (* LATEX
   *
   * Let $s$ be a sequence value and $i$ an $\tint$ value.
   * \begin{itemize}
   *
   * \item If $\seql{s} = 0$, then \smlp{splitMid(s,i)} evaluates to \sml{NONE}.
   *
   * \item If $\seql{s} > 0$, \smlp{splitMid(s,i)} evaluates to \smlp{SOME
   * (l,$s_i$,r)} where $l$ is the first subsequence of $s$ of length $i-1$
   * and $r$ is the last subsequence of $s$ of length $\seqmi{s} - i$.
   *
   * \end{itemize}
   *
   * This application will raise \sml{Range} if $i > \seql{s}$.
   *)
  val splitMid : 'a seq * int -> ('a seq * 'a * 'a seq) option

  (* LATEX
   *
   * If \sml{ord} is an ordering and \sml{s} is a sequence, \smlp{sort ord
   * s} evaluates to a rearrangement of the elements of \sml{s} that is
   * sorted with respect to \sml{ord}.
   *
   * %% TODO: is this well def with any ordering? in place, stable?
   *)
  val sort : 'a ord -> 'a seq -> 'a seq

  (* LATEX
   *
   *
   *)
  val merge : 'a ord -> 'a seq -> 'a seq -> 'a seq

  (* LATEX
   *
   * Let \sml{ord} be an ordering and $s$ be a sequence of
   * pairs. \smlp{collect ord s} evaluates to a sequence of sequences where
   * each unique first coordinate of elements of $s$ is paired with the
   * sequence of second coordinates of elements of s. The resultant
   * sequence is sorted by the first coordinates, according to
   * \sml{ord}. The elements in the second coordinates appear in their
   * original order in $s$.
   *
   * For example, if $$s = \seq{(5,"b"),(1,"a"),(1,"b"),(1,"b")}$$ and
   * $ord$ is the usual ordering on integers, then \smlp{collect ord s}
   * will evaluate to $$\seq{(1,\seq{"a","b","b"}),(5,\seq{"b"})}$$
   *)
  val collect : 'a ord -> ('a * 'b) seq -> ('a * 'b seq) seq

  (* LATEX
   *
   * If \sml{f} is a function and \sml{s} is a sequence value,
   * \smlp{toString f s} evaluates to a string representation of $s$. This
   * representation begins with ``$\langle$'', which is followed by the
   * results of applying $f$ to each element of $s$, in left-to-right
   * order, interleaved with ``,'', and ends with ``$\rangle$''.
   *)
  val toString : ('a -> string) -> 'a seq -> string

  (* LATEX
   *
   * Let \sml{p} be a predicate on characters. A token is a non-empty
   * maximal substring of a string not containing any character that
   * satisfies $p$. If \sml{p} is a predicate on characters and \sml{s} is
   * a string, \smlp{tokens p s} evaluates to the sequence of tokens of $s$
   * in left to right order.
   *
   * For example, \sml{tokens Char.isPunct ``the,,,horse''} evaluates to
   * $$\seq{``the'',``horse''}$$ and \sml{tokens Char.isPunct ``the,horse''}
   * evaluates to $$\seq{``the'',``horse''}$$.
   *)
  val tokens : (char -> bool) -> string -> string seq


  (* LATEX
   *
   * Let \sml{p} be a predicate on characters. A field is a possibly empty
   * maximal substring of not containing any character that satisfies
   * $p$. If \sml{p} is a predicate on characters and \sml{s} is a string,
   * \smlp{fields p s} evaluates to the sequence of tokens of $s$ in left to
   * right order.
   *
   * For example, \sml{fields Char.isPunct ``the,,,horse''} evaluates to
   * $$\seq{``the'',``'',``'',``horse''}$$ and \sml{fields Char.isPunct
   * ``the,horse''} evaluates to $$\seq{``the'',``horse''}$$.
   *)
  val fields : (char -> bool) -> string -> string seq

  (* LATEX
   *
   * Let \sml{s} be a sequence value.
   *
   * \begin{itemize}
   *
   * \item If $\seql{s} = 0$, \smlp{showt s} evaluates to \sml{EMPTY}.
   *
   * \item If $\seql{s} = 1$, \smlp{showt s} evaluates to
   * \sml{ELT($s_0$)}.
   *
   * \item If $\seql{s} > 1$, and \sml{NODE(take (s, $\fp{\seql{s}/2}$), drop (s,
   * $\fp{\seql{s}/2}$))} evalautes to some value \sml{v}, \smlp{showt s}
   * evaluates to \sml{v}.
   *
   * \end{itemize}
   *)
  val showt : 'a seq -> 'a treeview

  (* LATEX
   *
   * Let \sml{s} be a sequence value.
   *
   * \begin{itemize}
   *
   * \item If $\seql{s} = 0$, \smlp{showti s f} evaluates to \sml{EMPTY}.
   *
   * \item If $\seql{s} = 1$, \smlp{showti s f} evaluates to
   * \sml{ELT($s_0$)}.
   *
   * \item If $\seql{s} > 1$, $\oftp{f}{\tarr{\tint}{\tint}}$ is a
   * function, and \sml{NODE(take (s, f $\seql{s}$), drop (s, f
   * $\seql{s}$))} evalautes to some value \sml{v}, \smlp{showti s f}
   * evaluates to \sml{v}.
   *
   * \end{itemize}
   *)
  val showti : 'a seq -> (int -> int) -> 'a treeview

  (* LATEX
   *
   * Let \sml{tv} be a $\type{treeview}$ value.
   *
   * \begin{itemize}
   *
   * \item If \sml{tv} is \sml{EMPTY}, then \smlp{hidet tv} evaluates to
   * $\seq{}$.
   *
   * \item If \sml{tv} is \sml{(ELT x)}, then \smlp{hidet tv} evaluates
   * to $\seq{x}$.
   *
   * \item If \sml{tv} is \sml{NODE (l,r)}, then \smlp{hidet tv} evaluates
   * to the same value as \sml{append (l,r)}.
   *
   * \end{itemize}
   *)
  val hidet : 'a treeview -> 'a seq

  (* LATEX
   *
   * Let \sml{s} be a sequence value.
   *
   * \begin{itemize}
   *
   * \item If $\seql{s} = 0$, \smlp{showl s} evaluates to \sml{NIL}.
   *
   * \item If $\seql{s} > 0$, \smlp{showl s} evaluates to
   * \sml{CONS($s_0$,$\seq{s_1, \ldots, s_{\seqmi{s}}}$)}.
   *
   * \end{itemize}
   *)
  val showl : 'a seq -> 'a listview

  (* LATEX
   *
   * Let \sml{lv} be a $\type{listview}$ value.
   *
   * \begin{itemize}
   *
   * \item If \sml{lv} is \sml{NIL}, then \smlp{hidel lv} evaluates to
   * $\seq{}$.
   *
   * \item If \sml{lv} is \sml{CONS(x,xs)}, then \sml{hidel lv} evaluates
   * to a sequence with length $\seql{xs} + 1$ such that $s'_0$ is $x$ and
   * $s'_i$ is $xs_i$ for all valid indices $i$ into $xs$.
   *
   * \end{itemize}
   *)
  val hidel : 'a listview -> 'a seq

  val % : 'a list -> 'a seq
end
