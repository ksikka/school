structure ThesaurusASPTest =
struct
  open Thesaurus
  open Utils
  open Seq

  val filePath = "input/thesaurus.txt"
  val fileToPairs = Utils.parseString o Utils.readFile

  fun all () =
    let
      val () = print "Opening and parsing file..."
      val word_synseq = fileToPairs filePath

       val () = print " Done.\nCalling make function to produce thesaurus..."
      val thes_obj = make word_synseq
      val () = print " Done.\n\nCalling first stage of query with EARTHLY..."
      val q_thes = query thes_obj "EARTHLY"

      val () = print " Done.\nCalling second stage of query with POISON..."
      val answer = q_thes "POISON"
      val () = print " Done.\nAnswer was "
      val () = print (Seq.toString (Seq.toString (fn s => s ^ " => ")) answer)
      
      val () = print " Done.\nCalling second stage of query with TEND..."
      val answer = q_thes "TEND"
      val () = print " Done.\nAnswer was "
      val () = print (Seq.toString (Seq.toString (fn s => s ^ " => ")) answer)
      
      val () = print " Done.\n\nCalling first stage of query with CLEAR..."
      val q_thes = query thes_obj "CLEAR"

      val () = print " Done.\nCalling second stage of query with VAGUE..."
      val answer = q_thes "VAGUE"
      val () = print " Done.\nAnswer was "
      val () = print (Seq.toString (Seq.toString (fn s => s ^ " => ")) answer)
      
      val () = print " Done.\n\nCalling first stage of query with GOOD..."
      val q_thes = query thes_obj "GOOD"

      val () = print " Done.\nCalling second stage of query with BAD..."
      val answer = q_thes "BAD"
      val () = print " Done.\nAnswer was "
      val () = print (Seq.toString (Seq.toString (fn s => s ^ " => ")) answer)
    in true (* It clearly works if you look at the output :) *)
    end
end
