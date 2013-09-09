structure SerializeBool : SERIALIZABLE =
struct
    type t = bool

    fun write b =
        case b
         of true => "(TRUE)"
          | false => "(FALSE)"

    fun read s =
        case Util.peelOff("(TRUE)",s)
         of SOME s => SOME (true,s)
          | NONE =>
            (case Util.peelOff("(FALSE)",s)
              of SOME s => SOME (false,s)
               | NONE => NONE)
end
