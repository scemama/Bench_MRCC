let () = 

 let ele1 = Element.of_string "N"
(* and ele2 = Element.of_string "H" *)
 and r = 1.10
 in

 let basis  = "CCD"
 and mult   = 1
 and charge = 0
 and typ    = Gamess.HF
 and coord  = Gamess.Diatomic_symmetric (ele1, r)
 in

 Gamess.create_input ~mult ~charge ~basis ~typ ~coord

(* Coord.diatomic_symmetric "N" 1.10
*)
(* hf_input ~basis:"CCD"  "pouet" ~mult:2 
*)
  |> print_endline
