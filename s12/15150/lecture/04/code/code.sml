(* Purpose: compute the length of the list l *)
fun length (l : int list) : int =
    case l
     of [] => 0
      | x :: xs => 1 + length xs

val 5 = length (1 :: (2 :: (3 :: (4 :: (5 :: [])))))

(* Purpose: sum the numbers in the list *)
fun sum (l : int list) : int =
    case l
     of [] => 0
      | x :: xs => x + sum xs

val 15 = sum [1,2,3,4,5]

(* Purpose: add amount to each salary in the list *)
fun rB (l : int list, amount : int) : int list =
    case l
     of [] => []
      | x::xs => (x + amount) :: rB (xs,amount)

val [1001, 1002, 1003, 1005] = rB ([1, 2, 3, 5], 1000)

