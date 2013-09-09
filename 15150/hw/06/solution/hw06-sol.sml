use "../code/lib.sml";

(* ---------------- Section 2: Regular Expressions ----------------------- *)
fun match (r : regexp) (cs : char list) (k : char list -> bool) : bool =
    case r of
        Zero => false
      | One => k cs
      | Char c => (case cs of
                       []  => false
                     | c' :: cs' => chareq(c,c') andalso k cs')
      | Plus (r1,r2) => match r1 cs k orelse match r2 cs k
      | Times (r1,r2) => match r1 cs (fn cs' => match r2 cs' k)
      | Star r =>
            let
              fun matchrstar cs = k cs orelse match r cs matchrstar
            in
              matchrstar cs
            end
      (* Task 2.1 *)
      | Wild =>
        (case cs of
           nil => false
         | _::cs' => k cs')
      (* Task 2.3 *)
      | Both (r1,r2) =>
        match r1 cs
              (fn s => match r2 cs
                             (fn s' => charlisteq (s,s') andalso k s'))
      (* Task 2.5 *)
      | Any =>
            let
              fun matchany cs' =
                  case cs'
                   of [] => k []
                    | _::cs'' => k cs' orelse matchany cs''
            in
                matchany cs
            end

fun accept r s = match r (String.explode s) (fn [] => true | _ => false)

(* tests *)
local
  fun star1 r = Times(r, Star r)
  fun cat rs = foldr (fn (x,y) => Times (x,y)) One rs
  fun lit s = cat (map Char (String.explode s))

  val ra = Char #"a"
  val rb = Char #"b"
  val rc = Char #"c"
  val rab = Times(ra, rb)
  val rba = Times(rb, ra)
  val raorb = Plus(ra,rb)
  val rwild = Plus(raorb, rc)
  val rany = Star(rwild)

  (* list cross product *)
  fun cross [] _ = []
    | cross (x::xs) L = List.map (fn y => (x,y)) L @ cross xs L

  (* whole mess of test cases *)
  val rs_strs : (string list * regexp list) list =
      [ (["", "a"], [One, Zero])
      , (["", "a", "b", "q", "ab"], [ra, rb, raorb])
      , (["ababab", "abbabaab", "aba"],
         [rany, Star raorb, Star rab, star1 (cat [star1 ra, star1 rb])])
      , (["ab", "accccccb"], [ cat [ra, rany, rb],
                               cat [ra, Star rc, rc, rc, rb] ]) ]

  (* get the tests cases ready for match *)
  val ready = List.concat (map (fn (strs,rs) => cross rs strs) rs_strs)

  (* run accept *)
  val res = List.map (fn (r,s) => accept r s) ready

  (* test against known answers *)
  val [true,false,false,false,false,true,false,false,false,false,false,true,
       false, false,false,true,true,false,false,true,true,true,true,true,
       true,true,false,false,true,true,false,true,true,false,true] =  res
in
  (* nothing *)
end



(* ------------------- Section 3: File Systems --------------------------- *)
(* Task 3.1 *)
(* Purpose: Non-recursive function for computing the total size of files in the
 * given fsobject using fsreduce.
 *)
val totsize_reduce : fsobject -> int =
    fsreduce (fn (_, sz) => sz) (mapreduce  (fn (_, subsz) => subsz) 0 op+)

(* Tests for totsize_reduce *)
val 0 = totsize_reduce dirEmpty
val 3 = totsize_reduce fsingle
val 279 = totsize_reduce root

(* Purpose: Collects all the filenames matching the given predicate along with
 * their asolute paths in a tree using fsreduce with mapreduce.
 *)
val all_matches_reduce : (string -> bool) ->
                         (fsobject -> (string * string) tree) =
  fn match : string -> bool =>
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
      (* Task 3.2 *)
      fsreduce (fn _ => Empty) (mapreduce case_for_leaf Empty Node)
    end

(* Tests for all_matches_reduce *)
val lresult = [("a.sml", "/dir3/dir1.sml/a.sml"),
               ("c.sml", "/dir2/c.sml"),
               ("b.sml", "/dir3/b.sml"),
               ("dir1.sml", "/dir3/dir1.sml")]

val tresult = balancedFromList lresult

val tredsml = all_matches_reduce (accept starsml) root
val _ = printleaves (fn (s1, s2) => s1 ^ ": " ^ s2) tredsml
val true = strPairTreeCmp (tredsml, tresult)
val true = strPairTreeCmp (all_matches_reduce (accept starc) root, Empty)
val true = strPairTreeCmp (all_matches_reduce (accept Any) fsingle, Empty)
val true = strPairTreeCmp (all_matches_reduce (accept Any) dirEmpty, Empty)
val true = strPairTreeCmp (all_matches_reduce (accept starmp3) root,
                           Leaf ("e.mp3", "/dir3/e.mp3"))

(* ------------------- Section 4: Recursion On Lists --------------------- *)

(* purpose: applies a function to every element of a list of arguments to
 * produce a list of results
 *)
fun foldmap (f : 'a -> 'b) =
    foldr (fn (a,b) => (f a) :: b) []

val true = charlisteq(foldmap (fn x => #"a") [],
                      List.map (fn x => #"a") [])
val true = charlisteq(foldmap (fn x => #"a") [9,9,5],
                      List.map (fn x => #"a") [9,9,5])

(* Purpose: the identity function for lists *)
fun foldid (l : 'a list) : 'a list =
    foldr op:: [] l

val [1,2,3] = foldid [1,2,3]
val [] = foldid []
val ["a", "b", "c"] = foldid ["a", "b", "c"]

(* Purpose: given a predicate p and list l, evaluates to a list of all the
 * elements of l for which p holds in their original order
 *)
fun foldfilter (p : 'a -> bool) (l : 'a list) : 'a list =
    foldr (fn (a,b) => case p a
                        of true => a::b
                         | _ => b) [] l

val [] = foldfilter (fn x => false) [1,~4,9,0]
val [1,~4,9,0] = foldfilter (fn x => true) [1,~4,9,0]
val [1,9] = foldfilter (fn x => x > 0) [1,~4,9,0]

(* Purpose: computes the product of the sums of a list of lists of integers *)
val prodofsum : int list list -> int = (foldr op* 1) o (map (foldr op+ 0))

val 0 = prodofsum [[],[2,1,4],[9],[500]]
val 0 = prodofsum [[2,1,4],[9],[],[500]]
val 31500 = prodofsum [[2,1,4],[9],[500]]

(* Purpose: f there are n characters in a list of characters l and a
 * particular character c appears in the list k times, then cntchar l c ==
 * (k,n).
*)
fun cntchar (l : char list) (target : char) : int * int =
    foldr (fn (c , (targets, total)) =>
              case Char.compare (c,target)
               of EQUAL => (targets + 1, total + 1)
                | _ => (targets, total+1))
          (0,0) l

val (2,5) = cntchar (explode "curry") #"r"
val (0,6) = cntchar (explode "howard") #"z"
val (0,0) = cntchar [] #"a"

(* Purpose: computes the reverse of a list (in quadratic time) *)
fun foldrevslow (l : 'a list) : 'a list = foldr (fn (a,b) => b@[a]) [] l

val [] = foldrevslow []
val [2,1] = foldrevslow [1,2]
val ["a", "b", "c"] = foldrevslow ["c", "b", "a"]

(* Purpose: computes the reverse of a list (in linear time) *)
fun foldrevfast (l : 'a list) : 'a list = foldl op:: [] l

val [] = foldrevfast []
val [2,1] = foldrevfast [1,2]
val ["a", "b", "c"] = foldrevfast ["c", "b", "a"]


