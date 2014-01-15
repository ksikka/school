functor BigNumTest (BGNM : BIGNUM) : TESTS =
struct

  structure BigNum = BGNM

  fun testBinaryFunc (infn1, infn2, addOrSubtract) res tf=
    let
      val (n1,n2) = (BigNum.fromIntInf infn1, BigNum.fromIntInf infn2)
      val actual_res = addOrSubtract(n1,n2)
      val actual_res = BigNum.toIntInf actual_res
      val result = (res = actual_res) = tf
  	in case result of true => true | false =>
			let
			val () = print ((IntInf.toString infn1) ^
			               " (+/-) " ^
			               (IntInf.toString infn2) ^
			               " ?= " ^
			               (IntInf.toString actual_res) ^ "\n")
			in false
			end
  	end

  fun testAdd (infn1, infn2)      = testBinaryFunc (infn1,infn2,BigNum.add)
  fun testSubtract (infn1, infn2) = testBinaryFunc (infn1,infn2,BigNum.sub)

  val addTests = [ (Int.toLarge 400,Int.toLarge 200,Int.toLarge 600,true),
                (Int.toLarge 100000,Int.toLarge 20,Int.toLarge 100020,true),
                (Int.toLarge 400,Int.toLarge 2,Int.toLarge 600,false),
                (Int.toLarge 1, Int.toLarge 0, Int.toLarge 1, true),
                (Int.toLarge 0, Int.toLarge 1, Int.toLarge 1, true),
                (Int.toLarge 0, Int.toLarge 0, Int.toLarge 0, true) ]

  val subtractTests = [ (Int.toLarge 400,Int.toLarge 200,Int.toLarge 200,true),
                (Int.toLarge 100000,Int.toLarge 20,Int.toLarge 99980,true),
                (Int.toLarge 400,Int.toLarge 2,Int.toLarge 600,false),
                (Int.toLarge 1, Int.toLarge 1, Int.toLarge 0, true),
                (Int.toLarge 1, Int.toLarge 0, Int.toLarge 1, true),
                (Int.toLarge 0, Int.toLarge 0, Int.toLarge 0, true) ]

  fun all () = let
  				 val () = print "Testing add function \n"
  				 val adds = List.foldr (fn ( (a,b,c,d), res ) => (testAdd (a,b) c d)andalso res) true addTests
  				 
  				 val () = print "Testing subtract function \n"
  				 val subtracts = List.foldr (fn ( (a,b,c,d), res ) => (testSubtract (a,b) c d)andalso res) true subtractTests
  				 
  				 in adds andalso subtracts
  				 end

end
