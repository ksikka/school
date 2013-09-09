signature PRIORITY_QUEUE =
sig
  (* LATEX
   *
   * This is the abstract type for priority queues.
   *)
  structure Key : ORDERED

  (* LATEX
   *
   * This indicates that the type of keys in a priority queue has to have type
   * $\!\type{key}$.
   *)
  type key = Key.t

  (* LATEX
   *
   * This is the abstract type representing a priority queue with key type
   * $\!\type{key}$ (see below) and value type $\alpha$.
   *)
  type 'a pq
  type 'a t = 'a pq

  (* LATEX
   *
   * \sml{empty} represents the empty collection $\emptyset$.
   *)
  val empty   : unit -> 'a pq

  (* LATEX
   *
   * Returns true if the priority queue is empty.
   *)
  val isEmpty : 'a pq -> bool

  (* LATEX
   *
   * If \sml{k} is a value of type $\!\type{key}$ and \sml{v} is a
   * value of type $\alpha$, the expression \sml{singleton (k,v)}
   * evaluates to the priority queue including just $\{(k,v)\}$.
   *)
  val singleton : key * 'a -> 'a pq

  (* LATEX
   *
   * For a a key-value pair \sml{(k, v)}, and a priority queue \sml{Q},
   * \sml{insert (k, v) Q} evaluates to $Q \cup \{(k, v)\}$.  Since the
   * priority queue is treated as a multiset, duplicate keys or key-value
   * pairs are allowed and kept separately.
   *)
  val insert : (key*'a) -> 'a pq -> 'a pq

  (* LATEX
   *
   * Takes the union of two priority queues.  Since the priority queue
   * is treated as a multiset, duplicate keys or key-value pairs are 
   * allowed and kept.  Therefore the size of the result will be the sum
   * of the sizes of the inputs.
   *)
  val meld      : 'a pq -> 'a pq -> 'a pq

  (* LATEX
   *
   * Given a priority queue \sml{findMin Q} if $Q$ is empty, it returns 
   * NONE.   Otherwise it returns \sml{SOME(k,v)} where $(k,v) \in Q$ 
   * and $k$ is the key of minimum value in $Q$.  If multiple elements 
   * have the same minimum valued key, then an arbitrary one is returned. 
   *)
  val findMin   : 'a pq -> (key*'a) option

  (* LATEX
   *
   * This is the same as \sml{findMin} but also returns a priority queue
   * with the returned (key,value) pair removed (if the input queue is
   * non-empty) or an empty Q (if the input queue is empty).
   *)
  val deleteMin : 'a pq -> (key*'a) option * 'a pq
end
