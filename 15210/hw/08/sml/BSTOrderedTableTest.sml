functor BSTOrderedTableTest (structure B : ORD_TABLE
                                    where type Key.t = int) :> TEST =
struct
  structure Seq = B.Seq
  type 'a seq = 'a Seq.seq

  (* tests first, last, next, prev, split, join, getrange *)
  fun all () =
  let

    (* trees to test *)
    val emptyTree = B.empty ()
    val singletonTree = B.singleton (1,2)
    val multiTree = (B.fromSeq o Seq.fromList) [(4,5),(5,6),(6,7),(7,8),(8,9)
                                               ,(1,2),(2,3),(3,4)]

    val isNone = not o Option.isSome

    (* first and last in empty tree should be none *)
    val emp =          isNone (B.first emptyTree)
              andalso (isNone (B.last emptyTree))

    (* first and last in singleton should be the only thing in singleton *)
    val singl =         (B.first singletonTree = SOME (1,2))
                andalso (B.last singletonTree = SOME (1,2))
                andalso (isNone (B.previous singletonTree 1))
                andalso (isNone (B.next singletonTree 1))

    (* similar tests for the general case *)
    val multi =         (B.first multiTree = SOME (1,2))
                andalso (B.last multiTree = SOME (8,9))
                andalso (B.previous multiTree 8 = SOME (7,8))
                andalso (B.next multiTree 7 = SOME (8,9))
                andalso (isNone (B.next multiTree 8))

    (* test split and getrange *)
    val (l,k,r) = B.split (multiTree, 4)
    val splittest =         B.size l = 3
                    andalso B.size r = 4
                    andalso B.reduce (fn (x,y) => x andalso y) true
                      (B.mapk (fn (k,_) => k < 4) l)
                    andalso B.reduce (fn (x,y) => x andalso y) true
                      (B.mapk (fn (k,_) => k > 4) r)
                    andalso Option.isSome k
                    andalso Option.valOf k = 5

    val ranget = B.getRange multiTree (3,5)
    val testranget = B.filter (fn (k,_) => (k >= 3) andalso (k <= 5) ) multiTree
    val rangetest = B.Set.equal(B.domain ranget, B.domain testranget)


    val () = if emp then () else print "empty test failed"
    val () = if singl then () else print "singleton test failed"
    val () = if multi then () else print "bigtree test failed"
    val () = if splittest then () else print "split test failed"
    val () = if rangetest then () else print "range test failed"

  in emp andalso singl andalso multi andalso splittest andalso rangetest
  end

end

(* Use this to test *)
structure TestPartOne = BSTOrderedTableTest(structure B = B)
