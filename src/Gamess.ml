(* DATA *)
type coord_t = 
| Diatomic_homo of (Element.t*float)
| Diatomic      of (Element.t*Element.t*float)


type data_t =
{ sym: Sym.t ;
  title: string;
  xyz: string;
}

let data_of_diatomic_homo ele r =
  assert (r > 0.);
  let atom =
    Element.to_string ele
  in
  let charge =
    Element.to_charge ele
    |> Charge.to_int
  in
  { sym=Sym.D4h ;
    title=Printf.sprintf "%s2" atom ;
    xyz=Printf.sprintf "%s  %d.0  0. 0. %f" atom charge (-.r *. 0.5)
  }

let data_of_diatomic ele1 ele2 r =
  assert (r > 0.);
  let atom1, atom2 =
    Element.to_string ele1,
    Element.to_string ele2
  in
  let charge1, charge2 =
    Charge.to_int @@ Element.to_charge ele1,
    Charge.to_int @@ Element.to_charge ele2
  in
  { sym=Sym.C4v ;
    title=Printf.sprintf "%s%s" atom1 atom2 ;
    xyz=Printf.sprintf "%s  %d.0  0. 0. 0.\n%s  %d.0  0. 0. %f"
        atom1 charge1 atom2 charge2 r
  }


let make_data = function
| Diatomic_homo (ele,r) -> data_of_diatomic_homo ele r
| Diatomic      (ele1,ele2,r) -> data_of_diatomic ele1 ele2 r

let string_of_data d =
  String.concat "\n" [ " $DATA" ;
    d.title ;
    Sym.to_string d.sym ;
  ]  ^ d.xyz ^ "\n $END"
    
  
(* CONTRL *)
type scftyp_t = RHF | ROHF | MCSCF
let string_of_scftyp = function
| RHF -> "RHF"
| ROHF -> "ROHF"
| MCSCF -> "MCSCF"

type contrl =
{ scftyp: scftyp_t ;
  maxit: int;
  ispher: int;
  icharg: int;
  mult: int;
}

let string_of_contrl c =
  Printf.sprintf " $CONTRL
   EXETYP=RUN COORD=UNIQUE  UNITS=ANGS
   RUNTYP=ENERGY SCFTYP=%s CITYP=NONE
   MAXIT=%d
   ISPHER=%d
   MULT=%d
   ICHARG=%d
 $END"
 (string_of_scftyp c.scftyp)
 c.maxit c.ispher c.mult c.icharg

let make_contrl ?(maxit=100) ?(ispher=1) ~mult ~charge scftyp =
  { scftyp ; maxit ; ispher ; mult ; icharg=charge }


(* GUESS *)
type guess_t =
| HUCKEL
| MOREAD of int

let string_of_guess g =
 [
 " $GUESS\n" ; "  GUESS=" ; 
 begin
  match g with
    | HUCKEL -> "HUCKEL\n"
    | MOREAD norb -> Printf.sprintf "MOREAD\n  NORB=%d\n" norb
 end
 ; " $END"
 ] |> String.concat ""


(* BASIS *)
let string_of_basis =
  Printf.sprintf " $BASIS
  GBASIS=%s
 $END" 


(* HF *)

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


(* MCSCF *)

type cas = { n_elec : int ; n_orb : int }

let mcscf_input ~charge ~mult ~basis ~cas ~n_orb_tot =

  Printf.sprintf "
 $CONTRL
   EXETYP= RUN COORD= UNIQUE  UNITS=ANGS
   RUNTYP= ENERGY SCFTYP=MCSCF CITYP=NONE
   MAXIT=200 ISPHER=1 QMTTOL=1.e-12
   MULT= %d
   ICHARG= %d
 $END

 $GUESS
  GUESS=MOREAD
  NORB=%d
 $END

 $BASIS
  GBASIS=%s
 $END

 $TRANS DIRTRF=.FALSE. $END

 $MCSCF
   FOCAS=.F.    SOSCF=.F.   FULLNR=.T.
   CISTEP=GUGA EKT=.F. QUAD=.F. JACOBI=.f.
   MAXIT=1000
 $END

" mult charge n_orb_tot basis 


let hf_input ?(charge=0) ?(mult=1) ~basis = 
  match mult with
  | 1 -> rhf_input ~charge ~basis
  | mult -> rohf_input ~charge ~mult ~basis




(* Computation *)
type computation = HF | CAS of (int*int)

type system =
{ mult: int ; charge: int ; basis: string ; coord: coord_t }

let create_hf_input s =
  let scftyp =
    match s.mult with
    | 1 -> RHF
    | _ -> ROHF
  and mult = s.mult
  and charge = s.charge
  in
  [
    make_contrl ~mult ~charge scftyp
    |> string_of_contrl 
  ;
    string_of_guess HUCKEL
  ;
    string_of_basis s.basis
  ;
    make_data s.coord
    |> string_of_data
  ] |> String.concat "\n\n"
  

let create_cas_input system n_elec n_act =
  "TODO"

let create_input ~system = function
| HF -> create_hf_input system
| CAS (n_elec,n_act) -> create_cas_input system n_elec n_act


