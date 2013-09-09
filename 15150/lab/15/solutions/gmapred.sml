
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

    fun collect (combine : 'v * 'v -> 'v) (s : (Key.t * 'v) Seq.seq) : 'v D.dict =
        Seq.mapreduce (fn (k,v) => D.insert D.empty (k , v))
                      D.empty
                      (D.merge combine)
                      s

    fun gmapred extract combine s = 
        collect combine (Seq.flatten (Seq.map extract s))
end

structure WordFreq =
struct
    open SeqUtils
    structure MR = GoogleMapReduce(StringLt)
    
    fun wordCounts (d : string Seq.seq) : int MR.D.dict =
        MR.gmapred (fn s => Seq.map (fn w => (w, 1)) (SeqUtils.words s))
                   (op+)
                   d

    val [("1",1),("2",1),("document",2),("is",3),("this",2)] = 
        s2l
        (MR.D.toSeq (wordCounts (seq ["this is is document 1",
                                                    "this is document 2"])))
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

    structure SortChar = Sort(struct type t = char val compare = Char.compare end)
    val key : string -> string = 
        SeqUtils.implode o SortChar.sort o SeqUtils.explode
        
    structure MR = GoogleMapReduce(StringLt)
    structure S = Set(StringLt)

    val anagrams : string Seq.seq -> (string Seq.seq) Seq.seq = 
        (* insist on more than 1 word *)
        Seq.filter (fn v => Seq.length v > 1)  o

        (* convert dicts/sets to sequences *)
        MR.D.valueSeq o MR.D.map S.toSeq o

        (* do a gmapred to compute a set of anagrams for each word,
           keyed by the sorted version of the word *)
        MR.gmapred (fn page => Seq.map (fn w => (key w, S.insert S.empty w))
                                       (SeqUtils.words page))
                   S.union
                   

    (* strip off the keys and convert to lists for easy displaying *)
    val anagram_lists : string Seq.seq -> string list list = 
        s2l o Seq.map s2l o anagrams
        
end
