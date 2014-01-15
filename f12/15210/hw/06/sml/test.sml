structure AllTest : TESTS =
struct
  structure A = BridgesTest(Bridges(STArraySequence))
  structure B = MISTest
  structure C = MISColoringTest(SequenceMIS(STArraySequence))
  fun all () = if A.all() then
                 if B.all() then
                   if C.all() then true
                   else let val () = print "C" in false end
                 else let val () = print "B" in false end
               else let val () = print "A" in false end
end
