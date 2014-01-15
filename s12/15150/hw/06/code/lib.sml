fun chareq (c,c') = case Char.compare (c,c') of EQUAL => true | _ => false

fun charlisteq (cs, cs') = case List.collate Char.compare (cs, cs') of
                               EQUAL => true | _ => false

datatype regexp =
    Zero
  | One
  | Char of char
  | Times of regexp * regexp
  | Plus of regexp * regexp
  | Star of regexp
  | Wild
  | Both of regexp * regexp
  | Any

datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of 'a tree * 'a tree

datatype fsobject =
    File of string * int
  | Dir of (string * fsobject) tree

fun treemap (f : 'a -> 'b) (t : 'a tree) : 'b tree =
    case t of
        Empty => Empty
      | Leaf x => Leaf (f x)
      | Node (l, r) => Node (treemap f l, treemap f r)

val printleaves = fn (f : 'a -> string) => treemap (fn x => print (f x ^ "\n"))

fun treeall (p : 'a -> bool) (t : 'a tree) : bool =
    case t of
        Empty => true
      | Leaf x => p x
      | Node (l, r) => treeall p l andalso treeall p r

fun mapreduce (f : 'a -> 'b) (e : 'b) (n : 'b * 'b -> 'b) (t : 'a tree) : 'b =
    case t of
        Leaf x => f x
      | Empty => e
      | Node (l, r) => n (mapreduce f e n l, mapreduce f e n r)

fun size (t : 'a tree) : int =
   mapreduce (fn _ => 1) 0 (op+) t

(* ---------------------------------------------------------------------- *)
(* Functions for testing all_matches_rec/reduce *)

(* Purpose: Count the number of leaves of the tree *)
fun num_leaves (t : 'a tree) : int = mapreduce (fn _ : 'a => 1) 0 op+ t

(* Purpose: Count the number of leaves for which the given predicate, p,
 * returns true. *)
fun cnt_matches (p : 'a -> bool) : 'a tree -> int =
    mapreduce (fn x : 'a => (case p x of true => 1 | _ => 0)) 0 op+

(* Purpose: Test if two trees have the same multiset of leaves using the given
 * function to test equality. *)
fun same_leaves (cmp : 'a -> 'a -> bool) (t1 : 'a tree, t2 : 'a tree) : bool =
    let
      val same_leaf =
          fn x =>
             let
               val match = cmp x
             in
               case Int.compare (cnt_matches match t1, cnt_matches match t2) of
                   EQUAL => true
                 | _ => false
             end
    in
      case Int.compare (num_leaves t1, num_leaves t2) of
          EQUAL => treeall same_leaf t1
        | _ => false
    end

val int_t1 = Node (Node (Leaf 7, Leaf 4), Leaf 7)
val int_t2 = Node (Node (Leaf 7, Leaf 7), Leaf 4)
val int_t3 = Node (Node (Leaf 4, Leaf 4), Leaf 7)

val matchInt = fn x => fn y => (case Int.compare (x, y) of EQUAL => true
                                                           | _ => false)

val true = same_leaves matchInt (Empty, Empty)
val true = same_leaves matchInt (int_t1, int_t2)
val false = same_leaves matchInt (int_t1, int_t3)
val false = same_leaves matchInt (int_t2, int_t3)

fun matchPair (f : 'a -> 'a -> bool) (g : 'b -> 'b -> bool)
              ((x1, y1) : 'a * 'b) ((x2, y2) : 'a * 'b) : bool =
    (f x1 x2) andalso (g y1 y2)

val matchStrPair : (string * string) -> (string * string) -> bool =
    let
      val strMatch = fn s1 => fn s2 => (case String.compare (s1, s2) of
                                            EQUAL => true
                                          | _ => false)
    in
      matchPair strMatch strMatch
    end

val strPairTreeCmp : (string * string) tree * (string * string) tree -> bool =
    same_leaves matchStrPair

(* Purpose: Divides the argument list into two lists.  One of which has all
 * of the elements with even indices, and the other has all of the elements
 * with odd indices.
 *)
fun split (l : 'a list) : 'a list * 'a list =
    case l of
        nil => (nil, nil)
      | [x] => ([x], nil)
      | x1::x2::xs =>
        let
          val (l1, l2) = split xs
        in
          (x1::l1, x2::l2)
        end

val ([1,3], [2,4]) = split [1,2,3,4]
val (["a","c","e"], ["b","d"]) = split ["a","b","c","d","e"]

(* Purpose: Generate a tree with exactly the same elements as the given list.
 * The relative order of elements may change.
 *)
fun balancedFromList (l : 'a list) : 'a tree =
    case l of
        nil => Empty
      | [x] => Leaf x
      | _ =>
        let
          val (l1, l2) = split l
        in
          Node (balancedFromList l1, balancedFromList l2)
        end

val Empty = balancedFromList nil
val Leaf 3 = balancedFromList [3]
val Node (Node (Leaf 1, Leaf 3), Leaf 2) = balancedFromList [1,2,3]


(* fsreduce *)
fun fsreduce (f : (string * int) -> 'a)
             (g : (string * 'a) tree -> 'a)
             (fso : fsobject) : 'a =
    case fso of
        Dir t => g (treemap (fn (s, fso') => (s, fsreduce f g fso')) t)
      | File (ctnts, sz) => f (ctnts, sz)

(* Values for testing *)
val fsingle = File ("single nameless file", 3)
val dirEmpty = Dir Empty

val t1 = Node (Leaf ("a.sml", File ("()", 3)),
               Leaf ("b.txt", File ("content", 8)))
val dir1 = Dir t1
val t2 = Node (Leaf ("c.sml", File ("2", 2)),
               Leaf ("a.txt", File ("stuff", 6)))
val dir2 = Dir t2
val t3 = Node (Node (Leaf ("e.mp3", File ("music", 256)),
                     Leaf ("b.sml", File ("nil", 4))),
               Leaf ("dir1.sml", dir1))

val dir3 = Dir t3
val root = Dir (Node (Leaf ("dir2", dir2),
                      Leaf ("dir3", dir3)))

local
  fun charsToRegexp (l : char list) =
      case l of
          nil => One
        | c::cs => Times (Char c, charsToRegexp cs)
in
  val toRegexp = charsToRegexp o String.explode
end

val starsml = Times (Any, toRegexp ".sml")
val starmp3 = Times (Any, toRegexp ".mp3")
val starc = Times (Any, toRegexp ".c")

(* ---------------------------------------------------------------------- *)
(* Provided example of converting a recursive function to fsreduce using
 * mapreduce. *)

(* Purpose: Recursive function for computing the number of names in the
 * given fsobject that match the given predicate.
 *)
fun count_rec (match : string -> bool) (fso : fsobject) : int =
    let
      val case_for_leaf = fn (name : string, subcount : int) =>
          subcount + (case match name of
                          true => 1
                        | false => 0)
    in
      case fso of
          File _ => 0
        | Dir t =>
              let fun loop t =
                  case t of
                      Node (t1, t2) => loop t1 + loop t2
                    | Leaf (n, fso') => case_for_leaf (n, count_rec match fso')
                    | Empty => 0
              in
                  loop t
              end
    end

(* Purpose: Computes the number of names in the given fsobject that match
 * the given predicate using fsreduce with mapreduce.
 *)
val count_reduce : (string -> bool) -> (fsobject -> int) =
  fn match =>
    let
      val case_for_leaf = fn (name : string, subcount : int) =>
          subcount + (case match name of
                          true => 1
                        | false => 0)
    in
      fsreduce (fn _ => 0) (mapreduce case_for_leaf 0 op+)
    end

(* Purpose: Recursive function for computing the total size of files in the
 * given fsobject.
 *)
fun totsize_rec (fso : fsobject) : int =
    case fso of
        File (_, sz) => sz
      | Dir t =>
            let fun loop t =
                case t of
                    Node (t1,t2) => loop t1 + loop t2
                  | Leaf (_ , fso') => totsize_rec fso'
                  | Empty => 0
            in
                loop t
            end

(* Tests for totsize_rec *)
val 0 = totsize_rec dirEmpty
val 3 = totsize_rec fsingle
val 279 = totsize_rec root

(* ---------------------------------------------------------------------- *)
(* Purpose: Recursive function for collecting all the filenames and their
 * absolute paths matching the given predicate in a tree.
 *)
fun all_matches_rec (match : string -> bool) (fso : fsobject)
    : (string * string) tree =
    let
      fun case_for_leaf (name : string, t' : (string * string) tree)
          : (string * string) tree =
          let
            val submatches =
                treemap (fn (name', path) => (name', "/" ^ name ^ path)) t'
          in
            case match name of
                true => Node (Leaf (name, "/" ^ name), submatches)
              | false => submatches
          end
    in
      case fso of
          File _ => Empty
        | Dir t =>
              let fun loop t =
                  case t of
                      Node (t1, t2) => Node (loop t1, loop t2)
                    | Leaf (n, fso') =>
                          case_for_leaf (n, all_matches_rec match fso')
                    | Empty => Empty
              in
                  loop t
              end
    end
