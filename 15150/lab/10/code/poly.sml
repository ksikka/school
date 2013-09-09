structure Poly =
struct

  exception Unbound
  structure Dict = TreeDict
  (* because the types in TreeDict are abstract, your code will work for
     any other implementation of Dict as well.  
     e.g. structure Dict = FunDict from the next homework *)

  type var = string

  datatype poly =
      Var of var
    | K of real
    | Plus of poly * poly
    | Times of poly * poly

  fun cmp (x,y) = 
    case x < y of 
         true => LESS
       | false => case x > y of 
                       true => GREATER
                     | _ => EQUAL

  (* purpose: evaluate env p evaluates to the value of p according to the
      environment env, or raises Unbound if there's a variable in p
      that's not in env.  *)
  fun evaluate (env : (var,real) Dict.dict) (p : poly) : real = 
    case p of 
         K k => k
       | Var v => let x = lookup cmp env v
                  in case x of 
                          NONE => raise Unbound 
                        | SOME y => y
                  end
       | Plus (a,b) => (evaluate env a) + (evaluate env b)
       | Times (a,b) => (evaluate env a) * (evaluate env b)

end
