structure Types =
struct
  datatype nat = Z | S of nat
  datatype ('a,'b) choice = A of 'a | B of 'b
end
