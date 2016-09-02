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


(** Vec *)
type vec_t = 
| Canonical of string
| Natural of string

let read_mos guide filename =
  let text =
    let ic = open_in filename in
    let n = in_channel_length ic in
    let s = Bytes.create n in
    really_input ic s 0 n;
    close_in ic;
    s
  in

  let re_vec =
    Str.regexp " \\$VEC *\n"
  and re_natural =
    Str.regexp guide
  and re_end =
    Str.regexp " \\$END *\n"
  and re_eol =
    Str.regexp "\n"
  in
  let i =
    Str.search_forward re_natural text 0
  in
  let start =
    Str.search_forward re_vec text i
  in
  let i =
    Str.search_forward re_end text start
  in
  let finish =
    Str.search_forward re_eol text i
  in
  String.sub text start (finish-start)
  
let read_natural_mos =
  read_mos "--- NATURAL ORBITALS OF MCSCF ---"
  
let read_canonical_mos =
  try
    read_mos "--- OPTIMIZED MCSCF MO-S ---"
  with Not_found ->
    read_mos "--- CLOSED SHELL ORBITALS ---"
  
let string_of_vec = function
| Natural filename -> read_natural_mos filename
| Canonical filename -> read_canonical_mos filename

(** GUESS *)
type guess_t =
| Huckel
| Canonical of (int*string)
| Natural   of (int*string)

let string_of_guess g =
 [
 " $GUESS\n" ; "  GUESS=" ; 
 begin
  match g with
    | Huckel -> "HUCKEL\n"
    | Canonical (norb,_) | Natural (norb,_) -> Printf.sprintf "MOREAD\n  NORB=%d\n" norb
 end
 ; " $END" ;
 match g with
    | Huckel  -> ""
    | Natural (_,filename)  -> "\n\n"^(string_of_vec (Natural filename))
    | Canonical (_,filename) ->"\n\n"^(string_of_vec (Canonical filename))
 ] |> String.concat ""


(** BASIS *)
let string_of_basis =
  Printf.sprintf " $BASIS
  GBASIS=%s
 $END" 


(** DATA *)
type coord_t = 
| Atom          of Element.t
| Diatomic_homo of (Element.t*float)
| Diatomic      of (Element.t*Element.t*float)


type data_t =
{ sym: Sym.t ;
  title: string;
  xyz: string;
  nucl_charge: int;
}

let data_of_atom ele =
  let atom =
    Element.to_string ele
  in
  let charge =
    Element.to_charge ele
    |> Charge.to_int
  in
  { sym=Sym.D4h ;
    title=Printf.sprintf "%s" atom ;
    xyz=Printf.sprintf "%s  %d.0  0. 0. 0." atom charge ;
    nucl_charge = charge
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
| Atom          ele -> data_of_atom ele
| Diatomic_homo (ele,r) -> data_of_diatomic_homo ele r
| Diatomic      (ele1,ele2,r) -> data_of_diatomic ele1 ele2 r

let string_of_data d =
  String.concat "\n" [ " $DATA" ;
    d.title ;
    Sym.to_data d.sym ;
  ]  ^ d.xyz ^ "\n $END"
    

(** MCSCF *)
type mcscf_t = FULLNR | SOSCF | FOCAS

let string_of_mcscf m =
  " $MCSCF\n" ^ 
  begin
   match m with
   | FOCAS  -> "   FOCAS=.T.    SOSCF=.F.   FULLNR=.F."
   | SOSCF  -> "   FOCAS=.F.    SOSCF=.T.   FULLNR=.F."
   | FULLNR -> "   FOCAS=.F.    SOSCF=.F.   FULLNR=.T."
  end ^ "
   CISTEP=GUGA EKT=.F. QUAD=.F. JACOBI=.f.
   MAXIT=1000
 $END"


type drt_t = 
{ nmcc: int ;
  ndoc: int ;
  nalp: int ;
  nval: int ;
  istsym: int;
}


let make_drt ?(istsym=1) n_elec_alpha n_elec_beta n_e n_act =
  let n_elec_tot =
     n_elec_alpha + n_elec_beta
  in
  let nmcc =
     (n_elec_tot - n_e)/2
  in
  let ndoc = 
     n_elec_beta - nmcc
  in 
  let nalp =
     (n_elec_alpha - nmcc - ndoc)
  in
  let nval =
    n_act - ndoc - nalp
  in
  { nmcc ; ndoc ; nalp ; nval ; istsym }

let string_of_drt drt sym =
  Printf.sprintf " $DRT
  NMCC=%d NDOC=%d NALP=%d NVAL=%d  NEXT=0 ISTSYM=%d
  FORS=.TRUE.
  GROUP=%s
  MXNINT= 600000
  NPRT=2
 $END"
 drt.nmcc drt.ndoc drt.nalp drt.nval drt.istsym (Sym.to_string sym)

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
    (n+m-1)/2
  in
  let beta = 
    n - alpha
  in
  (alpha, beta)

  

let create_hf_input ?(vecfile="") s =
  let scftyp =
    match s.mult with
    | 1 -> RHF
    | _ -> ROHF
  and mult = s.mult
  and charge = s.charge
  and n_elec_alpha, _ = 
    n_elec_alpha_beta s
  in
  [
    make_contrl ~mult ~charge scftyp
    |> string_of_contrl 
  ;
    begin
      match vecfile with
      | "" ->     string_of_guess Huckel
      | vecfile -> string_of_guess (Canonical (n_elec_alpha, vecfile))
    end
  ;
    string_of_basis s.basis
  ;
    make_data s.coord
    |> string_of_data
  ] |> String.concat "\n\n"
  



let create_cas_input ?(vecfile="") s n_e n_a =
  let scftyp = MCSCF
  and mult = s.mult
  and charge = s.charge
  in
  let n_elec_alpha, n_elec_beta = 
    n_elec_alpha_beta s
  in
  let drt = 
    make_drt n_elec_alpha n_elec_beta n_e n_a
  in
  let data = 
    make_data s.coord
  in
  [
    make_contrl ~mult ~charge scftyp
    |> string_of_contrl 
  ;
    begin
      match vecfile with
      | "" ->     string_of_guess Huckel
      | vecfile -> string_of_guess (Natural (n_elec_alpha, vecfile))
    end
  ;
    string_of_basis s.basis
  ;
    string_of_mcscf FULLNR
  ;
    string_of_drt drt data.sym
  ;
    string_of_data data
  ] |> String.concat "\n\n"
  

let create_input ?(vecfile="") ~system = function
| HF -> create_hf_input ~vecfile system
| CAS (n_e,n_a) -> create_cas_input ~vecfile system n_e n_a 


