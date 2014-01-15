(********** TASK 4.1 **********)
functor FunDict (K : ORDERED) : DICT =
struct
  structure Key = K
  
  datatype 'v func = Func of (Key.t -> 'v option)

  type 'v dict = 'v func

  (* Purpose: Returns a dictionary that contains no mappings *)
  val empty = Func (fn _ => NONE)

  (* Purpose: Inserts an element into a dictionary *)
  fun insert (Func f) (k, v) = 
    Func
    (fn k' =>
      case Key.compare (k, k') of
        EQUAL => SOME v
      | _ => f k')

  (* Purpose: Finds an element in a dictionary *)
  fun lookup (Func f) k = f k

  (* Purpose: Removes an element from a dictionary *)
  fun remove (Func f) k =
    Func
    (fn k' =>
      case Key.compare (k,k') of
        EQUAL => NONE
      | _ => f k')
  
  (* Purpose: Maps a function g over all values in a dictionary *)
  fun map g d =
    Func
    (fn k' =>
      case (lookup d k') of
        SOME x => SOME (g x)
      | _ => NONE)
  
  (* Purpose: Returns a dictionary consisting of all values satisfying
   * some predicate p.
   *)
  fun filter p d =
    Func
    (fn k' =>
      case (lookup d k') of
        SOME x =>
          (case (p x) of
             true => SOME x
           | false => NONE)
      | _ => NONE)
end