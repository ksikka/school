structure NatOrder : ORDERED =
struct
  type t = Types.nat
  (* Compare nats by recurring on the structure of nats *)
  fun compare (n1,n2) =
      case (n1,n2)
       of (Types.Z, Types.Z) => EQUAL
        | (Types.Z, _) => LESS
        | (_, Types.Z) => GREATER
        | (Types.S n1', Types.S n2') => compare (n1', n2')
end

(* the keyword 'open' brings everything exported in a module into
   scope. it's a double edged sword: too many opens, or just badly chosen
   ones, can create unreadable code and bizarre shadowing bugs. for
   example, if you did 'open Seq', the identifier 'map' would refer to
   Seq.map and the normal binding to List.map would be shadowed. still, it
   can really clean up code sometimes; here's an example. the ChoiceOrder
   functor would be another reasonable candidate.
*)
structure NatOrderOpened : ORDERED =
struct
  open Types

  type t = nat
  (* Compare nats by recurring on the structure of nats *)
  fun compare (n1,n2) =
      case (n1,n2)
       of (Z, Z) => EQUAL
        | (Z, _) => LESS
        | (_, Z) => GREATER
        | (S n1', S n2') => compare (n1', n2')
end

functor FlipOrder (O : ORDERED) : ORDERED =
struct
  type t = O.t

  (* Compares the opposite of O case on the *)
  (* O.compare and flip LESS and GREATER *)
  fun compare (x : O.t * O.t) =
      case O.compare x
       of LESS => GREATER
        | GREATER => LESS
        | EQUAL => EQUAL

  (* another slightly clever implementation of the same comparison,
     assuming that O.compare is well-behaved.
   *)
  fun compare (x,y) = O.compare(y,x)
end

functor ChoiceOrder (P : TWOORDERS) : ORDERED =
struct
  type t = (P.O1.t,P.O2.t) Types.choice

  (* Compares a pair by ordering the As below the Bs. Then order within the
     As and within the Bs as normal.
   *)
  fun compare p =
      case p of
          (Types.A _, Types.B _) => LESS
        | (Types.B _, Types.A _) => GREATER
        | (Types.A a1, Types.A a2) => P.O1.compare (a1,a2)
        | (Types.B b1, Types.B b2) => P.O2.compare (b1,b2)
end

structure TestChoice =
struct
    structure Args : TWOORDERS =
    struct
      structure O1 = IntLt
      structure O2 = NatOrder
    end
    structure IN = ChoiceOrder(Args)

    (* you can avoid making an extra structure by inlining it, but it can
       get messy fast.
     *)
    (*
     structure IN = ChoiceOrder(struct
                                  structure O1 = IntLt
                                  structure O2 = NatOrder
                                end)
     *)

    val LESS = IN.compare (Types.A 4, Types.B Types.Z)
    val GREATER = IN.compare (Types.B (Types.S Types.Z), Types.A 7)
    val LESS = IN.compare (Types.A 6, Types.A 7)
    val LESS = IN.compare (Types.B Types.Z, Types.B (Types.S Types.Z))
    val EQUAL = IN.compare (Types.A 6, Types.A 6)
end

structure Ints : TWOORDERS =
struct
  structure O1 = FlipOrder (NatOrder)
  structure O2 = NatOrder
end

structure IntsOrder = ChoiceOrder(Ints)

(*convert between this representation of integers and the usual one *)
(* 0 is converted to Types.B Types.Z, so there's a shift. *)
structure Conv =
struct
  fun toNat 0 = Types.Z
    | toNat n = Types.S( toNat (n-1))

  fun fromNat (Types.Z) = 0
    | fromNat (Types.S(n)) = 1 + (fromNat n)

  fun toInt (Types.A x) = ~(fromNat x) - 1
    | toInt (Types.B x) = (fromNat x)

  fun fromInt x =
      case Int.compare(x,0)
       of LESS    => Types.A(toNat (~(x+1)))
        | EQUAL   => Types.B Types.Z
        | GREATER => Types.B(toNat (x))
end
