structure Primitives : sig 
  val par: (unit -> 'a) * (unit -> 'b) -> 'a * 'b 
  val par3: (unit -> 'a) * (unit -> 'b) * (unit -> 'c) -> 'a * 'b * 'c
end =
struct

  val par = fn (f, g) => (f (), g())

  fun par3 (x, y, z) =
      let
        val (a, (b, c)) = par(x, fn () => par(y, z))
      in
        (a, b, c)
      end

end
