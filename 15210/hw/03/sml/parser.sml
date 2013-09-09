functor Parser (Seq : SEQUENCE) : PARSER =
struct
  structure Seq = Seq
  open Seq

 (* start or end of token, plus it's index. 
    STARTEND is for single-char tokens *)
  datatype boundary = START of int | END of int | STARTEND of int
  
 (* Returns a sequence of tokens in string s. Delimiter function is cp. 
    Typically pass (fn (c:char) => not (Char.isAlphaNum c)) for cp. *)
  fun tokens cp s =
    let
      val sLength = String.size s
      
     (* Given an index, returns boundary type if boundary of token, else none *)
      fun startOrEndOfToken i =
        let 
          (* true means delimiting character *)
          val currCharType = cp (String.sub(s,i))
          val prevCharType = if i = 0 then true else cp (String.sub(s,(i-1)))
          val nextCharType = if i = (sLength-1) then true 
                             else cp (String.sub(s,(i+1)))
        in
          case (prevCharType,currCharType,nextCharType) of
               ( _  ,true, _   ) => NONE (* curr = delim *)
             | (false, _, false) => NONE (* in middle of token *)
             | (true , _, false) => SOME (START i)
             | (false, _, true ) => SOME (END i)
             | (true , _, true ) => SOME (STARTEND i)
        end

      (* FIND THE BOUNDARIES OF WORDS *)
      val boundaries = tabulate startOrEndOfToken sLength
      val boundaries = filter Option.isSome boundaries
      val numBoundaries = length boundaries
      val boundariesShifted = tabulate (fn i =>
                        if i = (numBoundaries - 1) then
                          NONE
                        else nth boundaries (i+1)) numBoundaries

      (* MAP THE BOUNDARIES TO THE TOKENS WHICH THEY ENCAPSULATE *)
      fun boundaryToToken (boundOpt,nextBoundOpt) = 
        case boundOpt of NONE => NONE |
             SOME (END   _) => NONE
           | SOME (STARTEND i) => SOME (String.substring (s,i,1))
           | SOME (START i) => let
             val END j = Option.valOf nextBoundOpt
             in SOME(String.substring (s,i,j-i+1))
             end

      val tokens = map2 boundaryToToken boundaries boundariesShifted
      val tokens = filter Option.isSome tokens
      val tokens = map Option.valOf tokens
    in tokens
    end

end
