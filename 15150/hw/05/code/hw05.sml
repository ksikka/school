use "lib.sml";

(* ---------------------------------------------------------------------- *)
(* Section 2 - Write and Prove *)
(* Task 2.1 *)
(* Purpose: Flattens a list of lists into one list of that type while preserving
 * the order. 
 * 
 * Examples: 
 * val [] = concat []
 * val [] = concat [[]]
 * val [[]] = concat [[[]]]
 * val [1] = concat [[1]]
 * val ["a","b","z"] = concat [[],["a","b"],[],[],[],["z"]]
 * val [1,2,5,6,10,10] = concat [[1,2],[5,6],[],[10,10]]
 * *)
fun concat (l : 'a list list) : 'a list = 
  case l of 
       [] => []
     | x::xs => case x of 
                     [] => concat xs
                   | y::ys => y::(concat (ys::xs) ) 

val [] = concat []
val [] = concat [[]]
val [[]] = concat [[[]]]
val [1] = concat [[1]]
val ["a","b","z"] = concat [[],["a","b"],[],[],[],["z"]]
val [1,2,5,6,10,10] = concat [[1,2],[5,6],[],[10,10]]

(* ---------------------------------------------------------------------- *)
(* Section 3 - Polymorphism, HOFs, Options *)
(* Task 3.1 *)
(* Purpose: Returns all the possible pairings of elements from l1 with elements
 * from l2, in their original order. 
 * 
 * Examples: 
 *   val [[(1,"a"),(1,"b"),(1,"c")],
          [(2,"a"),(2,"b"),(2,"c")],
          [(3,"a"),(3,"b"),(3,"c")]] = allpairs([1,2,3],["a","b","c"])
     val [[],[],[]]                  = allpairs([1,2,3],[])
     val []                          = allpairs([],[1,2,3])
*)
fun allpairs (l1 : 'a list, l2 : 'b list) : ('a * 'b) list list =
  List.map (fn x => (List.map (fn y => (x,y)) l2 )) l1

val [[(1,"a"),(1,"b"),(1,"c")],
     [(2,"a"),(2,"b"),(2,"c")],
     [(3,"a"),(3,"b"),(3,"c")]] = allpairs([1,2,3],["a","b","c"])
val [[],[],[]] = allpairs([1,2,3],[])
val [] = allpairs([],[1,2,3])

(* Task 3.2 *)
(* Purpose: Interchanges the rows and columns of a list of lists. 
 * 
 * Examples: 
 * val []                  = transpose []
 * val []                  = transpose [[]]
 * val [[1],[2]]           = transpose [[1,2]]
 * val [[1,3],[2,4]]       = transpose [[1,2],[3,4]]
 * val [[1,4],[2,5],[3,6]] = transpose [[1,2,3],[4,5,6]]
 * *)
fun transpose (l : 'a list list) : 'a list list =
  case l of
       [] => []
     | [] :: ys => transpose ys 
     | (x :: xs) :: ys => (List.map List.hd l) :: (transpose (List.map List.tl l))
 
val [] = transpose []
val [] = transpose [[]]
val [[1],[2]] = transpose [[1,2]]
val [[1,3],[2,4]] = transpose [[1,2],[3,4]]
val [[1,4],[2,5],[3,6]] = transpose [[1,2,3],[4,5,6]]

(* Task 3.3 *)
(* Purpose: Return the first element such that the predicate holds, and the rest
 * of the list without that element unchanged. If the element is not found,
 * return NONE. 
 * 
 * Examples: 
 * val NONE          = extract ((fn x => x<0),[1,2,3])
 * val SOME(1,[2,3]) = extract ((fn x => x<3),[1,2,3])
 * val NONE          = extract ((fn x => x>3),[1,2,3])
 * val SOME(3,[1,2]) = extract ((fn x => x=3),[1,2,3])
 * *)
fun extract (p : 'a -> bool, l : 'a list) : ('a * 'a list) option = 
  case l of 
       [] => NONE
     | x::xs => case p x of
                     true => SOME (x,xs)
                   | false => (case extract (p,xs) of
                                   NONE => NONE
                                 | SOME(y,ys) => SOME(y,x::ys))

val NONE = extract ((fn x => x<0),[1,2,3])
val SOME(1,[2,3]) = extract ((fn x => x<3),[1,2,3])
val NONE = extract ((fn x => x>3),[1,2,3])
val SOME(3,[1,2]) = extract ((fn x => x=3),[1,2,3])


(* ---------------------------------------------------------------------- *)
(* Section 4 - Polynomials as SML functions *)
(* Task 4.1 *)
(* Purpose: Returns the poly which is the derivative of a poly 
 * Examples: 
 * fn x =>  *)
fun differentiate (p : poly) : poly = ( fn x => (x+1)//1**(p (x+1)) )
val p = fn x => case x of 0 => 30//1 | 1 => 4//1 | 2 => 4//1 | _ => 0//1;
val dif = differentiate p;
(* Task 4.2 *)
(* Purpose: Returns a function which when given a rat, returns a poly which is 
* the integral of the function p. 
* Examples:
* val bob = integrate ( fn x => case x of 0 => 1 | 1 => 2 | 2 => 3  ) 
* bob is a function which takes a rat as the constant of integration, 
* and returns the poly which is the integral of the original function. *)
fun integrate (p : poly) : rat -> poly = 
  (fn c => 
    (fn x => case x of 
                  0 => c 
                | _ => p(x-1)**(1//x) ))

val bob = integrate p
val inttt = bob (5//1);
(* ---------------------------------------------------------------------- *)
(* Section 5 - Matrices *)
(* Task 5.1 *)
(* Purpose: Add two matrices, returns a matrix.
 * Examples: 
 * plus(m1,m2) = m3
 * see tests for more examples.
 *)
fun plus (m1 : matrix, m2 : matrix) : matrix = 
  ListPair.map (fn(xs,ys) => ListPair.map (fn (x,y) => x++y ) (xs,ys) ) (m1,m2)

val true = mateq( [[2//1,3//1,4//1],[5//1,6//1,7//1]] , plus
([[1//1,1//1,1//1],[1//1,1//1,1//1]],[[1//1,2//1,3//1],[4//1,5//1,6//1]]))

val true = mateq([[1//1,2//1],[3//1,4//1]], plus
([[1//1,2//1],[3//1,4//1]],[[0//1,0//1],[0//1,0//1]]))

(* summat won't work until you complete Task 5.1 *)
fun summat (ms : matrix list) : matrix =
    case ms of
        nil => zed (0, 0)
      | m::ms => List.foldr plus m ms

(* Task 5.2 *)
(* Purpose: Computes the outerproduct of 2 vectors. Returns a matrix.
 * Examples: outerprod(v1,v2) = m3 
 * See tests for more examples.
 * *)
fun outerprod (v1 : rat list, v2 : rat list) : matrix =
  List.map (fn x => List.map (fn y => x ** y) v2) v1

val "[[4,5,6],[8,10,12],[12,15,18]]" : string =
  toString (outerprod([1//1,2//1,3//1],[4//1,5//1,6//1]));

(* Task 5.3 *)
fun times (m1 : matrix, m2 : matrix) : matrix =
  summat (ListPair.map (fn (cs,rs) => outerprod (cs,rs)  ) (transpose m1,m2))

val m1:matrix = [[1//1,2//1,3//1],[3//1,2//1,1//1]];
val m2:matrix = [[3//1,4//1,5//1],[6//1,7//1,8//1]];
val "[[15,18,21],[21,26,31]]":string = toString (times (m1,m2))

(* ---------------------------------------------------------------------- *)
(* Section 6 - Block World *)
(* Task 6.1 *)
(* Purpose: If toExtract is a sub-multiset of from, thenextractMany(eq,toExtract,from)
  * returns SOME xs, where xs is from with every element of toExtract removed.
  * If toExtract is not a sub-multi-set of from, then extractMany(eq,toExtract,from) 
  * returns NONE.
  * *)
fun extractMany (eq : 'a * 'a -> bool,
                 toExtract : 'a list, from : 'a list) : ('a list) option =
  case toExtract of 
          [] => SOME from
     | x::xs => case extract( (fn y => eq(x,y)), from) of
                          NONE => NONE
                  | SOME(y,ys) => extractMany(eq,xs,ys)

(* This function compares two integers and return true iff they're equal *)
fun inteq (x : int , y : int):bool = (x = y)
val SOME [3,3,4,2] = extractMany( inteq, [2,1,2], [1,2,3,3,2,4,2])
val NONE = extractMany(inteq, [2,2], [2])
val NONE = extractMany(inteq,[2,2],[2,1])
val SOME [1,2,3,4,5] = extractMany(inteq,[],[1,2,3,4,5])
     
(* Task 6.2 *)
datatype block = 
                A 
              | B 
              | C

datatype move = 
                PickupFromTable of block
              | PutOnTable of block
              | PickupFromBlock of block*block
              | PutOnBlock of block*block

datatype fact = 
                IsFree of block
              | AIsOnB of block * block
              | IsOnTable of block
              | HEmpty
              | HHolding of block

type state = fact list


(* Task 6.3 *)
val initial : state = [HEmpty,IsOnTable(A),IsOnTable(B),IsOnTable(C),IsFree(A),
                      IsFree(B),IsFree(C)]

(* instantiates extractMany with equality for your fact datatype *)
fun extractManyFacts (toConsume : fact list, s : state) : state option =
    extractMany (fn (x : fact, y : fact) => x = y, toConsume, s)

(* Task 6.4 *)
(* Purpose: If before is a sub-multiset of s, then consumeAndAdd(s, before, after)
 * returns SOME s' where s' is s with before removed and after added. If before
 * is not a sub-multiset, consumeAndAdd(s, before, after) returns NONE.
 * Examples:
 * consumeAndAdd ( [IsFree(B), IsFree(A),HEmpty], 
 *                 [IsFree(A),HEmpty ], 
 *                 [HHolding(A)]) == SOME [IsFree(B),HHolding(A)]
 *)
fun consumeAndAdd (s : state, bef : fact list, aft : fact list) : state option =
  case extractManyFacts(bef,s) of
            NONE => NONE
     | SOME(y) => SOME (y@aft)

val SOME [IsFree(B),HHolding(A)] = consumeAndAdd ( [IsFree(B), IsFree(A),HEmpty], 
                [IsFree(A),HEmpty ], 
                [HHolding(A)]) 
val NONE = consumeAndAdd( [], [HEmpty], [IsFree(A)] )
(* Task 6.5 *) 
(* Purpose: If the before facts of m hold in s, then step(m,s) must
 * return SOME s', where s' is the collection of facts resulting from 
 * performing the move m. It should return NONE if the move cannot be
 * applied in that state.
 *
 * Examples:
 * val SOME [IsOnTable(a),HEmpty] = step(PutOnTable(A), [HHolding(A)])
 * val NONE = step(PutOnTable(A), [])
 * *)
fun step (m : move, s : state) : state option = 
let val (bef,aft) = 
  case m of PickupFromTable(a) =>([IsFree(a),IsOnTable(a),HEmpty],
                                  [HHolding(a)])
          |      PutOnTable(a) => ([HHolding(a)],
                                   [IsOnTable(a),HEmpty])
          | PickupFromBlock(a,b) => ([IsFree(a),AIsOnB(a,b),HEmpty],
                                     [IsFree(b),HHolding(a)])
          |      PutOnBlock(a,b) => ([HHolding(a),IsFree(b)],
                                     [IsFree(a),AIsOnB(a,b),HEmpty])
in  consumeAndAdd(s, bef, aft) 
end

val SOME [IsOnTable(a),HEmpty] = step(PutOnTable(A), [HHolding(A)])
val NONE = step(PutOnTable(A), [])

