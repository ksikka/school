(* Functions provided for you to use and analyze for this assignment *)
(* Purpose: test two ints for equality
 * Examples:
 *
 * inteq(~7, 7) == false
 * inteq(~7, 0) == false
 * inteq(~7, ~7) == true
 *)
fun inteq (l1 : int , l2 : int) : bool =
    case Int.compare (l1,l2)
     of EQUAL => true
      | _ => false

val false = inteq(~7, 7)
val false =inteq(~7, 0)
val true = inteq(~7, ~7)


(* Purpose: add n to each element of the list l
 * Examples:
 *
 * add_to_each (nil, 7) == nil
 * add_to_each (1::2::3::nil, 3) == 4::5::6::nil
 * add_to_each (6::5::4::nil, ~3) == 3::2::1::nil
 *)
fun add_to_each (l : int list, n : int) : int list =
    case l of
        nil => nil
      | x::xs => x + n :: add_to_each (xs, n)

val nil = add_to_each (nil, 7)
val 4::5::6::nil = add_to_each (1::2::3::nil, 3)
val 3::2::1::nil = add_to_each (6::5::4::nil, ~3)

(* Purpose: computes the sum of the elements in a list of ints.
 *
 * Examples:
 *  sum_list nil == 0
 *  sum_tree 7::nil == 7
 *  sum_tree 3::2::nil == 3
 *)
fun sum_list (l : int list) : int =
    case l of
        nil => 0
      | n1::l' => n1 + (sum_list l')

val 0 = sum_list nil
val 7 = sum_list (7::nil)
val 5 = sum_list (3::2::nil)

(* Purpose: Removes the first occurrence of the given int from the list if it
 * is present, returning (true, modified_list). Otherwise, returns (false, nil).
 *
 * Examples:
 *  removeIfPresent (2, [1,2,3,2]) == (true, [1,3,2])
 *  removeIfPresent (3, [4]) == (false, nil)
 *)
fun removeIfPresent (n : int, l : int list) =
    case l
     of nil => (false, nil)
      | (x :: l1) =>
        case inteq(n,x) of
            true => (true, l1)
          | false => case removeIfPresent (n, l1) of
                         (false, _) => (false, nil)
                       | (true, l2) => (true, x :: l2)

val (true, [1,3,2]) = removeIfPresent (2, [1,2,3,2])
val (false, nil) = removeIfPresent (3, [4])

(* Purpose: determine if the first list viewed as a multi-set is contained
 * in the second.
 *
 * Examples:
 *  contained (nil, 1::3::nil) == true
 *  contained (3::nil, 1::3::nil) == true
 *  contained (3::1::nil, 1::3::nil) == false
 *)
fun contained (l1 : int list, l2 : int list) : bool =
    case l1 of
        nil => true
      | n::l1' => (case removeIfPresent (n, l2)
                    of (true, l2') => contained (l1', l2')
                     | (false, _) => false)

val true = contained (nil, 1::3::nil)
val true = contained (3::nil, 1::3::nil)
val true = contained (3::1::nil, 1::3::nil)
val false = contained (2::2::nil, 2::3::nil)
val false = contained (2::4::nil, 2::3::5::nil)
