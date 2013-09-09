signature LABDICT =
sig

  type ('a, 'b) dict

  val empty : ('a, 'b) dict

  val insert : ('a * 'a -> order) -> ('a, 'b) dict -> ('a * 'b) -> ('a, 'b) dict
  val lookup : ('a * 'a -> order) -> ('a, 'b) dict -> 'a -> 'b option

end
