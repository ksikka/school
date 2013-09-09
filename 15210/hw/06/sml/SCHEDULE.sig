signature SCHEDULE =
sig
  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq
  type exam

  val scheduleExams : exam seq seq -> exam seq seq
end
