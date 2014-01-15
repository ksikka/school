structure Default =
struct

  structure Seq = ArraySequence
  
  structure IntHashKey : HASHKEY =
  struct
    type t = int
    fun compare(a,b) = Int.compare(a,b)
    fun eq(a,b) = (compare(a,b)=EQUAL)
    fun hash(i) = Word.toIntX(Word.*(0wx50356BCB,Word.fromInt i))
  end

  structure RealHashKey : HASHKEY =
  struct
    type t = real
    fun compare(a,b) = Real.compare(a,b)
    fun eq(a,b) = (compare(a,b)=EQUAL)
    fun hash(v) = 
	let
	    val {man=m,exp=_} = Real.toManExp v
	    fun ihash(i) = Word.toIntX(Word.*(0wx50356BCB,Word.fromInt i))
	in
	    ihash(round(m * 1000000000.0))
	end
  end

  structure IntIntHashKey : HASHKEY =
  struct
    type t = (int * int)
    fun compare((a1,a2),(b1,b2)) = 
     case Int.compare(a1,b1) of
         LESS => LESS
       | EQUAL => Int.compare(a2,b2)
       | GREATER => GREATER

    fun eq(a,b) = (compare(a,b)=EQUAL)
    fun hash(i,j) = 
	Word.toIntX(Word.*(Word.+(Word.fromInt i,  0wxB),
			   Word.*(0wx50356BCB,
				  (Word.+(Word.fromInt j, 0wx17)))))
  end

  structure StringHashKey : HASHKEY =
  struct
    type t = string
    fun compare(a,b) = String.compare(a,b)
    fun eq(a,b) = (compare(a,b)=EQUAL)
    fun hash(s) = 
	let
	    fun subs i = Word.fromInt (Char.ord (String.sub(s,i)))
	    val c = Word.fromInt 65599
	    fun hash'(i,h) = 
		if (i < 0) then h
		else hash'(i-1, (subs i) + h * c)
	in Word.toIntX (hash'((String.size s)-1, Word.fromInt 0)) end
  end

  functor TreapTable(structure HashKey : HASHKEY) : TABLE =
       BSTTable(structure Tree = Treap(HashKey) 
                structure Seq = Seq)

  structure IntTable = TreapTable(structure HashKey = IntHashKey)
  structure RealTable = TreapTable(structure HashKey = RealHashKey)
  structure StringTable = TreapTable(structure HashKey = StringHashKey)

  structure IntSet = IntTable.Set;
  structure RealSet =RealTable.Set;
  structure StringSet = StringTable.Set;

(*
  structure IntOrderedTable = BSTOrderedTable (structure Tree = IntTreap);
  structure RealOrderedTable = BSTOrderedTable (structure Tree = RealTreap);
  structure StringOrderedTable = BSTOrderedTable (structure Tree = StringTreap);
*)

  structure IntOrdered : ORDERED = IntHashKey
  structure RealOrdered : ORDERED = RealHashKey
  structure StringOrdered : ORDERED = StringHashKey
  structure IntPQ = LeftistHeap(IntOrdered)
  structure RealPQ = LeftistHeap(RealOrdered)
  structure StringPQ = LeftistHeap(StringOrdered)

structure StringSeqHashKey : HASHKEY =
struct
    structure Seq = ArraySequence
    type t = string Seq.seq
    (* Create lexicographical comparator for string sequences *)
    val stringseqcomp = Seq.collate String.compare 
    fun compare(a,b) = stringseqcomp(a,b)
    fun eq(a,b) = (compare(a,b)=EQUAL)
    fun hash(i) = Seq.reduce Int.max 0 (Seq.map StringHashKey.hash i)
end

structure StringSeqOrdered : ORDERED = StringSeqHashKey
structure StringSeqTreap = Treap (StringSeqHashKey);
structure StringSeqTable = BSTTable (structure Tree = StringSeqTreap
                                     structure Seq = ArraySequence)
end
