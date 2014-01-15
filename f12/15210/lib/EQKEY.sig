signature EQKEY =
sig
  type t
  val eq : t * t -> bool
end
