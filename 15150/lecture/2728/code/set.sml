signature SETCORE =
sig
  structure El : ORDERED

  type set

  val empty  : set
  val insert : set -> El.t -> set
  val member : set -> El.t -> bool

  datatype lview = Nil | Cons of El.t * set
  val show : set -> lview

  val mapreduce : (El.t -> 'b) -> 'b -> ('b * 'b -> 'b) -> set -> 'b
end

signature SET = 
sig
    include SETCORE
    val exists : (El.t -> bool) -> set -> bool
    val all : (El.t -> bool) -> set -> bool
    val fromList : El.t list -> set
end

functor SetCore (E : ORDERED) : SETCORE =
struct
    (* ENH: this is a really bad implementation, time-wise; use a tree! *)
    structure El = E
    datatype slowset = S of E.t list
    type set = slowset
    fun insert (S xs) x = S (x :: xs)
    fun member (S s) x = List.exists (fn y => case E.compare (x, y) of EQUAL => true | _ => false) s
    val empty = S []
    datatype lview = Nil | Cons of El.t * set
    fun show (S l) = case l of
        [] => Nil
      | x :: xs => Cons (x , S xs)
    fun mapreduce (f : El.t -> 'b) (n : 'b) (c : 'b * 'b -> 'b) (S l) : 'b = 
        case l of 
            [] => n
          | x :: xs => c (f x , mapreduce f n c (S xs))
end

functor SetUtils(S : SETCORE) : SET =
struct 
    open S
    fun fromList (l : El.t list) = List.foldr (fn (x,y) => S.insert y x) S.empty l
    fun exists f s = S.mapreduce f false (fn (x,y) => x orelse y) s
    fun all f s = S.mapreduce f true (fn (x,y) => x andalso y) s
end

functor Set(E : ORDERED) : SET = SetUtils(SetCore(E))

functor SetMonadUtils(A : sig 
                              structure S : SET
                              structure T : MONAD
                          end) : sig
                                     val existsM : (A.S.El.t -> bool A.T.comp) -> A.S.set -> bool A.T.comp
                                     val allM : (A.S.El.t -> bool A.T.comp) -> A.S.set -> bool A.T.comp
                                 end
=
struct
    open A
    open T
    infix 7 >>=

    fun existsM (f : S.El.t -> bool T.comp) (s : S.set) : bool T.comp = 
        case S.show s of 
            S.Nil => return false
          | S.Cons(c1, cs) => 
                f c1 >>= 
                (fn true => return true
                  | false => existsM f cs)

    fun allM (f : S.El.t -> bool T.comp) (s : S.set) : bool T.comp = 
        case S.show s of 
            S.Nil => return true
          | S.Cons(c1, cs) => 
                f c1 >>= 
                (fn false => return false
                  | true => allM f cs)
end
