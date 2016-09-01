let diatomic_symmetric_data ~atom ~r =
  let ele = 
    Element.of_string atom
  in
  let charge = 
    Element.to_charge ele
    |> Charge.to_int
  in
  Printf.sprintf " $DATA
%s2
%s
%s  %d.0  0. 0. -%f
 $END
" atom (Sym.(to_string D4h)) atom charge (r /. 2.)



