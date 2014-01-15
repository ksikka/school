structure TreeDict : LABDICT = 
struct 

datatype ('k,'v) tree = 
    Leaf
  | Node of ('k,'v) tree * ('k * 'v) * ('k,'v) tree

type ('k, 'v) dict = ('k, 'v) tree

val empty = Leaf

fun insert (cmp : 'k * 'k -> order) (d : ('k, 'v) dict) ((k,v) : ('k * 'v)) : (('k, 'v) dict) = 
  case d of 
       Leaf => Node(empty,(k,v),empty)
     | Node(l,(x,y),r) => (case cmp (k,x) of 
                               GREATER => insert cmp r (k,v)
                             | EQUAL   => Node(l,(x,v),r)
                             | _       => insert cmp l (k,v))

fun lookup (cmp : 'k * 'k -> order) (d : ('k, 'v) dict) (k : 'k) : ('v option) = 
  case d of
       Leaf => NONE
     | Node(l,(x,y),r) => case cmp (k,x) of
                              EQUAL   => SOME y
                            | GREATER => lookup cmp r k
                            | _       => lookup cmp l k

end
