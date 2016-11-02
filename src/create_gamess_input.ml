type read_data_t = 
{ mult  : int ;
  charge: int ;
  typ   : Gamess.computation;
  basis : string option;
  filename: string option;
  coord: Gamess.coord_t option;
  nstate: int;
}

let read_data = ref {
  mult = 1;
  charge = 0;
  typ = Gamess.HF;
  filename = None;
  basis = None;
  coord = None;
  nstate = 1;
}

let set_nstate n = 
  read_data := { !read_data with nstate=n }

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
  | "hf"  | "HF" -> read_data := { !read_data with typ=Gamess.HF }
  | "mp2" | "MP2" -> read_data := { !read_data with typ=Gamess.MP2 }
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
 
let speclist = [
("-b", Arg.String (set_basis),         "Basis set [ CCD | CCT | ... ]");
("-c", Arg.Int    (set_charge),        "Charge of the system. Default: 0" );
("-m", Arg.Int    (set_multiplicity),  "Spin multiplicity"    );
("-t", Arg.String (set_type),          "Type of calculation [ HF | CAS(n_e,n_a) ]. Default: HF");
("-f", Arg.String (set_filename),      "Name of the .dat file containing the MOs. Default: None");
("-s", Arg.Int    (set_nstate),        "Number of states for state-average. Default: 1");

]

let usage_msg = 
  "Creates GAMESS input file in standard output from a z-matrix given in the
standard input.

Example:

$ cat << EOF | create_gamess_input -b CCTC -t \"CAS(2,2)\" -s 2 -f h2o.dat > h2o.inp
h
o 1 oh
h 2 oh 1 angle

oh 1.08
angle 107.5
EOF
"

let read_zmat () =
  let rec read_stdin accu =
      try
        read_stdin ( (input_line stdin) :: accu )
      with End_of_file ->
        List.rev accu |> String.concat "\n"
  in
  let (zmat,map) = 
    read_stdin []
    |> Zmatrix.of_string
  in
  let geom = 
    let open Zmatrix in 
      begin
        match (Array.to_list zmat) with
        | First  e :: [] -> Gamess.Atom e
        | First e1 :: Second (e2,r) :: [] -> 
          begin
            if (e1 = e2) then
              Gamess.Diatomic_homo (e1, (float_of_distance map r) )
            else
              Gamess.Diatomic (e1, e2, (float_of_distance map r) )
          end
        | _ -> Gamess.Xyz (Zmatrix.to_xyz ~remove_dummy:true (zmat,map) )
      end
  in
  read_data := { !read_data with coord=Some geom }

        

let run () =
  Arg.parse speclist print_endline usage_msg;
  read_zmat ();

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
  and nstate = !read_data.nstate
  in

  let system = 
    Gamess.{ mult ; charge ; basis ; coord }
  in
  Gamess.create_input ~vecfile ~system ~nstate typ
  |> print_endline 


let () =
  try
   run ()
  with e ->
     (Arg.usage speclist usage_msg ; raise e)

