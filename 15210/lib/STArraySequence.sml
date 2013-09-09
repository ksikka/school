structure STArraySequence : ST_SEQUENCE =
struct
  structure Seq = ArraySequence
  type 'a seq = 'a Seq.seq
  exception Range
  datatype 'a update = INJ of (int * 'a) seq | INS of (int * 'a)
  type 'a updSeq = {updates : 'a update list, array : 'a seq}

  (* if (NONE,US) then in inefficient mode requiring all
     injectMods and insertMods to be applied before accessing.
     if (SOME(S) then S can be accessed and updated quickly *)
  type 'a stseq = ('a seq option * 'a updSeq) ref

  fun copy A = 
      Array.tabulate((Array.length A), (fn i => Array.sub(A,i)))

  fun applyUpdates {updates = U, array = A} =
  let
      val A' = copy A
      fun applyU nil = ()
	| applyU ((INJ I)::U) = (applyU U ;
            (Seq.iter (fn (_,(i,v)) => Array.update(A',i,v)) () I))
	| applyU (INS(i,v)::U) = (applyU U ; 
            Array.update(A',i,v))
  in
      (applyU U); A'
  end

  fun checkUpdate (r as ref(SOME A, U)) = 
      (r := (NONE, U); (A,U))
    | checkUpdate (ref(NONE,U)) = 
      let val A' = applyUpdates U
      in (A', U)
      end
 
  fun nth s i = 
     case (s) of
       (ref(SOME A, _)) => Array.sub(A,i)
     | (r as ref(NONE,U)) =>
         let val A' = applyUpdates U
         in (r := (SOME(A'), U); Array.sub(A',i))
         end

  fun inject IJ S =
    let 
	val (A, {updates=U, array=Ao}) = checkUpdate S
        val _ = Seq.iter (fn (_,(i,v)) => Array.update(A, i, v)) () IJ
    in 
	ref(SOME(A), {updates=INJ(IJ)::U, array=Ao})
    end

  fun update (i,v) S =
    let 
	val (A, {updates=U, array=Ao}) = checkUpdate S
        val _ = Array.update(A, i, v)
    in 
	ref(SOME(A), {updates=INS(i,v)::U, array=Ao})
    end

  fun fromSeq S = 
      ref (SOME(applyUpdates {updates=nil, array=S}), {updates=nil, array=S}) 

  fun toSeq (r as ref(SOME A, U)) = copy A
    | toSeq (ref(NONE,U)) = applyUpdates U

end
