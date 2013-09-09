structure Hi = struct
  structure LH = LeftistHeap(Default.IntOrdered)

  structure Seq = ArraySequence

  val s = Seq.% [1,2,3,4,5,6,7,8]
  val t = Seq.reduce (fn (x,y) => LH.meld x y) (LH.empty ()) (Seq.map (fn k => LH.singleton(k,())) s)



end
