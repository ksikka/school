signature PAREN_PACKAGE =
sig
  structure Seq : SEQUENCE
  exception NYI
  datatype paren = OPAREN
                 | CPAREN
end

signature PAREN =
sig
  structure P : PAREN_PACKAGE
  val parenDist : P.paren P.Seq.seq -> int option
end
