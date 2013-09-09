signature TESTS =
sig
  (*all () should evaluate to true if and only if all the tests
   *in the structure passed.*)
  val all : unit -> bool
end
