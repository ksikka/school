signature PARSER =
sig
   structure Seq : SEQUENCE
   val tokens : (char -> bool) -> string -> string Seq.seq
end
