
val true = CM.make("sources.cm");

val map = Seq.map

fun inteq(x,y) = case Int.compare (x,y) of EQUAL => true | _ => false
fun stringeq(x,y) = case String.compare (x,y) of EQUAL => true | _ => false

(* USE THESE FOR TESTING ONLY ! *)
fun seqFromList (l : 'a list) : 'a Seq.seq =
    List.foldr (fn (x,y) => Seq.cons x y) (Seq.empty ()) l
fun seqToList   (s : 'a Seq.seq) : 'a list =
    Seq.mapreduce (fn x => [x]) [] (op@) s

fun oddP (n : int) = inteq(n mod 2, 1)

fun seqFromList2 (l : 'a list list) : 'a Seq.seq Seq.seq =
    seqFromList (List.map seqFromList l)
fun seqToList2 (l : 'a Seq.seq Seq.seq) : 'a list list =
    seqToList (Seq.map seqToList l)

(* ---------------------------------------------------------------------- *)

(* Task 4.1 *)

(* Evaluates to true iff. f a == true for some a in given sequence *)
fun seqExists (f : 'a -> bool) : 'a Seq.seq -> bool =
    Seq.mapreduce f false (fn (b1, b2) => b1 orelse b2)

val true  = seqExists oddP (seqFromList [1,2,3])
val false = seqExists oddP (seqFromList [2,4,6])

(* ---------------------------------------------------------------------- *)

(* Task 5.1 *)

(* Evaluates to s1@s2 in O(n+m) work and O(1) span *)
fun myAppend (s1 : 'a Seq.seq, s2 : 'a Seq.seq) : 'a Seq.seq =
    Seq.tabulate (fn i => (case i < Seq.length s1 of
                     true => Seq.nth i s1
                   | false => Seq.nth (i - (Seq.length s1)) s2))
                 (Seq.length s1 + Seq.length s2)

val [1,2,3] = seqToList (myAppend (seqFromList [], seqFromList [1,2,3]))
val [1,2,3,4,5,6] = seqToList (myAppend (seqFromList [1,2,3], seqFromList [4,5,6]))
val [1,2,3] = seqToList (myAppend (seqFromList [1,2,3], seqFromList []))

(* Task 5.2 *)

(* assumes s is valid:
   rectangular n x m where n,m >= 0
   Transposes s in O(n+m) work and O(1) span *)
fun transpose (s : 'a Seq.seq Seq.seq) : 'a Seq.seq Seq.seq =
    let
      val originalrows = Seq.length s
      val originalcols = Seq.length (Seq.nth 0 s)
    in
      Seq.tabulate (fn j => Seq.tabulate (fn i => Seq.nth j (Seq.nth i s))
                                         originalrows)
                   originalcols
    end

val [[1],[2],[3]] = seqToList2 (transpose (seqFromList2 [[1,2,3]]))
val [[1,4],[2,5],[3,6]] = seqToList2 (transpose (seqFromList2 [[1,2,3],[4,5,6]]))

(* ---------------------------------------------------------------------- *)

(* Helpers *)

(* Compute a sequence of all the words (separated by spaces)
   in the given string *)
val words : string -> string Seq.seq =
    seqFromList o (String.tokens (fn s => s = #" "))

(* Converts a bool to either 1 for true or 0 for false *)
fun boolToInt b = case b of true => 1 | false => 0

(* Determine if the given int is 1 *)
fun isOne n = case n of 1 => true | _ => false

val theWWW = seqFromList [
    "Ethers are a class of organic compounds that contain an ether group -- an "
  ^ "oxygen atom connected to two alkyl or aryl groups -- of general formula R–O–R'.",
    "Elvis Aaron Presley (January 8, 1935 – August 16, 1977) was one of the most "
  ^ "popular American singers of the 20th century. A cultural icon, he is widely "
  ^ "known by the single name elvis. Born in Tupelo, Mississippi, Presley moved to "
  ^ "Memphis, Tennessee, with his family at the age of 13. He began his career "
  ^ "there in 1954 when Sun Records owner Sam Phillips, eager to bring the sound "
  ^ "of African-American music to a wider audience, saw in Presley the means to "
  ^ "realize his ambition.",
    "hI thEres do you livEs at three maiN streEt?",
    "Doctor Who is a British science fiction television programme produced by the "
  ^ "BBC. The programme depicts the adventures of a time-travelling humanoid alien "
  ^ "known as the doctorwho explores the universe in a sentient time machine "
  ^ "called the TARDIS that flies through time and space, whose exterior appears "
  ^ "as a blue police box. Along with a succession of companions, he faces a "
  ^ "variety of foes while working to save civilisations, help people, "
  ^ "and right wrongs.",
    "The series is a spin-off from Davies's 2005 revival of the long-running "
  ^ "science fiction programme Doctor Who . The show has shifted its broadcast "
  ^ "channel each series to reflect its growing audience, moving from BBC Three "
  ^ "to BBC Two to BBC One, and acquiring US financing in its fourth series. In "
  ^ "contrast to Doctor Who, whose target audience includes both adults and "
  ^ "children, torchwood is aimed at an older audience."]

(* Task 6.1 *)
(* return true if both words occur in the sequence, or false otherwise
   assumes the input is a sequence of words!
   *)
fun bothHit (word1 : string, word2 : string) : string Seq.seq -> bool =
    fn wordsInPage => seqExists (fn w => stringeq(w,word1)) wordsInPage
                      andalso
                      seqExists (fn w => stringeq(w,word2)) wordsInPage

val true = bothHit ("hi", "there") (words "hi there how are you")
val false = bothHit ("hi", "there") (words "hi how are you")

(* Task 6.2 *)
(* generate the sequence of websites that contain both words *)
fun searchBoth (word1 : string, word2 : string)
    : string Seq.seq -> string Seq.seq =
    Seq.filter (bothHit (word1, word2) o words)

val 2 = Seq.length (searchBoth ("Doctor","Who") theWWW)
val 1 = Seq.length (searchBoth ("Elvis","Records") theWWW)

(* Task 6.3 *)
(* count the number of websites that contain both words *)

(* Some simple solutions which require multiple passes *)
val sum : int Seq.seq -> int = Seq.reduce op+ 0
fun countBoth (word1 : string, word2 : string) : string Seq.seq -> int =
    sum o (Seq.map (boolToInt o bothHit (word1,word2) o words))

val 2 = countBoth ("Doctor","Who") theWWW

fun countBoth (word1 : string, word2 : string) : string Seq.seq -> int =
    Seq.length o searchBoth (word1,word2)

val 2 = countBoth ("Doctor","Who") theWWW

(* A more insightful solution which requires just one pass! *)
fun countBoth (word1 : string, word2 : string) : string Seq.seq -> int =
    Seq.mapreduce (boolToInt o bothHit (word1,word2) o words) 0 op+

val 2 = countBoth ("Doctor","Who") theWWW

(* Task 6.4 *)
(* Determine if the given pair of ints appears together exactly once *)
fun whack (word1 : string, word2 : string) : string Seq.seq -> bool =
    isOne o countBoth (word1 , word2)

(* Test for whack *)
val true = whack ("torchwood", "programme") theWWW
val false = whack ("Doctor", "Who") theWWW

(* Task 6.5 *)

(* Evaluates to the sequence of all tuples formed by selecting
   one element of s1 and another from s2 *)
fun allpairs (s1 : 'a Seq.seq, s2 : 'b Seq.seq) : ('a * 'b) Seq.seq =
    Seq.flatten (Seq.map (fn x => (Seq.map (fn y => (x,y)) s2)) s1)

(* Evaluates to the sequence of all Google Whacks in www *)
fun allWhacks (www : string Seq.seq) : (string * string) Seq.seq =
    let
      val allwords = (Seq.flatten (Seq.map words theWWW))
      val pairsToCheck =
          Seq.filter (not o stringeq) (allpairs (allwords,allwords))
    in
        Seq.filter (fn (w1,w2) => whack(w1,w2) theWWW) pairsToCheck
    end

