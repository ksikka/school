fun chareq (c,c') = case Char.compare (c,c') of EQUAL => true | _ => false

datatype regexp =
    Zero
  | One
  | Char of char
  | Times of regexp * regexp
  | Plus of regexp * regexp
  | Star of regexp

local 
fun match (r : regexp) (cs : char list) (k : char list -> bool) : bool = 
    case r of
        Zero => false
      | One => k cs
      | Char c => (case cs of
                       []  => false
                     | c' :: cs' => chareq (c,c') andalso k cs')
      | Plus (r1,r2) => match r1 cs k orelse match r2 cs k
      | Times (r1,r2) => match r1 cs (fn cs' => match r2 cs' k)
      | Star r => 
            let fun matchstar cs' = k cs' orelse match r cs' matchstar
            in 
                matchstar cs
            end
in
    fun accepts (r : regexp) (s : string) : bool = 
        match r (String.explode s) (fn [] => true | _ => false)
end

val true = accepts (Times (Plus(Char #"a",Char #"a") , Char #"b")) "ab"
val true = accepts (Times (Plus(Char #"b",Char #"a") , Char #"b")) "ab"
val true = accepts (Times (Char #"a",Plus(Char #"a",Char #"b"))) "ab"
val true = accepts (Star (Times (Char #"a", Char #"b"))) "ababab"
val false = accepts (Times (Plus(Char #"a",Char #"a") , Char #"a")) "ab"
val false = accepts (Times (Plus(Char #"b",Char #"c") , Char #"a")) "ab"
val false = accepts (Times (Char #"a",Plus(Char #"d",Char #"c"))) "ab"
val false = accepts (Char #"a") "ab"
val false = accepts (Times (Char #"a" , Char #"b")) "a"
val true = accepts (Times (Times(Char #"a",Char #"b") , Char #"c")) "abc"
val true = accepts (Times (Char #"a", Times(Char #"b",Char #"c"))) "abc"

fun oneplus r = Times (r, Star r)

fun test s = accepts (Times (oneplus (Times (oneplus (Char #"a"), 
                                             oneplus (Char #"a"))), 
                             Char #"b")) 
             s
(* test ((String.implode (List.tabulate (13, fn x => #"a")))); *)



(* "kleene algebra homomorphism" version, which uses 
   combinators corresponding to each syntactic construct

   this version is also staged: it processes the whole
   regular expression before it gets the string.  
 *)

local 
    type matcher = char list -> (char list -> bool) -> bool
    val FAIL : matcher = fn _ => fn _ => false
    val NULL : matcher = fn cs => fn k => k cs
    fun LITERALLY (c : char) : matcher = 
        fn cs => fn k => (case cs of
                              []  => false
                            | c' :: cs' => chareq(c, c') andalso k cs')
    infixr 8 OR
    infixr 9 THEN
    fun m1 OR m2 = fn cs => fn k => m1 cs k orelse m2 cs k
    fun m1 THEN m2 = fn cs => fn k => m1 cs (fn cs' => m2 cs' k)
    fun REPEATEDLY m = fn cs => fn k => 
        let fun repeat cs' = k cs' orelse m cs' repeat
        in
            repeat cs
        end

    fun match (r : regexp) : matcher =
        case r of
            Zero => FAIL
          | One => NULL 
          | Char c => LITERALLY c
          | Plus (r1,r2) => match r1 OR match r2
          | Times (r1,r2) => match r1 THEN match r2
          | Star r => REPEATEDLY (match r)
in
    fun accepts (r : regexp) : string -> bool = 
        let 
            val m = match r 
        in 
            fn s => m (String.explode s) (fn [] => true | _ => false) 
        end
end

val true = accepts (Times (Plus(Char #"a",Char #"a") , Char #"b")) "ab"
val true = accepts (Times (Plus(Char #"b",Char #"a") , Char #"b")) "ab"
val true = accepts (Times (Char #"a",Plus(Char #"a",Char #"b"))) "ab"
val true = accepts (Star (Times (Char #"a", Char #"b"))) "ababab"
val false = accepts (Times (Plus(Char #"a",Char #"a") , Char #"a")) "ab"
val false = accepts (Times (Plus(Char #"b",Char #"c") , Char #"a")) "ab"
val false = accepts (Times (Char #"a",Plus(Char #"d",Char #"c"))) "ab"
val false = accepts (Char #"a") "ab"
val false = accepts (Times (Char #"a" , Char #"b")) "a"
val true = accepts (Times (Times(Char #"a",Char #"b") , Char #"c")) "abc"
val true = accepts (Times (Char #"a", Times(Char #"b",Char #"c"))) "abc"
