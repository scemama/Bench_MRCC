type read_data_t = 
{ mult  : int ;
  charge: int ;
  typ   : Gamess.computation;
  basis : string option;
  filename: string option;
  coord: Gamess.coord_t option;
}

let read_data = ref {
  mult = 1;
  charge = 0;
  typ = Gamess.HF;
  filename = None;
  basis = None;
  coord = None;
}

let set_multiplicity m =
  read_data := { !read_data with mult=m }

let set_charge c =
  read_data := { !read_data with charge=c }
 
let set_basis b =
  read_data := { !read_data with basis=Some b }
 
let set_filename f = 
  read_data := { !read_data with filename=Some f }

let set_type t =
  match t with 
  | "hf" | "HF" -> read_data := { !read_data with typ=Gamess.HF }
  | _ ->
    begin
      let re_cas =
        Str.regexp "\\(CAS\\|cas\\)(\\([0-9]+\\),\\([0-9]+\\))"
      in
      let n_e, n_a = 
        int_of_string @@ Str.replace_first re_cas "\\2" t, 
        int_of_string @@ Str.replace_first re_cas "\\3" t
      in
      read_data := { !read_data with typ=Gamess.CAS(n_e,n_a) }
    end
 
let set_geometry g =
  match Str.split (Str.regexp ",") g with
  | atom :: [] -> 
    let ele = 
      Element.of_string atom
    in
    read_data := { !read_data with coord= Some (Gamess.Atom ele) }
  | atom :: r :: [] -> 
    let atom = 
      let l = 
        (String.length atom)-1
      in
      if atom.[l] <> '2' then
        failwith "Error in geometry";
      String.sub atom 0 l
    in
    let ele = 
      Element.of_string atom
    and r =
      float_of_string r
    in
    read_data := { !read_data with coord= Some (Gamess.Diatomic_homo (ele,r)) }
  | atom1 :: atom2 :: r :: [] -> 
    let ele1, ele2 = 
      Element.of_string atom1,
      Element.of_string atom2
    and r =
      float_of_string r
    in
    read_data := { !read_data with coord= Some (Gamess.Diatomic (ele1,ele2,r)) }
  | _ -> failwith "Error in geometry"
 
let speclist = [
("-b", Arg.String (set_basis),         "Basis set [ CCD | CCT | ... ]");
("-c", Arg.Int    (set_charge),        "Charge of the system. Default: 0" );
("-m", Arg.Int    (set_multiplicity),  "Spin multiplicity"    );
("-t", Arg.String (set_type),          "Type of calculation [ HF | CAS(n_e,n_a) ]. Default: HF");
("-f", Arg.String (set_filename),      "Name of the .dat file containing the MOs. Default: None");
("-g", Arg.String (set_geometry),      "Geometry.");

]

let usage_msg = 
  "Creates GAMESS input files.

Examples:
  -b CCT -g Li
  -b CCD -g N2,1.15 -t \"CAS(6,6)\"
  -b CCTC -g Li,H,1.00 -t \"CAS(2,2)\"

"


let run () =
  Arg.parse speclist print_endline usage_msg;

  let mult   = !read_data.mult
  and charge = !read_data.charge
  and coord  =
    begin
      match !read_data.coord with
      | None -> failwith "No geometry defined in command line"
      | Some c -> c
    end
  and basis  = 
    begin
      match !read_data.basis with
      | None -> failwith "No basis set defined in command line"
      | Some b -> b
    end
  and typ    = !read_data.typ
  and vecfile = 
    begin 
      match !read_data.filename with
      | None -> ""
      | Some filename -> filename
    end
  in

  let system = 
    Gamess.{ mult ; charge ; basis ; coord }
  in
  Gamess.create_input ~vecfile ~system typ
  |> print_endline 


let () =
  try
   run ()
  with e ->
     (Arg.usage speclist usage_msg ; raise e)

