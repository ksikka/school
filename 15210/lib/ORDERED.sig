signature ORDERED =
sig
  type t
  include EQKEY
  val compare : t * t -> order
end
