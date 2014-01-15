structure SeamFinder :
sig
  structure Seq : SEQUENCE
  type 'a seq = 'a Seq.seq

  type pixel = { r : real, g : real, b : real }
  type image = { width : int, height : int, data : pixel seq seq }
  type gradient = real

  val generateGradients : image -> gradient seq seq
  val findSeam : image -> int seq
end
=
struct
  structure Seq = ArraySequence
  open Seq

  type pixel = { r : real, g : real, b : real }
  type image = { width : int, height : int, data : pixel seq seq }
  type gradient = real

  fun generateGradients {width, height, data} : gradient seq seq =
      let
        fun sq (v : real) = v * v
        fun d ({r=r1, g=g1, b=b1}, {r=r2, g=g2, b=b2}) =
            sq (r2 - r1) + sq (g2 - g1) + sq (b2 - b1)
        fun p (i, j) = nth (nth data i) j
        fun gradient i j =
            if i = height - 1 then 0.0
            else if j = width - 1 then Real.posInf
            else let
              val dx = d (p (i, j), p (i, j+1))
              val dy = d (p (i, j), p (i+1, j))
            in Math.sqrt (dx + dy)
            end
      in tabulate (fn i => tabulate (gradient i) width) height
      end

  local
    type colcost = { cost : real, col : int }
    fun minCost (a as {cost=c1, ...}, b as {cost=c2, ...}) : colcost =
        if c1 < c2 then a else b
    val minCostAll = reduce minCost {col=(~1), cost=Real.posInf}
  in
    fun findSeam (img as {width, height, ...}) : int seq =
        let
          (* Bottom-up dynamic programming solution iterates across
           * the matrix of gradients and calculates the minimum cost
           * to reach each pixel. Builds a continuation function to
           * find the actual seam given the bottom-most column index.
           *)
          fun dp ((prevRow, buildSeam), gradients) =
              let
                fun nth' i = nth prevRow i handle Range => Real.posInf
                fun colcost i = {col=i, cost=nth' i}
                fun bestAbove c = minCostAll (map colcost (%[c-1, c, c+1]))
                fun bestCost j = #cost (bestAbove j) + nth gradients j
                val newRow = tabulate bestCost width
              in (newRow, buildSeam o (fn c::cs => #col (bestAbove c)::c::cs))
              end

          val gradients = generateGradients img

          (* First row of gradients and the identity function *)
          val init = (nth gradients 0, fn x => x)
          val (lastRow, buildSeam) = iter dp init (drop (gradients, 1))

          (* Find the last column and call the continuation on it *)
        in % (buildSeam [argmax (fn (x,y) => Real.compare (y,x)) lastRow])
        end
  end
end
