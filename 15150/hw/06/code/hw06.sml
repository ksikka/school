use "lib.sml";

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
            let fun matchrstar cs = k cs orelse match r cs matchrstar
            in
                matchrstar cs
            end

      (* Task 2.1 *)
      | Wild => (case cs of 
                      [] => false
                    | c'::cs' => k cs' )
      (* Task 2.3 *)
      | Both (r1,r2) => match r1 cs (fn cs' => match r2 cs (fn cs'' =>
          charlisteq(cs',cs'') andalso (k cs') )) 

      (* Task 2.5 *)
      | Any =>
            let
              fun matchany cs' = (case cs' of [] => k cs' 
                                     | x::xs => k cs' orelse match r xs matchany)
            in
                matchany cs
            end

fun accept r s = match r (String.explode s) (fn [] => true | _ => false)

(* Tests for Wild *)
(* Test against the pattern "c_"  *)
val true  = accept (Times(Char(#"c"),Wild)) "cs"
val true  = accept (Times(Char(#"c"),Wild)) "cx"
val false = accept (Times(Char(#"c"),Wild)) "c"
val false = accept (Times(Char(#"c"),Wild)) "cxx"

(* Tests for Both (r1, r2) *)
val true = accept (Both(Times(Char(#"a"),Char(#"b")), Times(Char(#"a"),Wild))) "ab"
val false = accept (Both(Times(Char(#"a"),Char(#"b")), Times(Char(#"a"),Wild))) "ac"

(* Tests for Any (r1, r2) *)
val true = accept Any "l;skdjflskdj"
val true = accept (Times(Any,Char(#"z"))) "sdfsadfz"
val false = accept (Times(Any,Char(#"z"))) "sdfsadfb"

(* ------------------- Section 3: File Systems --------------------------- *)
(* Task 3.1 *)
(* Purpose: to compute the total size of all the files in the given fsobject
 *)
val totsize_reduce : fsobject -> int =
  fn fso => fsreduce (fn (contents,size) => size) 
    (fn t => mapreduce (fn (name,partsize) => partsize ) 0 op+ t) fso
(* Tests for totsize_reduce *)
val 3   = totsize_reduce  fsingle
val 0   = totsize_reduce  dirEmpty
val 11  = totsize_reduce  dir1
val 8   = totsize_reduce  dir2
val 271 = totsize_reduce  dir3
val 279 = totsize_reduce  root

(* Purpose: Collects all the filenames matching the given predicate along with
 * their absolute paths in a tree using fsreduce with mapreduce.
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
      fsreduce (fn _ => Empty) (fn t => mapreduce (fn (n,r) =>
        case_for_leaf(n,r)) Empty Node t)
    end
(* Tests for all_matches_reduce *) 
val errthang = (fn _ => true)
val mp3filter = accept (Times(Any,toRegexp(".mp3")))
val true = strPairTreeCmp ((all_matches_rec (errthang) root),(all_matches_reduce (errthang) root))
val true = strPairTreeCmp ((all_matches_rec (mp3filter)root),(all_matches_reduce (mp3filter) root))
val false = strPairTreeCmp ((all_matches_rec(mp3filter)root),(all_matches_reduce (errthang) root))


(* ------------------- Section 4: Recursion On Lists --------------------- *)
(* Purpose: A function with the same purpose as List.map, except it uses 
 * List.foldr in its implementation. *)
fun foldmap (f : 'a -> 'b) (l : 'a list) : 'b list =
    List.foldr (fn (x,xs) => (f x) :: xs) [] l

(* Tests for foldmap *)
val [2,4,6] = List.map (fn x => 2*x) [1,2,3]
val [2,4,6] = foldmap (fn x => 2*x) [1,2,3]

(* Purpose: A function which takes in a list, and returns the same list.
 * Uses List.foldr, so it runs in linear time. *)
fun foldid (l : 'a list) : 'a list =
    List.foldr (op ::) [] l

(* Tests for foldid *)
val [] = foldid []
val [1,2,3] = foldid [1,2,3]

(* Purpose: A function with the same purpose as List.filter, except it uses 
 * List.foldr in its implementation. *)
fun foldfilter (p : 'a -> bool) (l : 'a list) : 'a list =
    List.foldr (fn (x,xs) => case (p x) of true => x::xs | _ => xs) [] l

(* Tests for foldfilter *)
val [] = foldfilter (fn _ => true) []
val [1,2,3] = foldfilter (fn x => x<4) [1,2,3,4,5,6]
val [4,5,6] = foldfilter (fn x => x>3) [4,1,5,2,6,3]
val [] = List.filter (fn _ => true) []
val [1,2,3] = List.filter (fn x => x<4) [1,2,3,4,5,6]
val [4,5,6] = List.filter (fn x => x>3) [4,1,5,2,6,3]

(* Purpose: A function which takes a list of list of ints, 
 * and returns the product of the sums of the elements within the lists. *)
val prodofsum : int list list -> int = 
  (fn l => List.foldr (fn (x,y) => x*y) 1 (List.map (List.foldr (fn (x,y) => x+y) 0) l))
(* Tests for prodofsum *)
val 1 = prodofsum []
val 0 = prodofsum [[]]
val 0 = prodofsum[[],[1,2]]
val 18 = prodofsum [[1,2,3],[1,2]]

(* Purpose: Given a list of characters, returns a function which takes in a
 * character and returns the number of occurances and the total length. *)
val cntchar : char list -> char -> int * int = 
  fn (l) => 
    (fn c => 
      List.foldr 
        ( fn (c',result) => let val (occurances,length) = result
                            in case chareq(c,c') of 
                                 true => (1 + occurances,1 + length)
                              | false => (0 + occurances,1 + length)
                            end )
        (0,0) 
        l )
(* Tests for cntchar *)
val (0,0) = cntchar [] #"z"
val (2,5) = cntchar (explode "bible") #"b"
val (1,5) = cntchar (explode "bible") #"i"
val (0,5) = cntchar (explode "bible") #"z"
val foo = cntchar (explode "mississippi")
val (4,11) = foo #"s"
val (2,11) = foo #"p"

(* Purpose: Reverses its argument in time quadratic in its length. *)
fun foldrevslow (l : 'a list) : 'a list = 
  List.foldr (fn (x,result) => result@[x] ) nil l
(* Tests for foldrevslow *)
val [] = foldrevslow []
val [4,3,2,1] = foldrevslow [1,2,3,4]

(* Purpose: Reverses its argument in time linear in its length. *)
fun foldrevfast (l : 'a list) : 'a list =
  List.foldl (fn (z,result) => z::result ) nil l
(* Tests for foldrevfast *)
val [] = foldrevfast []
val [4,3,2,1] = foldrevfast [1,2,3,4]
