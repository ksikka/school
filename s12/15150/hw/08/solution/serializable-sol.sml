(********** TASK 5.1 **********)
structure SerializeInt : SERIALIZABLE =
struct
    type t = int

    (* purpose:
     *
     * write i evaluates to a string representation of i
     *)
    fun write i = "(" ^ Int.toString i ^ ")"

    (* purpose:
     *
     * read s evaluates to the digit represented by s and the rest of s,
     * possibly empty. we assume that read will only be applied to string
     * representations of ints created with the above write function.
     *)
    fun read s =
        case Util.peelOff ("(",s) of
            SOME s => (case Util.peelInt s
                        of SOME (i , s) =>
                           (case Util.peelOff (")",s)
                             of SOME s => SOME (i , s)
                              | NONE => NONE)
                         | NONE => NONE)
          | NONE => NONE
end

(********** TASK 5.2 **********)
functor SerializePair (P : SERIALIZABLEPAIR) : SERIALIZABLE =
struct
    type t = P.S1.t * P.S2.t

    (* purpose:
     *
     * write (x,y) evaluates to a string representation of (x,y)
     *)
    fun write (x,y) = (P.S1.write x) ^ P.S2.write y

    (* purpose:
     *
     * read s parses a pair from the string representation written above
     *)
    fun read (s : string) : (t * string) option  =
        (case P.S1.read s
             of SOME (x , s) =>
                 (case P.S2.read s of
                      SOME (y , s) => SOME((x,y),s)
                    | NONE => NONE)
           | NONE => NONE)
end

(********** TASK 5.3 **********)
functor SerializeList (S : SERIALIZABLE) : SERIALIZABLE =
struct
    type t = S.t list

    (* purpose:
     *
     * write l evaluates to a string representation of l
     *)
    fun write l =
        case l
         of [] => "(NIL)"
          | x :: xs => "(CONS " ^ (S.write x) ^ " " ^ write xs ^ ")"

    (* purpose:
     *
     * read s evaluates to the list represented by s and the rest of s,
     * possibly empty. we assume that read will only be applied to string
     * representations of lists created with the above write function.
     *)
    fun read (s : string) : (S.t list * string) option  =
        case Util.peelOff("(NIL)",s) of
            SOME s => SOME ([] , s)
          | NONE =>
                (case (Util.peelOff ("(CONS " , s))
                  of SOME s =>
                     (case S.read s
                       of SOME (x , s) =>
                          (case Util.peelOff(" ",s)
                            of SOME s =>
                               (case read s
                                 of SOME (xs , s) =>
                                    (case Util.peelOff (")" , s)
                                      of SOME s => (SOME (x :: xs, s))
                                       | NONE => NONE)
                                  | NONE => NONE)
                             | NONE => NONE)
                        | NONE => NONE)
                   | NONE => NONE)

    (* here's a monadic version of the same code *)
    val RETURN = SOME
    infix 8 THEN
    fun (x : 'a option) THEN (f : 'a -> 'b option)
      : 'b option =
        case x of
            NONE => NONE
          | SOME v => f v

    fun read (s : string) : (S.t list * string) option  =
        case Util.peelOff("(NIL)",s) of
            SOME s => SOME ([] , s)
          | NONE =>
                (Util.peelOff ("(CONS " , s)) THEN (fn s =>
                S.read s                      THEN (fn (x , s) =>
                Util.peelOff(" ",s)           THEN (fn s =>
                read s                        THEN (fn (xs , s) =>
                Util.peelOff (")" , s)        THEN (fn s =>
                RETURN (x :: xs, s))))))
end

(********** TASK 5.3 **********)
functor SerializeListLen (S : SERIALIZABLE) : SERIALIZABLE =
struct
    type t = S.t list

    fun ocase f x =
        case x
         of SOME v => f v
          | NONE => NONE

    fun ocons (x,y) = ocase (fn (l,v) => SOME(x::l,v)) y

    fun write l =
        (SerializeInt.write (length l)) ^
        (foldr (fn (a,b) => (S.write a) ^ b) "" l)

    (* read the int, use it to control the recursion and call S.read that
       many times. This version is very explicit about the case statements.
     *)
    fun read_verbose s =
        let
          fun recons (n : int, s : string) =
              case n
               of 0 => SOME([],s)
                | _ =>
                  (case S.read s
                    of SOME(elem,rest) =>
                       (case recons (n-1, rest)
                         of SOME (l,last) => SOME (elem :: l, last)
                          | NONE => NONE)
                     | NONE => NONE)
        in
            case SerializeInt.read s
             of SOME x => recons x
              | NONE => NONE
        end

    (* same idea but with the common case-statements factored out. *)
    fun read s =
        let
          fun recons (n : int, s : string) =
              case n
               of 0 => SOME([], s)
                | _ => ocase
                           (fn (elem,rest) => ocons(elem, recons (n-1, rest)))
                           (S.read s)
        in
          ocase recons (SerializeInt.read s)
        end
end

(********** TASK 5.4 **********)

structure ILL : SERIALIZABLE = SerializeList(SerializeList(SerializeInt))
structure ILSB : SERIALIZABLE = SerializePair(struct
                                                structure S1=SerializeList(SerializeInt)
                                                structure S2=SerializeBool
                                               end)
structure ISBL : SERIALIZABLE = SerializeList(
                                    SerializePair(struct
                                                    structure S1=SerializeInt
                                                    structure S2=SerializeBool
                                                  end))
structure ISBLL : SERIALIZABLE = SerializeList(
                                    SerializePair(struct
                                                    structure S1=SerializeInt
                                                    structure S2=SerializeList(SerializeBool)
                                                  end))

(********** TASK 5.5 -- extra credit! **********)
structure SerializeString : SERIALIZABLE =
struct
    structure S = SerializeList (SerializeInt)
    type t = string

    fun write s = S.write(map ord (explode s))
    fun read l = Option.map (fn (s,y) => (implode (map chr s), y)) (S.read l)
end

(* Here's a bonus example: *)

structure GradesDB =
struct

type grades = (string * (int list * string list)) list

val db : grades =
 [("drl", ([95,99,98], (["y","n","y","y"]))),
  ("iev", ([99,99,99], (["y","y","y","y","y"]))),
  ("nkindber", ([97,99,99], (["y","y","y","y","y"]))),
  ("srikrish", ([100,100,100], (["n","n","n","y","n"]))),
  ("rmemon", ([98,98,98], (["y","y","y","y","y"]))),
  ("dsyang", ([98,100,98], (["y","y","y","y","y"])))
  ]

structure SG =
SerializeList(
 SerializePair(
  struct
   structure S1 = SerializeString
   structure S2 = SerializePair(
                   struct
                    structure S1 = SerializeList(SerializeInt)
                    structure S2 = SerializeList(SerializeString)
                   end)
  end))

val sdb = SG.write db
val db' = SG.read sdb

end


(* Code we used to test *)

signature UNITPACK =
sig
  val s : string
end

functor SerializeUnit(P : UNITPACK) : SERIALIZABLE =
struct
  type t = unit
  fun write _ = P.s
  fun read s =
      case Util.peelOff(P.s,s)
       of SOME s => SOME ((),s)
        | NONE => NONE
end

structure SUBracks = SerializeUnit (struct val s = "[]" end)
structure SUEndBrack = SerializeUnit (struct val s = "]" end)
structure SUOpenBrack = SerializeUnit (struct val s = "[" end)
structure SUPnilP = SerializeUnit (struct val s = "(NIL)" end)
structure SUNil = SerializeUnit (struct val s = "NIL" end)
structure SU40 = SerializeUnit (struct val s = "40" end)
structure SUP40P = SerializeUnit (struct val s = "(40)" end)
structure SUComma = SerializeUnit (struct val s = "," end)
structure SUEpsilon = SerializeUnit (struct val s = "" end)

structure S = SerializeList(SerializeList(SUEpsilon))

functor T (S : SERIALIZABLE) =
struct
fun test reader writer inputs =
    List.map
    (fn x => reader(writer(x)) = SOME(x,""))
end
