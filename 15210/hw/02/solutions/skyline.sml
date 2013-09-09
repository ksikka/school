functor Skyline (S : SEQUENCE) : SKYLINE =
struct
  structure Seq = S 
  open Seq

  open Primitives

  fun scanI f b s =
      let val (s', r) = scan f b s
      in append (drop(s', 1), singleton r)
      end

  fun skyline S =
      let
        fun base (l, h, r) = %[(l, h), (r, 0)]
        fun combine (s1, s2) =
            let
              val s1 = map (fn (x,y) => (x, y, ~1)) s1
              val s2 = map (fn (x,y) => (x, ~1, y)) s2      
              val ss = merge (fn (a,b) => Int.compare(#1 a, #1 b)) s1 s2
              
              fun binOp ((lx,ly1,ly2),(rx,ry1,ry2)) =
                  (rx, if ry1 = ~1 then ly1 else ry1,
                       if ry2 = ~1 then ly2 else ry2)
              val scn = scanI binOp (~1, ~1, ~1) ss
              val res = map (fn (x,y1,y2) => (x, Int.max(y1,y2))) scn 
              
              fun change 0 = true
                | change i = (#2 (nth res (i-1)) <> #2 (nth res i))
              val changes = tabulate change (length res)
              val zip = map2 (fn x => x) res changes
            in
              map (fn (x,_) => x) (filter (fn (_,b) => b) zip)
            end
      in
        reduce combine (empty ()) (map base S)
      end
end
