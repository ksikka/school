use "lib.sml";

(* ---------------------------------------------------------------------- *)
(* SECTION 2 *)

(* Purpose: To take a list of ints, and a list of strings, and return a list
 * of tuples with the nth int and the nth string.
 * Example:
 * ( [1,2,3,4,5] , ["a","b","c","d","e"] ) ==> 
 * [ (1,"a") , (2,"b") , (3,"c") , (4,"d") , (5,"e") ]
 *)
fun zip (l1 : int list, l2 : string list) : (int * string) list =
  case l1 of
       [] => []
     | x::xs => case l2 of 
                     [] => []
                   | y::ys => (x,y)::zip(xs,ys)
val [] = zip ([],[])
val [(1,"2"),(3,"4")] = zip ([1,3],["2","4","6"])
val [(1,"2"),(3,"4")] = zip ([1,3,5],["2","4"])
val [ (1,"a") , (2,"b") , (3,"c") , (4,"d") , (5,"e") ] = zip( [1,2,3,4,5] , ["a","b","c","d","e"] )

(* Purpose: To take a list of tuples with an int and a string, and return two
 * lists: one of the ints and one of the strings.
 * Example:
 * [ (1,"a") , (2,"b") , (3,"c") , (4,"d") , (5,"e") ] ==>
 * ( [1,2,3,4,5] , ["a","b","c","d","e"] )
 *)
fun unzip (l : (int * string) list) : int list * string list =
  case l of
       [] => ([],[])
     | x::xs => let val (pint, pstr) = x
                    val (ints, strs) = unzip(xs)
                in (pint::ints,pstr::strs)
                end
val ([],[]) = unzip []
val ([1,2,3,4,5] , ["a","b","c","d","e"]) = unzip [ (1,"a") , (2,"b") , (3,"c") , (4,"d") , (5,"e") ] 

(* ---------------------------------------------------------------------- *)
(* SECTION 3 *)
(* Purpose: a helper function to take in a tail of list of ints, a counter of
 * the last element, and how many time the last element was seen continuously.
 * Outputs the tail of the list without the repeated element in the front, and a
 * count for the total number of times the repeated element occurred in the
 * front.
 * Examples:
 * lasHelp([1,2,3],3,1) ==> ([1,2,3],1)
 * lasHelp([2,2,6,3],2,2) ==> ([6,3],4)
 * *)
fun lasHelp (l : int list, x : int, acc : int) : int list * int =
  case l of 
       [] => ([],acc)
     | y::ys => case inteq(x, y) of
                     true => let 
                               val (tale,tot) = lasHelp(ys,y,acc+1)
                             in
                               (tale,tot)
                             end
                   | false => (l,acc)
val ([1,2,3],1) = lasHelp([1,2,3],3,1)
val ([6,3],4) = lasHelp([2,2,6,3],2,2) 

fun look_and_say (l : int list) : int list =
  case l of 
       [] => []
     | x::xs => let val (tale,tot) = lasHelp(xs,x,1)
                in tot::x::look_and_say(tale)
                end

val [4,1,4,2,4,3,4,4] = look_and_say([1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4])
val [1,2,3,4,1,5] = look_and_say([2,4,4,4,5])

(* ---------------------------------------------------------------------- *)
(* SECTION 4 *)

(* Purpose: Given an int list, prefixSum will return a list where the nth
 * element is the sum of the 0...n elements of the list. 
 * Examples:
 * prefixSum([3]) ==> [3]
 * prefixSum([3,4]) ==> [3,7]
 * prefixSum([3,4,5]) ==> [3,7,12] *)
fun prefixSum (l : int list) : int list =
  case l of 
       nil => nil
     | x::xs => x::add_to_each(prefixSum(xs),x)

val [] = prefixSum []
val [1,2,3,4] = prefixSum [1,1,1,1]
val [1,3,6,10] = prefixSum [1,2,3,4]

(* Purpose: Given an int list, prefixSumHelp will use an extra argument to make
 * prefixSum faster. Given the sum of the head, it will compute the prefix sum list
 * for the tail, followed by the last element in the prefix sum list.
 * Examples:
 * prefixSumHelp([1,2,3]) ==> ([1,3,6],6)
 * prefixSumHelp([3,4,5],7) ==> ([10,14,19],19)
 * prefixSumHelp([3,4,5],3) ==> ([6,10,15],15) *)
fun prefixSumHelp (l : int list, prevSum : int) : int list * int =
  case l of 
       nil => (nil,prevSum)
     | x::xs => let val (tale, sum) = prefixSumHelp(xs,prevSum + x)
                in ((x+prevSum)::tale , sum)
                end
val ([1,3,6],6) = prefixSumHelp([1,2,3],0)
val ([10,14,19],19) = prefixSumHelp([3,4,5],7)
val ([6,10,15],15) = prefixSumHelp([3,4,5],3)

(* Purpose: Given an int list, prefixSumFast will use prefixSumHelp to make
 * prefixSum faster. Follows the syntax and usage of prefixSum.
 * Examples:
 * prefixSumFast([1,2,3]) ==> [1,3,6]
 * prefixSumFast([5,4,2]) ==> [5,9,11]
 * prefixSumFast([3,4,5]) ==> [3,7,12] *)
fun prefixSumFast (l : int list) : int list =
  case l of
       nil => nil
     | _ => let val (l2,sum) = prefixSumHelp(l,0)
            in l2
            end
val [1,3,6] = prefixSumFast([1,2,3])
val [5,9,11] = prefixSumFast([5,4,2])
val [3,7,12] = prefixSumFast([3,4,5])

(* ---------------------------------------------------------------------- *)
(* SECTION 5 *)
(* Purpose: To return the sublist of a list, as given by the starting index
 * (inclusive) , the ending index (exclusive) , and the list itself.
 * Examples:
 * sublist(0,5,[1,2,3,4,5,6,7,8]) = [1,2,3,4,5]
 * sublist(1,6,[1,2,3,4,5,6,7,8]) = [2,3,4,5,6]
 * sublist(~1,60,[1,2,3,4,5,6,7,8]) = [1,2,3,4,5,6,7,8]
 * sublist(6,7,[1,2,3,4,5,6,7,8]) = [7]
 * *)
fun sublist (i : int, j : int, l : int list) : int list =
    case l of
         [] => []
       | x::xs => case i > 0 of 
                       true => sublist(i-1,j,xs)
                     | false => case j of
                                     0 => []
                                   | _ => x::sublist(i,j-1,xs)
val [1,2,3,4,5] = sublist(0,5,[1,2,3,4,5,6,7,8])
val [2,3,4,5,6,7] = sublist(1,6,[1,2,3,4,5,6,7,8])
val [7,8] = sublist(6,2,[1,2,3,4,5,6,7,8,9])
val [] = sublist(1,0,[1,2,3,4])

fun sublist_check (i : int, j : int, l : int list) : int list =
    case i < 0 of 
         true => raise Fail "Invalid i value: i < 0"
       | false => case j < 0 of 
                       true =>  raise Fail "Invalid j value: j less than 0"
                     | false => case i+j > length l of 
                                     true =>  raise Fail "Invalid j value: j too big"
                                   | false => sublist(i,j,l)
val [1,2,3,4,5] = sublist_check(0,5,[1,2,3,4,5,6,7,8])
val [2,3,4,5,6,7] = sublist_check(1,6,[1,2,3,4,5,6,7,8])
val [7,8] = sublist_check(6,2,[1,2,3,4,5,6,7,8,9])
val [] = sublist_check(1,0,[1,2,3,4])
(* Error checks : 
uncaught exception Fail [Fail: Invalid i value: i < 0]
  raised at: hw03.sml:141.24-141.53
- sublist_check(1,~3,[1,2,3]);

uncaught exception Fail [Fail: Invalid j value: j less than 0]
  raised at: hw03.sml:143.39-143.76
- sublist_check(1,3,[1,2,3]);

uncaught exception Fail [Fail: Invalid j value: j too big]
  raised at: hw03.sml:145.53-145.86 *)

(* SECTION 6 *)
(* Purpose: Given a list and an int, the function will compute whether or not
* the int is the sum of any submultiset in the multiset.
* Examples: 
* subset_sum([4],4) ==> true
* subset_sum([1,2],3) ==> true
* subset_sum([1,2,3],3) ==> true
* subset_sum([1,2,3],5) ==> true
* subset_sum([1,2,3],6) ==> true
* *)
fun subset_sum (l : int list, s : int) : bool =
    case l of
         [] => (case s of
                    0 => true
                  | _ => false)
       | x::xs => (case subset_sum(xs, s-x) of 
                       true => true
                     | false => subset_sum(xs, s))

val true = subset_sum([4],4)
val true = subset_sum([1,2],3)
val true = subset_sum([1,2,3],3)
val true = subset_sum([1,2,3],5)
val true = subset_sum([1,2,3],6)
val true = subset_sum([1,2,3,50],51)
val true = subset_sum([1,2,3,50],52)
val true = subset_sum([1,2,3,50],53)
val false = subset_sum([2,3,50],54)
val false = subset_sum([1,2,3],7)

fun subset_sum_cert (l : int list, s : int) : bool * int list =
    case l of
         [] => (case s of
                    0 => (true,[])
                  | _ => (false,[]))
       | x::xs => let val (subsumP, you) = subset_sum_cert(xs,s-x)
                  in (case subsumP of 
                       true => (true,x::you)
                     | false => subset_sum_cert(xs, s))
                  end
(* The following function is a sufficient test for subset_sum_cert *)

fun subset_sum_dc (l : int list, s : int) : bool =
    let val (sumP, yoU) = subset_sum_cert(l,s)
    in
      case sumP of
           false => false
         | true => (case ((sum_list(yoU) = s) andalso (contained(yoU,l))) of
                        false => raise Fail "invalid certificate"
                      | true => true)
    end

val true = subset_sum_dc([4],4)
val true = subset_sum_dc([1,2],3)
val true = subset_sum_dc([1,2,3],3)
val true = subset_sum_dc([1,2,3],5)
val true = subset_sum_dc([1,2,3],6)
val true = subset_sum_dc([1,2,3,50],51)
val true = subset_sum_dc([1,2,3,50],52)
val true = subset_sum_dc([1,2,3,50],53)
val false = subset_sum_dc([2,3,50],54)
val false = subset_sum_dc([1,2,3],7)


