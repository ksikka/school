structure Base =
struct
  datatype t = A | T | C | G

  fun eq (b1 : t, b2 : t) : bool = b1 = b2

  fun toString b = case b of A => "A" | T => "T" | C => "C" | G => "G"
  
  (* an arbitrary total order over bases *)
  fun compare (A : t, A : t) : order = EQUAL
      | compare (T, T) = EQUAL | compare (C, C) = EQUAL | compare (G, G) = EQUAL
      | compare (A, _) = LESS | compare (_, A) = GREATER
      | compare (T, _) = LESS | compare (_, T) = GREATER
      | compare (C, _) = LESS | compare (_, C) = GREATER

  (* converts a string to a list of bases *)
  fun dnaFromString (s : string) : t list =
      List.map (
           fn #"A" => A
            | #"T" => T
            | #"C" => C
            | #"G" => G
            | _ => raise Fail "Bad base.") (String.explode s)

  (* converts a list of bases to a string *)
  fun dnaToString (b : t list) : string =
      List.foldr (fn (x, y) => (toString x) ^ y) "" b

  (* Given DNA strands a and b, returns the longer one. *)
  fun longerDnaOf (a : t list, b : t list) : t list =
      case (List.length a <= List.length b)
         of true => b
          | false => a
end

structure DnaPairOrder : ORDERED =
struct
    type t = (Base.t list * Base.t list)

    val compareDna = List.collate Base.compare

    fun compare ((a, b), (c, d) : t) =
        case compareDna (a, c)
         of EQUAL => compareDna (b, d)
          | c => c
end

signature LCS =
sig
  (* given two list of bases, computes the longest common subsequence
   * (eg, drops the minimum number of elements from both lists such that
   * the lists become equal) *)
  val lcs : (Base.t list * Base.t list) -> Base.t list
end

structure SlowLCS : LCS =
struct
  fun lcs (s1 : Base.t list, s2 : Base.t list)
      : Base.t list =
    case (s1, s2)
       of ([], _) => []
        | (_, []) => []
        | (x :: xs, y :: ys) =>
            case Base.eq (x, y)
             of true => x :: lcs (xs, ys)
              | false => Base.longerDnaOf (
                  lcs (s1, ys),
                  lcs (xs, s2))
end
