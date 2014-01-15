signature SET =
sig

  (* LATEX
   *
   * This is the abstract type representing a set described in
   * Section~\ref{set:abs}.
   *)
  type set

  (* LATEX
   *
   * This indicates that each element of a set has to have type
   * $\!\type{key}$.
   *)
  type key

  type t = set

  (* LATEX
   *
   * Boo
   *)
  structure Seq : SEQUENCE

  (* LATEX
   *
   * \sml{empty} represents the empty set $\emptyset$.
   *)
  val empty : set

  (* LATEX
   *
   * For a value \sml{x} of type $\!\type{key}$, the expression
   * \sml{singleton x} evaluates to a set containing exactly \sml{x}.
   *)
  val singleton : key -> set

  (* LATEX
   *
   * If \sml{s} is a value of type $\!\type{set}$, then \sml{size s}
   * evaluates to $|s|$ (i.e., the number of elements in the set
   * represented by \sml{s}).
   *)
  val size : set -> int


  (* LATEX
   *
   * If \sml{s1} and \sml{s2} are values of type $\!\type{set}$, then
   * \sml{equal (s1,s2)} evaluates to \sml{true} if \sml{s1} and
   * \sml{s2} are identical sets (i.e, they have the exact same set of
   * elements); otherwise, it evaluates to \sml{false}.
   *)
  val equal : set * set -> bool

  (* LATEX
   *
   * If \sml{f} is a function, \sml{b} is a value, and \sml{s} is a
   * set value, then \sml{iter f b s} iterates $f$ with left
   * association on $s$ on an implementation-specified ordering, using
   * $b$ as the base case. That is to say, \sml{iter f b s} evaluates
   * to \[ f(f(\ldots f(b,s_{|s|-1}), \ldots s_1), s_0), \] where
   * $s_0, s_1, \dots, s_{|s| - 1}$ are the elements of $s$ listed in
   * the order that the implementation chooses.
   *)
  val iter : ('b * key -> 'b) -> 'b -> set -> 'b

  (* LATEX
   *
   * If $p$ is a predicate and $s$ is a set value, then \sml{filter p
   * s} evaluates to the subset $s'$ of $s$ such that an element $x
   * \in s'$ if and only if $p$ holds on $x$.
   *)
  val filter : (key -> bool) -> set -> set


  (* LATEX
   *
   * If $s$ is a set value and $k$ is a key value, then \sml{find s
   * k} evaluates to a boolean value indicating whether or not $k$ is 
   * a member of $s$.
   *)
  val find : set -> key -> bool

  (* LATEX
   *
   * If \sml{s} and \sml{t} are set values, \sml{union (s,t)} evaluates
   * to the set $s \cup t$.
   *)
  val union : (set * set) -> set

  (* LATEX
   *
   * If \sml{s} and \sml{t} are set values, \sml{intersection (s,t)}
   * evaluates to the set $s \cap t$.
   *)
  val intersection : (set * set) -> set

  (* LATEX
   *
   * If \sml{s} and \sml{t} are set values, \sml{difference (s,t)}
   * evaluates to the set $s \setminus t$ (i.e. the set $\{x \in s : s
   * \not\in t\}$).
   *)
  val difference : (set * set) -> set

  (* LATEX
   *
   * If \sml{k} is a key value and \sml{s} is a set, \sml{insert k s}
   * evaluates to the set $s \cup \{k\}$.
   *)
  val insert : key -> set -> set

  (* LATEX
   *
   * If \sml{k} is a key value and \sml{s} is a set, \sml{delete k s}
   * evaluates to the set $s \setminus \{k\}$.
   *)
  val delete : key -> set -> set

  (* LATEX
   *
   * If \sml{s} is a sequence value of type $\mathit{key}
   * \type{Seq.seq}$, then \sml{fromSeq s} evaluates to the set
   * containing the elements $s_0, s_1, \dots, s_{|s| - 1}$.  The
   * ordering in the set representation may differ from the ordering
   * in the sequence representation.
   *)
  val fromSeq : key Seq.seq -> set


  (* LATEX
   *
   * If \sml{s} is a set value where the elements have type
   * $\mathit{key}$, then \sml{toSeq s} evaluates to the sequence of
   * type $\mathit{key} \type{Seq.seq}$ containing all $|s|$ elements
   * of $s$ appearing in the order of the implementation's choosing.
   *)
  val toSeq : set -> key Seq.seq

  (* LATEX
   *
   * If \sml{s} is a set, \sml{toString s} evaluates to a string
   * representation of $s$ listing the elements of $s$, interleaved
   * with ``,''.
   *)
  val toString : set -> string

end
