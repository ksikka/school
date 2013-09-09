
structure Solars =
struct

  local
      (* rather inefficient. *)
      structure II = IntInf

      fun pow (f : II.int, 0) = 1
        | pow (f, n) = f * pow (f, n-1)

      (* FIXME: uses floating point arithmetic *)
      fun digits x = Real.floor (Math.log10 (Real.fromLargeInt (II.abs x)))

      (* parses a pair in "scientific notation" into a Plane.scalar
       * eg sci (412, 13) == 4.12E13
       *)
      fun sci (0, _) = Plane.s_zero
        | sci (f : II.int, exp : int) =
          let val digs = digits f
              val f = Plane.s_fromRatio (f, pow (10, digs))
              val order = Plane.s_pow (Plane.s_fromInt 10, exp)
          in Plane.s_times (f, order)
          end

      val zero : II.int * int = (0,0)

      fun I x = (x, digits x)

      (* fun pb (mass, pos, vel) =
       *     print (Plane.s_toString mass ^ " " ^ Plane.pointToString pos ^ " " ^
       *            Plane.vecToString vel ^ "\n") *)

      fun b (mass : II.int * int) (dist : II.int * int) (vel : II.int * int) =
          (sci mass,
           Plane.fromcoord (Plane.s_zero, sci dist),
           Plane.--> (Plane.origin, Plane.fromcoord (sci vel, Plane.s_zero)))

  in

    val sun = b (198892, 30) zero zero              (* sun *)
    val mercury = b (33022, 23) (579091, 10) (I 47870)  (* mercury *)
    val venus = b (48685, 24) (~10820893, 11) (I ~35020)    (* venus *)
    val earth = b (59736, 24) (~14960, 11) (I ~29780)    (* earth *)
    val mars = b (64185, 23) (2279391, 11) (I 24077)     (* mars *)
    val jupiter = b (18986, 27) (7785472, 11)  (I 13070)  (* jupiter *)
    val saturn = b (56846, 26) (~143344937, 12) (~969, 3)   (* saturn *)
    val uranus = b (8681, 25)  (2876679082, 12)  (681, 3)    (* uranus *)
    val neptune = b (10243, 26) (~4503443661, 12) (~543, 3)  (* neptune *)

    val sun2 = b (198892, 30) (7785472, 11)  (I 13070)

  end

  val one_body = [sun]
  val two_body = [sun, earth]

  val solar_system : Mechanics.body list =
      [sun, mercury, venus, earth, mars, jupiter, saturn, uranus, neptune]

end
