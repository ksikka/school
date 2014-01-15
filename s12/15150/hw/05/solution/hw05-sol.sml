use "../code/lib.sml";

(* ---------------------------------------------------------------------- *)
(* Section 2 - Write and Prove *)
(* Task 2.1 *)
(* PURPOSE
 *
 * Flatten a list of lists of 'a into one list of 'a while preserving the
 * order.
 *)
fun concat (l : 'a list list) : 'a list =
    case l of
        [] => []
      | (hd :: tl) :: tls => hd :: concat (tl :: tls)
      | [] :: tls => concat tls

val [] = concat []
val [] = concat [[]]
val [[]] = concat [[[]]]
val [1] = concat [[1]]
val ["a","b","z"] = concat [[],["a","b"],[],[],[],["z"]]
val [1,2,5,6,10,10] = concat [[1,2],[5,6],[],[10,10]]

(* ---------------------------------------------------------------------- *)
(* Section 3 - Polymorphism, HOFs, Options *)
(* Task 3.1 *)
(* PURPOSE
 *
 * allpairs(l1, l2) returns all of the possible pairings of elements from l1
 * with elements from l2, in their original order, grouped into sublists
 * by first element.
 *)
fun allpairs (l1 : 'a list, l2 : 'b list) : ('a * 'b) list list =
    map (fn a => map (fn b => (a, b)) l2) l1

val [] = allpairs ([],[1,2,3])
val [[],[],[]] = allpairs ([1,2,3],[])
val [[(1,"a"),(1,"b"),(1,"c")],
     [(2,"a"),(2,"b"),(2,"c")],
     [(3,"a"),(3,"b"),(3,"c")]] = allpairs ([1,2,3],["a","b","c"])
val [[(1,"a"), (1,"b")], [(2,"a"), (2,"b")], [(3,"a"), (3,"b")]] =
    allpairs ([1,2,3], ["a","b"])

(* Task 3.2 *)
(* PURPOSE
 *
 * transpose l interchanges the rows and columns of a list of lists of
 * equal length. If transpose l evaluates to l', and if l_ij is the element
 * of l in the jth position of the ith sublist, L_ij = L'_ji.
 *)
fun transpose (m : 'a list list) : 'a list list =
    case m of
        [] => []
      | [] :: rs => []
      | _ => (map List.hd m) :: transpose (map List.tl m)

fun transpose' (m : 'a list list) : 'a list list =
    case m of
        [] => []
      | [r] => List.map (fn x => [x]) r
      | x :: xs => ListPair.map (fn (a, b) => a :: b) (x, transpose' xs)

fun transpose'' (l : 'a list list) : 'a list list =
    case l of
        [] => []
      | d :: _ => foldr (ListPair.map op::) (map (fn _ => []) d) l

(* Try an alternate implementation if you'd like! *)
val transpose = transpose

val [[1],[2]] = transpose [[1,2]]
val [[1,3],[2,4]] = transpose [[1,2],[3,4]]
val [[1,3,5],[2,4,6]] = transpose [[1,2],[3,4],[5,6]]
val [[1,2],[3,4],[5,6]] = transpose([[1,3,5],[2,4,6]])
val [["one"]] = transpose([["one"]])
val [] = transpose([])
val [[42],[90],[11]] = transpose([[42,90,11]])
val [["dragon","ponies"],
     ["unicorn","kitties"],
     ["narwal","barrel"],
     ["rainbow","roll"]] = transpose([["dragon","unicorn","narwal","rainbow"],
                                      ["ponies","kitties","barrel","roll"]])

(* Task 3.3 *)
(* PURPOSE
 *
 * extract (p, l) evaluates to NONE if none of the elements of l
 * satisfy the predicate p. Otherwise, if x is the first element
 * satisfying p and l = l' @ [x] @ l'', then evaluates to SOME (x, l' @ l'').
 *)
fun extract (p : 'a -> bool, l : 'a list) : ('a * 'a list) option =
    case l of
        [] => NONE
      | x :: xs =>
        (case p x of
             true => SOME (x, xs)
           | false => (case extract (p, xs) of
                           NONE => NONE
                         | SOME (witness, rest) => SOME (witness, x :: rest)))

fun oddP (x:int) : bool = (x mod 2) = 1

val SOME (3,[2,4]) = extract(oddP, [2,3,4])
val SOME (3,[2,4,5,6,7,8]) = extract(oddP, [2,3,4,5,6,7,8])
val NONE = extract(fn x => not (oddP x), [1,3,5,7,9])
val NONE = extract(oddP, [2,4,6])
val SOME ("b", ["aaa", "bca"]) =
    extract(fn x => String.size x < 2, ["aaa","b","bca"])

(* ---------------------------------------------------------------------- *)
(* Section 4 - Polynomials as SML functions *)

(* PURPOSE
 *
 * Converts an argument list into a function that maps a natural
 * number to the element of the list in that position if there is one.
 * Otherwise, the function maps the number to the value x.
 *)
fun listToFun (x : 'a, l : 'a list) : int -> 'a =
    fn y => case nth (l, y) of NONE => x | SOME x' => x'

(* PURPOSE
 *
 * Compare the coefficients of two polynomials for equality up to the
 * coefficient of x^count.
 *)
fun polyEqual (n1 : poly, n2 : poly, count : int) : bool =
    ListPair.all (fn (r1, r2) => EQUAL = Rational.compare (r1, r2))
                 (List.tabulate(count + 1, n1), List.tabulate(count + 1, n2))

val p0 = listToFun (0//1, [2//1,1//1])
val p1 = listToFun (0//1, [1//1,2//1,1//1])
val p2 = listToFun (0//1, [2//1,2//1])
val p3 = listToFun (0//1, [2//1])
val p4 = listToFun (0//1, [3//1,2//1,1//1,3//1,1//1])
val p5 = listToFun (0//1, [2//1,2//1,9//1,4//1])
val p6 = listToFun (0//1, [2//1,18//1,12//1])
val p7 = listToFun (0//1, [18//1,24//1])
val p8 = listToFun (0//1, [24//1])
val p9 = listToFun (0//1, [4//1,6//1,36//1,20//1])
val p10 = listToFun (0//1, [0//1,2//1,1//1])
val p11 = listToFun (0//1, [2//1,2//1])
val p12 = listToFun (1//1, [1//1,2//1,1//1,3//1,1//1])
val p13 = listToFun (0//1, [2//1,2//1,9//1,4//1])

(* Task 4.1 *)
(* PURPOSE
 *
 * Computes the derivative of a polynomial represented as a `poly`,
 * a function `int -> rat` that given a natural number i emits the
 * coefficient c_i of a polynomial in normal form:
 *
 *   c_0 x^0 + c_1 x^1 + c_2 x^2 + ...
 *   => 1 c_1 x^0 + 2 c_2 x^1 + ...
 *)
fun differentiate (p : poly) : poly =
    fn i => ((i + 1) // 1) ** (p (i + 1))

val true = polyEqual (p2, differentiate p1, 1)
val true = polyEqual (p3, differentiate p2, 0)
val true = polyEqual (p5, differentiate p4, 3)
val true = polyEqual (p6, differentiate p5, 2)
val true = polyEqual (p7, differentiate p6, 1)
val true = polyEqual (p8, differentiate p7, 0)

(* Task 4.2 *)
(* PURPOSE
 *
 * Computes the integral of a polynomial represented as a `poly`
 * with a given constant of integration:
 *
 *   c_0 x^0 + c_1 x^1 + c_2 x^2 + ...
 *   => c + 1 c_0 x^1 + (1/2) c_1 x^2 + (1/3) c_2 x^3 + ...
 *)
fun integrate (p : poly) : rat -> poly =
    fn c => (fn 0 => c | e => 1 // e ** (p (e - 1)))

val true = polyEqual ((integrate p11) (0//1), p10, 2)
val true = polyEqual (integrate p13 (1//1), p12, 4)
val true = polyEqual (differentiate (integrate p13 (3//1)), p13, 3)
val true = polyEqual (differentiate (integrate p12 (1//1)), p12, 4)
val true = polyEqual (differentiate (integrate p11 (2//1)), p11, 1)
val true = polyEqual (differentiate (integrate p10 (0//1)), p10, 2)

(* ---------------------------------------------------------------------- *)
(* Section 5 - Matrices *)

val m1 = zed (0, 0)
val m2 = [[1//3]]
val m3 = [[2//3]]
val m4 = [[1//1,2//1,1//2]]
val m5 = [[4//1,1//1,1//3]]
val m6 = [[5//1,3//1,5//6]]
val m7 = [[1//1],[4//1],[1//3]]
val m8 = [[3//2],[8//1],[2//3]]
val m9 = [[5//2],[12//1],[1//1]]
val m10 = [[1//1,2//1],[3//1,3//1]]
val m11 = [[5//1,1//1],[0//1,3//1]]
val m12 = [[6//1,3//1],[3//1,6//1]]
val m13 = [[5//8]]
val m14 = [[3//1,6//1,3//2]]
val m15 = [[8//1,2//1,2//3]]
val m16 = [[5//2,3//2,5//12]]
val m17 = [[10//1],[40//1],[10//3]]
val m18 = [[3//4],[8//2],[2//6]]
val m19 = [[1//3,2//3],[1//1,1//1]]
val m20 = [[1//1,2//1],[3//1,4//1],[5//1,6//1]]
val m21 = [[1//1,3//1,5//1],[2//1,4//1,6//1]]
val m22 = [[5//1],[3//1],[5//6]]
val m23 = [[2//9]]
val m24 = [[3//2,8//1,2//3],[6//1,32//1,8//3],[1//2,8//3,2//9]]
val m25 = [[5//1],[24//1],[2//1]]
val m26 = [[8//1,9//1,9//1],[5//1,~1//1,20//1]]
val m27 = [[10//1,2//1],[40//1,8//1],[9//1,0//1]]
val m28 = [[521//1,88//1],[190//1,2//1]]

(* Task 5.1 *)
(* PURPOSE
 *
 * If A and B are valid matrices with the same dimensions, plus (A, B)
 * performs addition on the matrices A and B element-wise.
 *)
fun plus (m1 : matrix, m2 : matrix) : matrix =
    ListPair.map (ListPair.map op++) (m1, m2)

val true = mateq (plus (m1, m1), m1)
val true = mateq (plus (m2, m2), m3)
val true = mateq (plus (m4, m5), m6)
val true = mateq (plus (m7, m8), m9)
val true = mateq (plus (m10, m11), m12)

(* summat won't work until you complete Task 5.1 *)
fun summat (ms : matrix list) : matrix =
    case ms of
        [] => zed (0, 0)
      | m :: ms => List.foldr plus m ms

(* Task 5.2 *)
(* PURPOSE
 *
 * outerprod (V1, V2) computes the outer product of V1 and V2,
 * defined (where V1 and V2 are column vectors of equal dimension)
 * as the matrix product VE^T. This is effectively a matrix M containing
 * the products of all possible pairs of elements from V1 and V2, where
 * M_i,j = V1_i ** V2_j.
 *)
fun outerprod (v1 : rat list, v2 : rat list) : matrix =
    map (map op**) (allpairs (v1, v2))

val v1 = []
val v2 = [1//3]
val v3 = [2//3]
val v7 = [1//1,4//1,1//3]
val v8 = [3//2,8//1,2//3]
val true = mateq(outerprod (v1, v1), m1)
val true = mateq(outerprod (v2, v3), m23)
val true = mateq(outerprod (v7, v8), m24)

(* Task 5.3 *)
(* PURPOSE
 *
 * times (m1, m2), for m1 (an n by k matrix) and m2 (a k by m matrix),
 * is the result of the matrix multiplication m1m2.
 *)
fun times (m1 : matrix, m2 : matrix) : matrix =
    summat (ListPair.map outerprod (transpose m1, m2))

val true = mateq(times (m1,m1), m1)
val true = mateq(times (m26,m27), m28)

(* ---------------------------------------------------------------------- *)
(* Section 6 - Block World *)
(* Task 6.1 *)
(* PURPOSE
 *
 * extractMany eq toExtract from:
 *  - returns NONE if toExtract is not a sub-multi-set of from according to
 *    the equality predicate eq
 *  - otherwise, returns SOME l where l contains the result of removing the
 *    sub-multi-set toExtract from the multiset from. *)
fun extractMany (eq : 'a * 'a -> bool,
                 toExtract : 'a list, from : 'a list) : ('a list) option =
    case toExtract of
        [] => SOME from
      | e :: es =>
        (case extract (fn x => eq (x, e), from) of
             NONE => NONE
           | SOME (_ , from') => extractMany (eq, es, from'))

val SOME [2,4,6] = extractMany(op=,[1,3,5],[1,2,3,4,5,6])
val NONE = extractMany(op=,[1,3,5],[2,4,6,8])
val SOME ["gold",
          "silver",
          "bronze",
          "copper",
          "brass"] = extractMany(op=, ["blue","white","red","green","black"],
                                     ["blue","gold","white","silver","bronze",
                                      "red","green","copper","black","brass"])

(* Task 6.2 *)
datatype block = A | B | C

datatype move =
    PickUpFromBlock of block * block
  | PutOnBlock of block * block
  | PickUpFromTable of block
  | PutOnTable of block

datatype fact =
    Free of block
  | On of block * block
  | OnTable of block
  | HandIsEmpty
  | HandHolds of block

type state = fact list

(* Task 6.3 *)
val initial : state = [HandIsEmpty,
                       OnTable A, OnTable B, OnTable C,
                       Free A, Free B, Free C]

(* instantiates extractMany with equality for your fact datatype *)
fun extractManyFacts (toConsume : fact list, s : state) : state option =
    extractMany (fn (x : fact, y : fact) => x = y, toConsume, s)

(* Task 6.4 *)
(* PURPOSE
 *
 * consumeAndAdd s bef aft:
 *  - returns NONE if bef is not a sub-multi-set of s
 *  - otherwise, returns SOME s', where s' = (s - bef) + aft.
 *    (- sub-multi-set difference, + sub-multi-set union).
 *)
fun consumeAndAdd (s : state, bef : fact list, aft : fact list) : state option =
    case extractManyFacts (bef, s) of
        NONE => NONE
      | SOME s' => SOME (aft @ s')

val NONE = consumeAndAdd(initial, [On(B,C), Free A],[HandHolds A])
val SOME [On (A,B),
          HandIsEmpty,
          OnTable B,
          OnTable C,
          Free C] = consumeAndAdd(initial,[OnTable A, Free A, Free B],
                                          [On (A,B)])
val SOME [HandHolds A,
          OnTable B] = consumeAndAdd([OnTable B, OnTable A, HandIsEmpty],
                                     [OnTable A, HandIsEmpty],[HandHolds A])

(* Task 6.5 *)
(* PURPOSE
 *
 * step m s returns NONE if s does not satisfy the preconditions of m.
 * Otherwise, it returns SOME s', where s' is the result of performing
 * m on s (that is, rendering the preconditions false and establishing
 * the postconditions).
 *)
fun step (m : move, s : state) : state option =
    case m of
        PickUpFromBlock (a, b) =>
            consumeAndAdd (s,
                           [Free a , On(a, b) , HandIsEmpty],
                           [Free b , HandHolds a])
      | PutOnBlock (a, b) =>
            consumeAndAdd (s,
                           [HandHolds a, Free b],
                           [HandIsEmpty, Free a, On(a, b)])
      | PickUpFromTable a =>
            consumeAndAdd (s,
                           [Free a, OnTable a, HandIsEmpty],
                           [HandHolds a])
      | PutOnTable a =>
            consumeAndAdd (s,
                           [HandHolds a],
                           [HandIsEmpty, OnTable a, Free a])

val NONE = step (PickUpFromBlock(A,B),initial)
val SOME [HandHolds C,OnTable A,
          OnTable B,Free A,Free B] = step (PickUpFromTable C, initial)
val SOME [HandIsEmpty,
          Free C,
          On (C,A),
          OnTable A,
          OnTable B,
          Free B] = step (PutOnBlock(C,A), [HandHolds C,OnTable A,
                                            OnTable B,Free A,Free B])
