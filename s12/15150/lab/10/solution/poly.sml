structure Poly =
struct

  exception Unbound
  structure Dict = TreeDict

  type var = string

  datatype poly =
      Var of var
    | K of real
    | Plus of poly * poly
    | Times of poly * poly

  (* purpose: evaluate env p evaluates to the value of p according to the
      environment env, or raises Unbound if there's a variable in p
      that's not in env.  *)
  fun evaluate (env : (var,real) Dict.dict) (p : poly) : real =
    case p of
      Var v =>
        (case Dict.lookup String.compare env v of
          SOME x => x
        | NONE => raise Unbound)
    | K x => x
    | Plus (p1, p2) => (evaluate env p1) + (evaluate env p2)
    | Times (p1, p2) => (evaluate env p1) * (evaluate env p2)

  infixr 0 ++ 
  val op++ = Plus
  infixr 1 **
  val op** = Times
  infix 6 ^^

  fun p ^^ n = 
      case n of 
          0 => K 1.0
        | _ => p ** (p ^^ (n-1))

  val example = (Var "x")^^2 ++ K 2.0 ** (Var "x") ++ K 1.0
  val true = Real.==(evaluate (Dict.insert String.compare Dict.empty ("x",4.0)) example, 25.0)

  val ` = Var
  val `` = K
  val example' = `"x"^^2 ++ ``2.0 ** `"x" ++ ``1.0
  val true = Real.==(evaluate (Dict.insert String.compare Dict.empty ("x",4.0)) example', 25.0)

end
