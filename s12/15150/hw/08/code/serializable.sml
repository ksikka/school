(********** TASK 5.1 **********)
structure SerializeInt : SERIALIZABLE =
struct
  type t = int

  (* Given an int, returns the serialized string of the int 
   * which is of the form, #<string rep of int>.
   * Invariant: (write n) is 16 characters long. *)
  fun write (n : int) : string =
  let 
    val prefix : string = case n < 0 of true => "#~" | false => "#0"
    val intstr : string = Int.toString (Int.abs n)
    val length : int = String.size intstr
    fun zeroes (x : int) : string =
      case x of 
           0 => ""
         | _ => "0" ^ (zeroes (x-1))
    val zerostr : string = zeroes (14-length)
  in
    prefix ^ zerostr ^ intstr
  end

  (* Given a serialized int string, parses it and returns SOME int,remainder
   * by peeling off the # and parsing the next 15 characters. *)
  fun read (raw:string) =
    case Util.peelOff("#",raw) of
         NONE => NONE
       | SOME r => let
                     val intstr = String.extract(r,0,SOME 15)
                     val parsed = case Int.fromString intstr of NONE => 0 | SOME z => z
                     val theRest = String.extract(r,15,NONE)
                   in
                     SOME (parsed,theRest)
                   end
  (* TESTS *)
  val SOME(32429,"hello kitty") = read( write(32429) ^ "hello kitty" );
  val SOME(32429,"") = read( write(32429) ^ "" );
  val SOME(~32429,"") = read( write(~32429) ^ "" );
  val SOME(0,"#testing") = read( write(0) ^ "#testing" );
end


(********** TASK 5.2 **********)
functor SerializePair (P : SERIALIZABLEPAIR) : SERIALIZABLE =
struct
  type t = (P.S1.t * P.S2.t)

  (* Given an pair (p1,p2), returns the serialized string of the pair 
   * which is of the form <encoded p1>@<encoded p2> *)
  fun write (t1,t2) : string =
  let 
    val str1 = P.S1.write t1
    val str2 = P.S2.write t2
  in
    str1 ^ str2
  end

  (* Given a serialized pair string, parses it and returns SOME pair,remainder 
   * by parsing for the first element, then for the second element *)
  fun read (r1 : string) =
  let
    val (s1,r2) = Option.valOf (P.S1.read r1)
    val (s2,r3) = Option.valOf (P.S2.read r2)
  in SOME ((s1,s2),r3) 
  end
  (* TESTS after 5.4*)
end


(********** TASK 5.3 **********)
functor SerializeList (S : SERIALIZABLE) : SERIALIZABLE =
struct
  type t = S.t list

  (* Given an list, returns the serialized string of the list 
   * in the form of <length toString>@<x1>@<x2>@...@<x_length>*)
  fun write (l1 : S.t list) : string =
  let
    val length = List.length l1
    fun w (l2 : S.t list) =
      case l2 of
           [] => ""
         | x::xs => (S.write x) ^ (w xs)
    in
      (SerializeInt.write length) ^ (w l1)
  end

  (* Given a serialized list string, parses it and returns SOME list,remainder
   * by first parsing the length, then recursively parsing until length = 0. *)
  fun read (raw : string) = 
  let
    val (length,r1) = Option.valOf (SerializeInt.read raw)
    fun r (str : string, i : int) : S.t list * string = 
      case i of 
           0 => ([],str)
         | _ => let
                  val (a,z) = Option.valOf (S.read str)
                  val (b,y) = r (z,i-1)
                in 
                  (a::b,y)
                end
  in
    SOME (r (r1,length))
  end
  (* TESTS after 5.4*)
end

(********** TASK 5.4 **********)
structure ILL = SerializeList( SerializeList( SerializeInt ) )
val SOME ([[1,2,3],[4],[],[5,6,7,8,9],[10],[]],"#messing around") =
  ILL.read ((ILL. write [[1,2,3],[4],[],[5,6,7,8,9],[10],[]])^"#messing around")
structure ILSB = SerializePair(
                   struct
                     structure S1 = SerializeList( SerializeInt )
                     structure S2 = SerializeBool
                   end)
structure ISBL = SerializeList(
                   SerializePair(
                     struct
                       structure S1 = SerializeInt
                       structure S2 = SerializeBool
                     end))
structure ISBLL = SerializePair(
                   struct
                     structure S1 = SerializeInt
                     structure S2 = SerializeList( SerializeBool )
                   end)
val SOME ((~23423324,[true,true,true,false,false]),"#m3$$ing 4r0un6") =
  ISBLL.read ((ISBLL.write (~23423324,[true,true,true,false,false])) ^ "#m3$$ing 4r0un6")

(********** TASK 5.5 -- extra credit! **********)
structure SerializeString : SERIALIZABLE = 
struct
  type t = string

  (* Given an string, returns the serialized string of the string 
   * in the form of <serialized length>@<str>*)
  fun write (str : string) : string =
  let
    val length = String.size str
  in
    (SerializeInt.write length) ^ str
  end

  (* Given a serialized string, parses it and returns SOME string,remainder
   * by first parsing the length and then extracting the string. *)
  fun read (r1 : string) =
  let
    val (length,r2) = Option.valOf (SerializeInt.read r1)
    val (str,r3) = (String.extract(r2,0,SOME length),String.extract(r2,length,NONE))
  in
    SOME (str,r3)
  end
end
