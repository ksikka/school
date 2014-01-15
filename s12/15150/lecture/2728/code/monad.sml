signature MONAD = 
sig
    type 'a comp
    val return : 'a -> 'a comp
    val >>= : 'a comp * ('a -> 'b comp) -> 'b comp
end

signature STATE_MONAD = 
sig
    include MONAD
    type state 
    val get  : state comp
    val set  : state -> unit comp
    val run  : 'a comp -> state -> 'a
end

functor StorePassing(A : sig type state end) : STATE_MONAD =
struct
    type state = A.state
    type 'a comp = state -> 'a * state
    fun return x = fn s => (x,s)
    fun >>= (c : state -> 'a * state, f : 'a -> (state -> 'b * state)) : state -> 'b * state = 
        fn s => let val (v,s) = c s in f v s end
    val get : state -> state * state = fn s => (s , s)
    fun set (news : state) : state -> unit * state = fn _ => (() , news)
    fun run f s = case (f s) of (v , _) => v
end
