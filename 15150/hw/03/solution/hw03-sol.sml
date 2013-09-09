(* ---------------------------------------------------------------------- *)
(* Functions provided for you to use and analyze *)

fun inteq (l1 : int , l2 : int) : bool =
    case Int.compare (l1, l2)
     of EQUAL => true
      | _ => false

(* Purpose: add n to each element of the list l
 * Examples:
 *  add_to_each (nil, 7) ==> nil
 *  add_to_each (1::2::3::nil, 3) ==> 4::5::6::nil
 *  add_to_each (6::5::4::nil, ~3) ==> 3::2::1::nil
 *)
fun add_to_each (l : int list, n : int) : int list =
    case l of
        nil => nil
      | x::xs => x + n :: add_to_each (xs, n)

val [] = add_to_each ([], 7)
val [4, 5, 6] = add_to_each ([1, 2, 3], 3)
val [3, 2, 1] = add_to_each ([6, 5, 4], ~3)

(* Purpose: computes the sum of the int's in the list.  By convention an empty
 *          list has sum of 0.
 * Examples:
 *  sum_list nil ==> 0
 *  sum_tree 7::nil ==> 7
 *  sum_tree 3::2::nil ==> 3
 *)
fun sum_list (l : int list) : int =
    case l of
      nil => 0
    | n1::l' => n1 + sum_list l'

val 0 = sum_list []
val 7 = sum_list [7]
val 5 = sum_list [3, 2]

(* Purpose: Removes the first occurrence of the given int from the list if it
 *          is present, returning (true, modified_list). Otherwise,
 *          returns (false, nil).
 * Examples:
 *  removeIfPresent (2, [1,2,3,2]) => (true, [1,3,2])
 *  removeIfPresent (3, [4]) => (false, nil)
 *)
fun removeIfPresent (n : int, l : int list) : bool * int list =
    case l of
      nil => (false, nil)
    | x::l1 =>
        case inteq (n, x) of
          true => (true, l1)
        | false => case removeIfPresent (n, l1) of
                     (false, _) => (false, nil)
                   | (true, l2) => (true, x::l2)

val (true, [1, 3, 2]) = removeIfPresent (2, [1, 2, 3, 2])
val (false, []) = removeIfPresent (3, [4])

(* Purpose: determine if the first list viewed as a multi-set is contained
 *          in the second.
 * Examples:
 *  contained (nil, 1::3::nil) ==> true
 *  contained (3::nil, 1::3::nil) ==> true
 *  contained (3::1::nil, 1::3::nil) ==> false
 *)
fun contained (l1 : int list, l2 : int list) : bool =
    case l1 of
      nil => true
    | n::l1' => case removeIfPresent (n, l2) of
                  (true, l2') => contained (l1', l2')
                | (false, _) => false

val true = contained ([], [1, 3])
val true = contained ([3], [1, 3])
val true = contained ([3, 1], [1, 3])
val false = contained ([2, 2], [2, 3])
val false = contained ([2, 4], [2, 3, 5])

(* ---------------------------------------------------------------------- *)
(* Functions you must write *)

(* Functions for the tasks in section 2 *)

(* Purpose: Takes two lists, and returns a list such that the nth element in
 *          the first list is paired with the nth element from the second list.
 *          Truncates the returned list based on the shortest list length.
 * Examples:
 *  zip([1,2],["a","b"]) = [(1,"a"),(2,"b")]
 *  zip([1,2,3],["a"]) = [(1,"a")]
 *  zip([1,2],["a","b","c","d"]) = [(1,"a"),(2,"b")]
 *)
fun zip (l1 : int list, l2 : string list) : (int * string) list =
  case (l1,l2) of
    (nil, _) => nil
  | (_, nil) => nil
  | (x::xs, y::ys) => (x,y) :: zip (xs,ys)

(* Tests for zip *)
val [(1,"a"), (2,"b")] = zip ([1,2], ["a","b"])
val [(1,"a")] = zip ([1,2,3], ["a"])
val [(1,"a"), (2,"b")] = zip ([1,2], ["a","b","c","d"])

(* Purpose: Takes a list of tuples and returns a tuple of lists such that
 *          the first list is the list of first elements, and the second
 *          is the list of second elements.
 * Examples:
 *  unzip[(1,"a"),(2,"b")] = ([1,2],["a","b"])
 *  unzip[(42,"dragon"),(54,"llama"),(76,"muffin")] =
 *    ([42,54,76],["dragon","llama","muffin"])
 *)
fun unzip (l : (int * string) list) : int list * string list =
  case l of
    nil => (nil,nil)
  | (x1,x2)::xs => let
                     val (l1,l2) = unzip xs
                   in
                     (x1::l1, x2::l2)
                   end

(* Tests for unzip *)
val ([1,2], ["a","b"]) = unzip [(1,"a"), (2,"b")]
val ([42,54,76], ["dragon","llama","muffin"]) =
  unzip [(42,"dragon"), (54,"llama"), (76,"muffin")]

(* Functions for the tasks in section 3 *)

(* Purpose: Counts the number of sequential occurrences of x at the of l
 *  to compute the pair (tail, total) such that total is the sum of the count
 *  and acc and tail is the rest of the list. Note that this does not count
 *  *all* occurrences of x, just the ones that happen before the first
 *  occurrence of a different number.
 * Examples:
 *  lasHelp (2::nil, 1, 3) = (2::nil, 3)
 *  lasHelp (1::1::2::nil, 1, 3) = (2::nil, 5)
*)
fun lasHelp (l : int list, x : int, acc : int) : int list * int =
    case l of
      nil => (nil, acc)
    | y::l' => case inteq (x, y) of
                 true => lasHelp (l', x, acc + 1)
               | false => (l, acc)

(* Tests for lasHelp *)
val ([2], 3) = lasHelp ([2], 1, 3)
val ([2], 5) = lasHelp ([1,1,2], 1, 3)

(* Purpose: Count the number of occurrences of each element of a list, in order
 * Examples:
 *  look_and_say (1::nil) ==> 1::1::nil ("one one")
 *  look_and_say (1::1::2::1::3::nil) ==> 2::1::1::2::1::1::1::3::nil
 *                                ("two ones, one two, one one, one three")
 *  look_and_say nil ==> nil (we choose nil for ease of implementation)
*)
fun look_and_say (l : int list) : int list =
    case l of
      nil => nil
    | x::l' => let
                 val (tail, total) = lasHelp (l', x, 1)
               in
                 total :: x :: look_and_say tail
               end

(* Tests for look_and_say *)
val [1,1] = look_and_say [1]
val [2,1,1,2,1,1,1,3] = look_and_say [1,1,2,1,3]
val [] = look_and_say []

(* Functions for the tasks in section 5 *)

(* Purpose: computes the list of prefix sums for the argument list.  The
 *          i-th int in the result list is the sum of the first i int's
 *          in the argument list.
 * Examples:
 *  prefixSum nil ==> nil
 *  prefixSum (1::2::3::nil) ==> 1::3::6::nil
 *  prefixSum (5::3::1::nil) ==> 5::8::9::nil
 *)
fun prefixSum (l : int list) : int list =
    case l of
      nil => nil
    | x::xs => x :: add_to_each (prefixSum xs, x)

(* Tests for prefixSum *)
val [] = prefixSum []
val [1,3,6] = prefixSum [1,2,3]
val [5,8,9] = prefixSum [5,3,1]

(* Purpose: Given an int list, l, and an int, n, prefixSumHelp computes a list
 *          of the same length as l such that the i-th int in the result list
 *          is n more than the sum of the first i int's in the argument list.
 * Examples:
 *  prefixSumHelp (nil, 7) ==> nil
 *  prefixSumHelp (1::2::3::nil, 2) ==> 3::5::8::nil
 *  prefixSumHelp (5::3::1::nil, 0) ==> 5::8::9::nil
 *)
fun prefixSumHelp (l : int list, n : int) : int list =
    case l of
      nil => nil
    | x::xs => (n + x) :: prefixSumHelp (xs, n + x)

(* Tests for prefixSumHelp *)
val [] = prefixSumHelp ([], 7)
val [3,5,8] = prefixSumHelp ([1,2,3], 2)
val [5,8,9] = prefixSumHelp ([5,3,1], 0)

(* Purpose: computes the list of prefix sums for the argument list.  The
 *          i-th int in the result list is the sum of the first i int's
 *          in the argument list.
 * Examples:
 *  prefixSumFast nil ==> nil
 *  prefixSumFast (1::2::3::nil) ==> 1::3::6::nil
 *  prefixSumFast (5::3::1::nil) ==> 5::8::9::nil
 *)
fun prefixSumFast (l : int list) : int list =
    prefixSumHelp (l, 0)

(* Tests for prefixSumFast *)
val [] = prefixSumFast []
val [1,3,6] = prefixSumFast [1,2,3]
val [5,8,9] = prefixSumFast [5,3,1]

(* Functions for the tasks in section 6 *)

(* Purpose:
 *          assuming that
 *             (1) i >=0
 *             (2) k >= 0
 *             (3) i+k <= the length of l
 *          sublist(i,k,L) returns the k elements of L after and
 *          including the index i. Lists are indexed from 0.
 * Examples:
 *  sublist(0,0,[50]) ==> []
 *  sublist(1,1,[50,100]) ==> [100]
 *  sublist(3,3, [1,2,3,4,5,6]) ==> [4,5,6]
 *)
fun sublist (i : int, k : int, L : int list) : int list =
    case L of
        [] => []
      | x :: L' =>
        case i of
          0 => (case k of
                  0 => []
                | _ => x :: (sublist (i, k - 1, L')))
        | _ => sublist (i - 1, k, L')

(* tests for sublist *)
val [] = sublist(0, 0, [50])
val [100] = sublist(1, 1, [50,100])
val [4,5,6] = sublist(3, 3, [1,2,3,4,5,6])
val [3] = sublist(2,1, [1,2,3,4,5,6])

(* Purpose: sublist_check(i,k,L) is defined on all (int * int * int list)'s.
 *          When
 *             (1) i >= 0
 *             (2) k >= 0
 *             (3) i + k <= the length of l
 *          sublist_check(i,k,L) returns the k elements of L after and
 *          and including the index i. Otherwise it raises Fail.
 * Examples:
 *  sublist_check(10,10,nil) raises Fail with a helpful message
 *  sublist_check(3,5, [1,2,3,4,5]) raises Fail with a helpful message
 *  sublist_check(3,3, [1,2,3,4,5,6]) ==> [4,5,6]
 *  sublist_check(0,0,[50]) ==> []
 *  sublist_check(1,1,[50,100]) ==> [100]
 *)
fun sublist_check (i : int, k : int, L : int list) : int list =
    let
      val len = length L
    in
      case(i >= 0 andalso i <= len, i+k <= len, k >= 0 andalso k <= len) of
         (false,_,_) =>
            raise Fail "the index must be a natural number"
       | (_,false,_) =>
            raise Fail "the sublist must be entirely contained within the list"
       | (_,_,false) =>
            raise Fail "the sublist length must be a natural number"
       | _ => sublist (i,k,L)
    end

(* tests for sublist_check *)
val [] = sublist_check(0, 0, [50])
val [100] = sublist_check(1, 1, [50,100])
val [4,5,6] = sublist_check(3, 3, [1,2,3,4,5,6])
val [3] = sublist_check(2,1, [1,2,3,4,5,6])

(* Functions for the tasks in section 7 *)

(* Purpose: determine if there is a subset of the elements in the given list
 *          whose sum is s.
 * Examples:
 *  subset_sum (nil, 0) ==> true
 *  subset_sum (nil, 7) ==> false
 *  subset_sum (2::3::2::nil, 4) ==> true
 *  subset_sum (2::4::6::nil, 7) ==> false
 *)
fun subset_sum (l : int list, s : int) : bool =
    case l of
      nil => s = 0
    | n1::l' => subset_sum (l', s - n1) orelse subset_sum (l', s)

(* Tests for subset_sum *)
val true = subset_sum (nil, 0)
val false = subset_sum (nil, 7)
val true = subset_sum ([2,3,2], 4)
val false = subset_sum ([2,4,6], 7)
val true = subset_sum ([5,~2,1,~2],~3)

(* Purpose: determine if there is a subset of the elements in the given list
 * whose sum is s, and computes such a subset if it exists.  If no such subset
 * exists, the result will be the pair (false, nil)
 * Examples:
 *  subset_sum_cert (nil, 0) ==> (true, nil)
 *  subset_sum_cert (nil, 7) ==> (false, nil)
 *  subset_sum_cert (2::3::2::nil, 4) ==> (true, 2::2::nil)
 *  subset_sum_cert (2::4::6::nil, 7) ==> (false, nil)
 *)
fun subset_sum_cert (l : int list, s : int) : bool * int list =
    case l of
      nil => (inteq (s, 0), nil)
    | n1::l' => case subset_sum_cert (l', s - n1) of
                  (true, l1) => (true, n1 :: l1)
                | (false, _) => subset_sum_cert (l', s)

(* Tests for subset_sum_cred *)
val (true, []) = subset_sum_cert ([], 0)
val (false, []) = subset_sum_cert ([], 7)
val (true, [2,2]) = subset_sum_cert ([2,3,2], 4)
val (false, []) = subset_sum_cert ([2,4,6], 7)

(* Purpose: determine if there is a subset of the elements in the given list
 * whose sum is s using subset_sum_cred and checking the certificate.  If the
 * certificate is incorrect, a Fail exception is raised.
 * Examples:
 *  subset_sum_dc (nil, 0) ==> true
 *  subset_sum_dc (nil, 7) ==> false
 *  subset_sum_dc (2::3::2::nil, 4) ==> true
 *  subset_sum_dc (2::4::6::nil, 7) ==> false
 *)
fun subset_sum_dc (l : int list, s : int) : bool =
    case subset_sum_cert (l, s) of
      (true, l') => (case inteq (s, sum_list l') andalso contained (l', l) of
                       true => true
                     | false => raise Fail "invalid certificate")
    | (false, _) => false

(* Tests for subset_sum_dc *)
val true = subset_sum_dc ([], 0)
val false = subset_sum_dc ([], 7)
val true = subset_sum_dc ([2,3,2], 4)
val false = subset_sum_dc ([2,4,6], 7)

