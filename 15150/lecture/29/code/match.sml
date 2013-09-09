signature MATCH = sig
                      datatype regexp =
                          Zero
                        | One
                        | Char of char
                        | NotChar of char (* NotChar c matches any single character that is not c *)
                        | Wild
                        | Times of regexp * regexp
                        | Plus of regexp * regexp
                        | Star of regexp

                      val QuestionMark : regexp -> regexp
                      val String       : string -> regexp
                         
                      (* return the stream of strings that match the regexp 
                         warning: not productive if there is never something that matches *)
                      val grep : regexp -> char Stream.stream -> string Stream.stream
                  end

structure Match : MATCH = 
struct
    open Stream

    datatype regexp =
        Zero
      | One
      | Char of char
      | NotChar of char  
      | Wild 
      | Times of regexp * regexp
      | Plus of regexp * regexp
      | Star of regexp

    fun addc c : string option * char Stream.stream -> string option * char Stream.stream = 
        (fn  (NONE , cs) => (NONE , cs)
          | (SOME m , cs) => (SOME (str c ^ m),cs))

    fun match r (cs : char Stream.stream) 
                (k : char Stream.stream -> string option * char Stream.stream) 
      : string option * char Stream.stream = 
        case r of
            Zero => (NONE , cs)
          | One => k cs
          | Char c => (case expose cs of
                           Nil  => (NONE,cs)
                         | Cons (c' , cs) => (case c = c' of
                                                  true => (addc c o k) cs
                                                | false => (NONE, cs)))
          | NotChar c => (case expose cs of
                              Nil  => (NONE,cs)
                            | Cons (c' , cs) => (case c = c' of
                                                     false => (addc c' o k) cs
                                                   | true => (NONE, cs)))
          | Wild => (case expose cs of
                         Nil  => (NONE,cs)
                       | Cons (c , cs) => (addc c o k) cs)
          | Plus (r1,r2) => (case match r1 cs k of
                                 (SOME v , cs') => (SOME v , cs')
                                 (* exploits persistence: backtracks from the result of match r1
                                                                     to cs *)
                               | (NONE   ,  _) => match r2 cs k) 
          | Times (r1,r2) => match r1 cs (fn cs' => match r2 cs' k)
          | Star r => 
                let fun matchstar cs = case k cs of 
                    (SOME v , cs) => (SOME v , cs)
                  | (NONE , _) => match r cs matchstar
                in 
                    matchstar cs
                end

    fun QuestionMark r = Times (r , Star r)

    fun String s = List.foldr (fn (c , r) => Times (Char c, r)) One (String.explode s)

    fun grep r cs = stream (fn () => 
                            case expose cs of
                                Nil => Nil
                              | _ => (case match r cs (fn cs => (SOME "" , cs)) of 
                                          (SOME s , cs) => Cons (s , grep r cs)
                                        | (NONE   , cs) => expose (grep r cs)))
        
end
