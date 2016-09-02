let () = 


 let ele1 = Element.of_string "Li"
 and ele2 = Element.of_string "H" 
 and r = 1.10
 in

 let mult   = 1
 and charge = 0
 and basis  = "CCD" 
 and coord  = Gamess.Diatomic (ele1, ele2, r)
 in

 let system = 
  Gamess.{ mult ; charge ; basis ; coord }
 in
 Gamess.create_input ~system Gamess.HF
 |> print_endline
