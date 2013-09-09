signature TABLE =
sig
  (* LATEX
   *
   * This is the abstract type representing a table with key type
   * $\!\type{key}$ (see below) and value type $\alpha$.
   *)
  type 'a table
  (* LATEX
   *
   * This type is a shorthand for the abstract type $\alpha \type{table}$
   * representing a table.
   *)
  type 'a t = 'a table

  structure Key : EQKEY

  (* LATEX
   *
   * This indicates that the type of keys in a table has to have type
   * $\!\type{key}$.
   *)
  type key = Key.t

  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq

  structure Set : SET where type key = key and Seq = Seq
  type set = Set.set

  (* LATEX
   *
   * \sml{empty} represents the empty collection $\emptyset$.
   *)
  val empty : unit -> 'a table

  (* LATEX
   *
   * If \sml{k} is a value of type $\!\type{key}$ and \sml{v} is a
   * value of type $\alpha$, the expression \sml{singleton (k,v)}
   * evaluates to the collection $\{(k,v)\}$.
   *)
  val singleton : key * 'a -> 'a table

  (* LATEX
   *
   * If \sml{T} is a value of type $\alpha \type{table}$, then
   * \sml{size T} evaluates to $|T|$ (i.e., the number of keys in the
   * collection \sml{T}).
   *)
  val size : 'a table -> int

  (* LATEX
   *
   * If \sml{f} is a function of type $\alpha \to \beta$ and \sml{T}
   * is a value of type $\alpha \type{table}$ with entries \[
   * \{(k_1,v_1), \dots, (k_n, v_n)\}, \] then \sml{map f T} evaluates
   * to $\{(k_1, f v_1), (k_2, f v_2), \dots, (k_n, f v_n)\}$. That
   * is, it creates a new collection with the same keys by applying
   * \sml{f} on each value.
   *)
  val map : ('a -> 'b) -> 'a table -> 'b table

  (* LATEX
   *
   * This function generalizes the \sml{map} function. If \sml{f} is a
   * function of type $\!\type{key} \times \alpha \to \beta$ and
   * \sml{T} is a value of type $\alpha \type{table}$ with entries $
   * \{(k_1,v_1), \dots, (k_n, v_n)\}$, then \sml{mapk f T} evaluates
   * to $\{(k_1, f(k_1,v_1)), (k_2, f(k_2,v_2)), \dots, (k_n,
   * f(k_n,v_n))\}$.
   *)
  val mapk : (key * 'a -> 'b) -> 'a table -> 'b table

  (* LATEX
   *
   * If \sml{f} is a function of type $\type{key} \to \alpha$ and \sml{S}
   * is a value of type $\type{set}$ with elements \[
   * \{k_1, \dots, k_n\}, \] then \sml{tabulate f S} evaluates
   * to $\{(k_1, f k_1), (k_2, f k_2), \dots, (k_n, f k_n)\}$.
   *)
  val tabulate : (key -> 'a) -> set -> 'a table

  (* LATEX
   *
   * For a table \sml{T}, the function \sml{domain T} returns
   * the domain of \sml{T} as a set.
   *)
  val domain : 'a table -> set

  (* LATEX
   *
   * For a table \sml{T}, the function \sml{range T} returns
   * the range of \sml{T} as a sequence.   In particular it is
   * equivalent to \sml{Seq.map (fn (k,v) => v) (toSeq T)}.
   *)
  val range : 'a table -> 'a seq

  (* LATEX
   *
   * The function \sml{reduce f init T} returns the same as
   * \sml{Seq.reduce f init (range(T))}
   *)
  val reduce : ('a * 'a -> 'a) -> 'a -> 'a table -> 'a

  (* LATEX
   *
   * If \sml{p} is a predicate and \sml{T} is an $\alpha \type{table}$
   * value, then \sml{filter p T} evaluates to the collection $T'$ of
   * $T$ such that $(k,v) \in T$ if and only if $p$ evaluates to
   * \sml{true} on $(k,v)$.
   *)
  val filter : (key * 'a -> bool) -> 'a table -> 'a table

  (* LATEX
   *
   * If \sml{f} is a function, \sml{b} is a value, and \sml{T} is a
   * table value, then \sml{iter f b s} iterates $f$ with left
   * association on $T$ on an implementation-specified ordering, using
   * $b$ as the base case. That is, \sml{iter f b T} evaluates to \[
   * f(f(\ldots f(b,(k_{|T|},v_{|T|})), \ldots (k_2,v_2))),
   * (k_1,v_1)), \] where $(k_1,v_1), (k_2,v_2), \dots, (k_{|T|},
   * v_{|T|})$ are members of $T$ listed in the order that the
   * implementation chooses.
   *)
  val iter : ('b * (key * 'a) -> 'b) -> 'b -> 'a table -> 'b

  (* LATEX
   *
   * If \sml{f} is a function, \sml{b} is a value, and \sml{T} is a
   * table value, then \sml{iterh f b s} iterates $f$ with left
   * association on $T$ on an implementation-specified ordering, using
   * $b$ as the base case. Unlike \sml{iter}, \sml{iterh} also stores
   * intermediate results in a table. That is, if the implementation
   * orders $T$ as $(k_1, v_1), (k_2, v_2), \dots, ..., (k_{|T|},
   * v_{|T|})$ and we let $r_i$ denote the result of the partial
   * evaluation up to the $i$-th pair (i.e., $r_i = f(f(\ldots
   * f(b,(k_{i},v_{i})), \ldots (k_2,v_2))), (k_1,v_1))$), then
   * \sml{iterh} evaluates to the pair \[ (\{(k_i, r_i) : i = 1,
   * \dots, |T|\}, r_{|T|}), \] where $r_{|T|} = \sml{iter f b T}$ by
   * definition.
   *)
  val iterh : ('b * (key * 'a) -> 'b) -> 'b -> 'a table -> ('b table * 'b)



  (* LATEX
   *
   * If \sml{T} is a table value and \sml{k} is a key value, then
   * \sml{find T k} evaluates to \sml{SOME v} provided that $k$ is
   * present in $T$ and is associated with the value $v$; otherwise,
   * it evaluates to \sml{NONE}.
   *)
  val find : 'a table -> key -> 'a option

  (* LATEX
   *
   * \sml{merge} is a generalization of set union in the following
   * sense. If \sml{f} is a function of type $\alpha \times \alpha \to
   * \alpha$ and \sml{S} and \sml{T} are $\alpha$ tables, then
   * \sml{merge f (S, T)} evaluates a table with the following
   * properties: (1) it contains all the keys from $S$ and $T$ and (2)
   * for each key $k$, its associated value is inherited from either
   * $S$ or $T$ if $k$ is present in \emph{exactly} one of them. But
   * if $k$ is present in both tables, i.e., $(k, v) \in S$ and $(k,
   * w) \in T$, then the value is $f(v, w)$.
   *)
  val merge : ('a * 'a -> 'a) -> ('a table * 'a table) -> 'a table

  (* LATEX
   *
   * \sml{mergeOpt} further generalizes set union, allowing values to
   * cancel out each other and eliminate the presence of a key in
   * manner similar to set symmetric difference. If \sml{f} is a
   * function of type $\alpha \times \alpha \to \alpha \type{option}$
   * and \sml{S} and \sml{T} are $\alpha$ tables, then \sml{merge f
   * (S, T)} evaluates a table with the following properties: (1) it
   * contains all the keys from $S$ and $T$ and (2) for each key $k$,
   * its associated value is inherited from either $S$ or $T$ if $k$
   * is present in \emph{exactly} one of them. But if $k$ is present
   * in both tables, i.e., $(k, v) \in S$ and $(k, w) \in T$, then the
   * following outcomes are possible: in the case that $f(v, w)$
   * evaluates to \sml{NONE}, the key $k$ will not be present in the
   * output table; otherwise, $f(v, w)$ evaluates to \sml{SOME r} and
   * the key $k$ will be associated with the value $r$.
   *)
  val mergeOpt : ('a * 'a -> 'a option) -> ('a table * 'a table) -> 'a table

  (* LATEX
   *
   * \sml{extract} is a generalization of set intersection in the
   * following sense. If \sml{T} is an $\alpha$ table and \sml{S} is a
   * set, then \sml{extract (T,S)} evaluates to $\{(k, v) \in T : k
   * \in_m S \}$.
   *)
  val extract : 'a table * set -> 'a table

  (* LATEX
   *
   * \sml{extractOpt} is a further generalization of set
   * intersection. If \sml{f} is a function $\alpha \times \beta \to
   * \gamma\type{option}$, \sml{T} is an $\alpha$ table, and \sml{S}
   * is a $\beta$ table, then \sml{extractOpt f (T,S)} evaluates to
   * $\{(k, w) : (k,v) \in T, (k,v') \in S, \mbox{ and } w = f(v,v')
   * \}$.
   *)
  val extractOpt : ('a * 'b -> 'c option) -> 'a table * 'b table -> 'c table

  (* LATEX
   *
   * This operation extends set difference. If \sml{T} is an $\alpha$
   * table, and \sml{S} is a set, then \sml{erase (T,S)} evaluates to
   * $\{(k, v) \in T : (k,v) \in T, k \not\in_m S \}$.
   *)
  val erase : 'a table * set -> 'a table


  (* LATEX
   *
   * For a function \sml{f} of type $\alpha \times \alpha \to \alpha$,
   * a key-value pair \sml{(k, v)}, and a table \sml{T}, \sml{insert f
   * (k, v) T} evaluates to $T \cup \{(k, v)\}$ provided that $k
   * \not\in_m T$; otherwise, if $(k, v') \in T$, it evaluates to
   * $(T\setminus\{(k, v')\}) \cup \{(k,f(v',v)\}\}$ (i.e., it
   * replaces the value associated with $k$ with the result of
   * applying $f$ on the old value $v'$ and the new value $v$).
   *)
  val insert : ('a * 'a -> 'a) -> (key * 'a) -> 'a table -> 'a table
  (* LATEX
   *
   * If \sml{k} is a value of type $\!\type{key}$ and \sml{T} is an
   * $\alpha \type{table}$, then \sml{delete k T} evaluates to $\{
   * (k', v') \in T : k' \neq k\}$.
   *)
  val delete : key -> 'a table -> 'a table

  (* LATEX
   *
   * If \sml{s} is a $\!\type{key} \times \alpha$ sequence such that \[ s
   * = \langle (k_1, v_1), (k_2, v_2), \dots (k_n, v_n) \rangle, \]
   * then \sml{fromSeq s} evaluates to $\{(k_1, v_1), (k_2, v_2),
   * \dots (k_n, v_n)\}$.
   *)
  val fromSeq : (key*'a) seq -> 'a table

  (* LATEX
   *
   * If \sml{T} is an $\alpha$ table representing $\{(k_1, v_1), (k_2,
   * v_2), \dots (k_n, v_n)\}$, then \sml{toSeq T} evaluates to
   * $\langle (k_1, v_1), (k_2, v_2), \dots (k_n, v_n) \rangle$, where
   * the ordering is determined by the implementation.
   *)
  val toSeq : 'a table -> (key*'a) seq

  (* LATEX
   *
   * This function groups values of the same key together as a
   * sequence of values that respects the original sequence ordering.
   * Specifically, if \sml{s} is a $\!\type{key} \times \alpha$
   * sequence representing $\langle (k_1, v_1), (k_2, v_2), \dots
   * (k_n, v_n) \rangle$, then \sml{collect s} evaluates to
   * $\{(\ell_1, s_1), (\ell_2, s_2), \dots, (\ell_m, s_m)\}$, where
   * the $\ell_i$'s are unique keys belonging to $\{k_1, \dots, k_n\}$
   * and for $i \in [m]$, $s_i$ is the sequence of values in $s$ with
   * the key $\ell_i$ (i.e., $s_i = \langle v_j : k_j =
   * \ell_i\rangle$).
   *)
  val collect : (key*'a) seq -> 'a seq table


  val toString : ('a -> string) -> 'a table -> string
end;
