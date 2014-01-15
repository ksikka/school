
signature SET =
sig

  structure Element : ORDERED

  type set

  val empty : set

  val insert : set -> Element.t -> set
  val remove : set -> Element.t -> set
  val member : set -> Element.t -> bool

end
