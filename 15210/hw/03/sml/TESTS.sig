signature TESTS =
sig
  (*[all ()] = true iff all the tests in the module pass.*)
  val all : unit -> bool
end
