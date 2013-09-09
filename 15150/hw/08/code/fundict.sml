(********** TASK 4.1 **********)
functor FunDict (K:ORDERED) : DICT = 
struct
  structure Key = K
  datatype 'v func = Func of (Key.t -> 'v option)

  type 'v dict = 'v func

  val empty = Func (fn x => NONE)

  (* Purpose: to insert the k,v pair into the dictionary. *)
  fun insert (Func d) (k,v) = Func (fn x => 
    case Key.compare(k,x) of 
         EQUAL => SOME v 
       | _ => d x)

  (* Purpose: given a dict and a k, returns the value
   * the key is associated with, or returns NONE. *)
  fun lookup (Func d) (k) = d k
  
  (* Purpose: given a dict d and key k, returns the dictionary
   * where d k is none, but the rest of the dictionary operates fine. *)
  fun remove (Func d) (k) = Func (fn x => 
    case Key.compare(k,x) of 
         EQUAL => NONE 
       | _ => d x)

  (* Purpose: Given a function and a dictionary, returns the 
   * dictionary where each original value v becomes f v*)
  fun map (f) (Func d) = Func (fn x =>
    case d x of 
         SOME v => SOME (f v)
       | NONE => NONE)

  (* Purpose: Given a function and a dictionary, returns the
   * dictionary with only the values for which f v is true.*)
  fun filter (f) (Func d) = Func (fn x =>
    case d x of 
         SOME v => (case f v of true => SOME v | false => NONE)
       | NONE => NONE)
end
