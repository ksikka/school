signature HASHKEY =
sig
  type t
  include EQKEY
  val compare : t * t -> order
  val hash : t -> int
end
