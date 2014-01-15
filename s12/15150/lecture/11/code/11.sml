
fun sum (l : int list) : int =
   case l of
      [] => 0
    | x :: xs => x + sum xs

local 
    fun sumTC (l : int list, s : int) : int = 
        case l of 
            [] => s
          | x :: xs => sumTC (xs , s + x)
in 
    fun sum' (l : int list) : int = sumTC (l , 0)
end


local 
    fun sum_cont (l : int list) (k : int -> int) : int = 
        case l of 
            [] => k 0
          | x :: xs => sum_cont xs (fn a => k(x + a))
in
    fun sum'' l = sum_cont l (fn x => x)
end
