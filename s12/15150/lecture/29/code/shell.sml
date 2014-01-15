(* some char stream utils *)
structure Shell : 
sig
    include MATCH

    type pipeline = char Stream.stream -> char Stream.stream 

    val firstnat : char Stream.stream
                 -> (int * char Stream.stream) option
    val flatten : string Stream.stream -> char Stream.stream
    val lines : char Stream.stream -> string Stream.stream (* leaves the newline at the end *)
    val printstream : char Stream.stream -> unit
    val echo : string -> char Stream.stream
    val cat : string -> pipeline
    val catLines : string list -> (char Stream.stream -> string Stream.stream)

    val |> : ('a -> 'b) * ('b -> 'c) -> 'a -> 'c


    val > : ('a -> char Stream.stream) * string -> ('a -> char Stream.stream) (* pipe to file, and return the empty stream on stdout *)
    val shell : pipeline -> unit
    val summarize : ('a Stream.stream -> 'b) -> 'a Stream.stream -> 'b Stream.stream 
end = 
struct
    open Stream
    open Match

    type pipeline = char stream -> char stream 

    (* return SOME (i , s) iff there is a nat at the front and s is what's leftover *)
    fun firstnat (c : char stream) : (int * char stream) option =
        let 
            fun loop c : string * char stream = 
                case expose c of 
                    Nil => ("" , c)
                  | Cons (first,rest) => 
                    (case Char.isDigit first of
                         true => let val (front , back) = loop rest
                                 in (str first ^ front , back) end
                       | false => ("" , c))
            val (firststring , rest) = loop c 
        in
            case Int.fromString firststring of
                NONE => NONE
              | SOME firstint => SOME (firstint , rest)
        end

    fun flatten (s : string stream) : char stream = 
        stream (fn () => case expose s of 
                Nil => Nil
              | Cons (x , xs) => case String.explode x of 
                    [] => expose (flatten xs)
                  | (f :: r)  => Cons (f , flatten (stream (fn () => Cons (String.implode r , xs)))))

    val lines : char stream -> string stream = 
           grep (Times (Star (NotChar #"\n") , Char #"\n"))

    (* assumes stream is finite; 
       buffers and actually prints at the end *)
    fun printstream (c : char stream) : unit = List.app (fn x => print (str x)) (Stream.toList c)

    val echo : string -> char stream = Stream.fromList o String.explode 
    fun cat  (f : string) : 'a -> char stream = fn _ => memo (Process.file f)

    fun catLines fs = fn _ => 
        List.foldr (fn (f , r) => append (memo (Process.fileLines f)) r)
                   (stream (fn () => Nil)) 
                   fs

    infixr 3 |> 
    fun f |> g = g o f

    infixr 3 > (* assumes finite *)
    fun (c : 'a -> char stream) > (f : string) : 'a -> char stream = 
        fn a =>
        let val outf = TextIO.openOut f
            val chunk = 1000
            fun pr s n =
                let val n = (case n of 0 => (TextIO.flushOut outf ; chunk) | _ => n - 1)
                in case expose s of
                    Nil => ()
                  | Cons (x,s) => (TextIO.output (outf , str x);
                                   pr s (n - 1))
                end
            val () = pr (c a) chunk
            val () = TextIO.flushOut outf
        in stream (fn () => Nil) end
    
    fun shell (p : pipeline) = printstream (p (memo Process.stdin))
    fun summarize f = 
        f |> (fn x => stream (fn () => Cons (x , stream (fn () => Nil))))

end

structure GrepExample =
struct
    open Stream
    open Shell
    infixr 3 |> 
    infixr 3 > 

    val nats = selfreferential (fn ns => stream (fn () => (Cons (0 , map (fn x => x + 1) ns))))

    val nl : string stream -> string stream = fn s =>
        map (fn (x,y) => "      " ^ x ^ " " ^ y) 
            (zip (map (fn x => Int.toString (x + 1)) nats ,
                  s))

    fun linesMatching (r : regexp) : regexp = (Times (Star (NotChar #"\n") , 
                                                      Times(r , 
                                                            Times (Star (NotChar #"\n") , 
                                                                   Char #"\n"))))

    val example : pipeline =

        (* cat ../../asgn/hw/08/code/ratplane.sml | grep 'dist' | nl | head -n 3 *)

        cat "../../asgn/hw/08/code/ratplane.sml" 
      |> grep (linesMatching (String "dist")) 
      |> nl 
      |> truncate 3 |> flatten

end

structure CompressDna =
struct        
    open Stream
    open Shell
    infixr 3 |> 
    infixr 3 > 

    fun compressdna (inf : string) (outf : string) = 
        shell (cat inf
               |> looksay (op=)
               |> map (fn (count,chr) => 
                        (case count of 
                             1 => "" 
                           | _ => Int.toString count)
                        ^ (str chr)) 
               |> flatten
               >  outf)

    fun exp s n = 
        case n of 0 => ""
      | _ => s ^ (exp s (n - 1))

    (* assumes file is well-formed *)
    fun parsebase (c : char stream) : (string * char stream) option = 
        case firstnat c of 
            NONE => (* must be either done or a single base *)
                (case expose c of
                     Nil => NONE
                   | Cons (base , rest) => SOME (str base , rest))
          | SOME (i , rest) => 
                     (case expose rest of
                          Nil => raise Fail "ill-formed file"
                        | Cons (base , rest) => SOME (exp (str base) i , rest))

    fun decompressdna (inf : string) (outf : string) = 
        shell (cat inf
               |> unfold parsebase
               |> flatten
               >  outf)


    (* useful for processing the downloaded DNA *)
    fun removenewlines inf outf = 
        shell (cat inf
               |> filter (fn x => x <> #"\n")
               >  outf)

    (* for testing *)
    val stdinLines = memo Process.stdinLines
    val stdin = memo Process.stdin
end

