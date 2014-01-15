structure Schedule : SCHEDULE =
struct
  type exam = string
  structure C : COLORING = MISColoring
  open C

  structure STbl = Default.StringTable
  structure NTbl = Default.IntTable
  structure NNTbl = Default.TreapTable(structure HashKey = Default.IntIntHashKey)

  (* Takes a seq of exams and returns the X-product, without
     entries which equal each other. *)
  fun examSeqXProd exams =
    let
      fun examToOtherExams exams e =
        Seq.map (fn e2 => if e < e2 then (e,e2) else (e2,e)) exams
    in
      Seq.filter (fn (x,y) => x <> y)
        (Seq.flatten (Seq.map (examToOtherExams exams) exams))
    end

  (* Dedupe a seq of strings*)
  val dedupeS = STbl.Set.toSeq o STbl.Set.fromSeq
  
  (* Dedupe a seq of int tuples *)
  val dedupeNN = NNTbl.Set.toSeq o NNTbl.Set.fromSeq

  (* The map function takes ('a * int) *)
  fun mapWithIndexes f S = Seq.map2 f S (Seq.tabulate (fn x => x) (Seq.length S))
   
  (* Schedules exams using MIS *)
  fun scheduleExams examsPerStudent =
    (* Map to ints, turn it into a graph,
         and call graphcolor on it. *)
    let
      (* Remove duplicates *)
      val examNames = dedupeS (Seq.flatten examsPerStudent)
      val n = Seq.length examNames

      (* Map to integers from 0 to n-1 *)
        (* Create mapping *)
      val nameIntPairs = mapWithIndexes (fn x => x) examNames
      val examIntMap = STbl.fromSeq nameIntPairs
      val intExamMap = NTbl.fromSeq (Seq.map (fn (a,b) => (b,a)) nameIntPairs)
        (* Apply the mapping *)
      val intsPerStudent = Seq.map (Seq.map (Option.valOf o (STbl.find
      examIntMap))) examsPerStudent
      
      (* Get a list of exam-pairs, feed to graphColor, and format the output *)
        val inputToEdgeSeq = dedupeNN o Seq.flatten o (Seq.map examSeqXProd)
        val resToOutputStrctr = (Seq.collect Int.compare) o
                                              (Seq.map (fn (a,b) => (b,a)))
        val intToStrAdjList = Seq.map (fn (c,ints) => Seq.map
                                   (Option.valOf o (NTbl.find intExamMap)) ints)
      val edgePairs = inputToEdgeSeq intsPerStudent
      val misResult = graphColor edgePairs
      val intColoring = resToOutputStrctr edgePairs 
    in  intToStrAdjList intColoring
    end

end
