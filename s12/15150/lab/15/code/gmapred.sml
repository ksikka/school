
functor GoogleMapReduce (Key : ORDERED) : 
sig
    structure D : DICT 
    val gmapred : ('a -> (D.Key.t * 'v) Seq.seq) (* keys are not nec unique *)
                -> ('v * 'v -> 'v) 
                -> 'a Seq.seq 
                -> 'v D.dict
end = 
struct
    structure D = Dict(Key)

    (* TASK 2.1 *)
    fun collect (combine : 'v * 'v -> 'v) (s : (Key.t * 'v) Seq.seq) : 'v D.dict =
        raise Fail "unimplemented"

    (* TASK 2.2 *)
    fun gmapred extract combine s = 
        raise Fail "unimplemented"

end

structure WordFreq =
struct
    open SeqUtils
    structure MR = GoogleMapReduce(StringLt)
    
    (* TASK 2.3: use this to test 
    fun wordCounts (d : string Seq.seq) : int MR.D.dict =
        MR.gmapred (fn s => Seq.map (fn w => (w, 1)) (SeqUtils.words s))
                   (op+)
                   d

    val [("1",1),("2",1),("document",2),("is",3),("this",2)] = 
        s2l
        (MR.D.toSeq (wordCounts (seq ["this is is document 1",
                                      "this is document 2"])))
        *)
end

structure Anagrams =
struct
    open SeqUtils

    val docs : string Seq.seq = seq [ 
    "Ethers are a class of organic compounds that contain an ether group -- an "
  ^ "oxygen atom connected to two alkyl or aryl groups -- of general formula R–O–R'.",
    "Elvis Aaron Presley (January 8, 1935 – August 16, 1977) was one of the most "
  ^ "popular American singers of the 20th century. A cultural icon, he is widely "
  ^ "known by the single name elvis. Born in Tupelo, Mississippi, Presley moved to "
  ^ "Memphis, Tennessee, with his family at the age of 13. He began his career "
  ^ "there in 1954 when Sun Records owner Sam Phillips, eager to bring the sound "
  ^ "of African-American music to a wider audience, saw in Presley the means to "
  ^ "realize his ambition.",
    "hI thEres do you livEs at three maiN streEt?",
    "Doctor Who is a British science fiction television programme produced by the "
  ^ "BBC. The programme depicts the adventures of a time-travelling humanoid alien "
  ^ "known as the doctorwho explores the universe in a sentient time machine "
  ^ "called the TARDIS that flies through time and space, whose exterior appears "
  ^ "as a blue police box. Along with a succession of companions, he faces a "
  ^ "variety of foes while working to save civilisations, help people, "
  ^ "and right wrongs.",
    "The series is a spin-off from Davies's 2005 revival of the long-running "
  ^ "science fiction programme Doctor Who. The show has shifted its broadcast "
  ^ "channel each series to reflect its growing audience, moving from BBC Three "
  ^ "to BBC Two to BBC One, and acquiring US financing in its fourth series. In "
  ^ "contrast to Doctor Who, whose target audience includes both adults and "
  ^ "children, torchwood is aimed at an older audience."]

    (* TASK 3.1 *)
    val anagrams : string Seq.seq -> (string Seq.seq) Seq.seq = 
        fn _ => raise Fail "unimplemented"

    (* strip off the keys and convert to lists for easy displaying *)
    val anagram_lists : string Seq.seq -> string list list = 
        s2l o Seq.map s2l o anagrams

    (* test using
       anagram_lists docs *)
        
end
