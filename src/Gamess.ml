(** CONTRL *)
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


(** GUESS *)
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


(** BASIS *)
let string_of_basis =
  Printf.sprintf " $BASIS
  GBASIS=%s
 $END" 


(** DATA *)
type coord_t = 
| Diatomic_homo of (Element.t*float)
| Diatomic      of (Element.t*Element.t*float)


type data_t =
{ sym: Sym.t ;
  title: string;
  xyz: string;
  nucl_charge: int;
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
    xyz=Printf.sprintf "%s  %d.0  0. 0. %f" atom charge (-.r *. 0.5) ;
    nucl_charge = 2*charge
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
        atom1 charge1 atom2 charge2 r ;
    nucl_charge = charge1 + charge2
  }


let make_data = function
| Diatomic_homo (ele,r) -> data_of_diatomic_homo ele r
| Diatomic      (ele1,ele2,r) -> data_of_diatomic ele1 ele2 r

let string_of_data d =
  String.concat "\n" [ " $DATA" ;
    d.title ;
    Sym.to_string d.sym ;
  ]  ^ d.xyz ^ "\n $END"
    

(** MCSCF *)
type drt_t = 
{ nmcc: int ;
  ndoc: int ;
  nalp: int ;
  nval: int ;
  istsym: int;
}

(*
let make_drt n_elec_alpha n_elec_beta n_e n_act =
  let ndoc = n_e / 2 in
  let nalp = ndoc
*)
  

(** Computation *)
type computation = HF | CAS of (int*int)

type system =
{ mult: int ; charge: int ; basis: string ; coord: coord_t }

let n_elec system =
  let data = 
    make_data system.coord
  in
  data.nucl_charge - system.charge

let n_elec_alpha_beta system =
  let n = 
    n_elec system 
  and m = 
    system.mult
  in
  let alpha = 
    (n + int_of_float (sqrt (float_of_int (1 + 4 * (m-1)))) - 1)/2
  in
  let beta = 
    n - alpha
  in
  (alpha, beta)

  

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
  



let create_cas_input system n_e n_a =
 ""

let create_input ~system = function
| HF -> create_hf_input system
| CAS (n_e,n_a) -> create_cas_input system n_e n_a


