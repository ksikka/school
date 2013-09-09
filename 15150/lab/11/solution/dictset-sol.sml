functor DictSet (D : DICT) : SET =
struct
  structure Element = D.Key
  type set = unit D.dict

  (* we represent the empty set as the empty dictionary *)
  val empty = D.empty

  (* Purpose: Insert an element into the set *)
  fun insert s v = D.insert s (v, ())

  (* Purpose: Remove an element from the set *)
  val remove = D.remove

  (* Purpose: Test of an element is in the set *)
  val member = fn d => ((fn SOME () => true | NONE => false) o (D.lookup d))
end

(* because everything is functorized, the best we can do for testing is to
   instantiate the functors and see if the functions behave according to
   spec. since member is the only function that produces a non-abstract
   type, we really have to trust that it's correct: our entire test suite
   relies on that fact.
*)
structure TestSet =
struct
  structure IntSet : SET = DictSet (TreeDict(IntLt))

  val l5 = List.tabulate (5, fn x => x)
  val is5 = List.foldl (fn (x, d) => IntSet.insert d x) IntSet.empty l5

  val true = IntSet.member is5 4
  val false = IntSet.member is5 5

  val is4 = IntSet.remove is5 3

  val false = IntSet.member is4 3
  val true = IntSet.member is4 1

  val is6 = IntSet.insert (IntSet.insert is4 5) 6

  val true = IntSet.member is6 5
  val true = IntSet.member is6 6

  val l10 = [4, 2, 8, 1, 9, 3, 5, 7, 0, 6]
  val is10 = List.foldl (fn (x, d) => IntSet.insert d x) IntSet.empty l10

  val true = IntSet.member is10 4
  val true = IntSet.member is10 5
  val false = IntSet.member is10 10

  val is9 = IntSet.remove is10 2

  val false = IntSet.member is9 2
  val true = IntSet.member is9 1
  val true = IntSet.member is9 3
  val true = IntSet.member is9 0
end
