local
  val secs_in_day = (Plane.s_fromInt 864000)

  val onebody_list = map (fn (x,y) => (x, Solars.one_body, "onebody." ^ y ^ ".auto.txt"))
                         [(1,"10day"),
                          (14,"20weeks"),
                          (365,"10yr")]

  val twobody_list = map (fn (x,y) => (x, Solars.two_body, "twobody." ^ y ^ ".auto.txt"))
                       [(1,"10day"),
                        (2,"20day"),
                        (3,"30day"),
                        (4,"40day"),
                        (5,"50day"),
                        (6,"60day")]

  val system_list = map (fn (x,y) => (x, Solars.solar_system, "system." ^ y ^ ".auto.txt"))
                        [(1,"10day"),
                         (2,"20day")]

  val all = onebody_list @ twobody_list @ system_list

  fun dorun (num_days, bod, name) =
      let
        val _ = print ("made " ^ name ^ " ...")
        val t1 = Time.now ();
        val _ = Simulation.runBH bod secs_in_day num_days name
        val t2 = Time.now ();
        val delta = Time.-(t2,t1)
        val _ = print (" in " ^ Time.toString delta ^ " seconds\n")
      in
        ()
      end

  val _ = map dorun all

in
end
