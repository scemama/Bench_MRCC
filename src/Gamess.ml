(* DATA *)
let diatomic_symmetric_data ~ele ~r =
  assert (r > 0.);
  let atom = 
    Element.to_string ele
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


(* HF / MCSCF *)

let rhf_input ~charge ~basis = 
  Printf.sprintf "
 $CONTRL
   EXETYP=RUN COORD=UNIQUE  UNITS=ANGS
   RUNTYP=ENERGY SCFTYP=RHF CITYP=NONE
   MAXIT=200
   ISPHER=1
   MULT=1
   ICHARG=%d
 $END

 $GUESS
  GUESS=HUCKEL
 $END

 $BASIS
  GBASIS=%s
 $END

" charge basis 

let rohf_input ~charge ~mult ~basis = 
  Printf.sprintf "
 $CONTRL
   EXETYP=RUN COORD=UNIQUE  UNITS=ANGS
   RUNTYP=ENERGY SCFTYP=ROHF CITYP=NONE
   MAXIT=200
   ISPHER=1
   MULT=%d
   ICHARG=%d
 $END

 $GUESS
  GUESS=HUCKEL
 $END

 $BASIS
  GBASIS=%s
 $END

" mult charge basis 



let hf_input ?(charge=0) ?(mult=1) ~basis = 
  match mult with
  | 1 -> rhf_input ~charge ~basis
  | mult -> rohf_input ~charge ~mult ~basis

  

type input_type = HF | MCSCF

type coord_type = 
| Diatomic_symmetric of (Element.t*float)
| Diatomic           of (Element.t*Element.t*float)


let create_input ?(mult=1) ?(charge=0) ~basis ~typ ~coord =
  String.concat "\n" 
  [ (match typ with
    | HF -> hf_input ~charge ~mult ~basis
    | MCSCF -> ""
    )
  ;
    (
    match coord with
    | Diatomic_symmetric (ele,r) -> diatomic_symmetric_data ~ele ~r
    | Diatomic           (ele1,ele2,r) -> "" (*diatomic_data ~ele1 ~ele2 ~r *)
    )
  ]
  
   
