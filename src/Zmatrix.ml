type atom_id  = int
type angle    = float
type distance = float
type dihedral = float

let pi = 3.14159265358979323846
let to_radian = pi /. 180.

let rec in_range (xmin, xmax) x =
   if (x <= xmin) then
     in_range (xmin, xmax) (x -. xmin +. xmax )
   else if (x > xmax) then
     in_range (xmin, xmax) (x -. xmax +. xmin )
   else
     x

let atom_id_of_int : int -> atom_id = 
  fun x -> ( assert (x>0) ; x)

let distance_of_float : float -> distance = 
  fun x -> ( assert (x>=0.) ; x)

let angle_of_float : float -> angle = 
  fun x -> in_range (-180., 180.) x

let dihedral_of_float : float -> dihedral = 
  fun x -> in_range (-360., 360.) x


type line = 
| First  of  Element.t
| Second of (Element.t * atom_id * distance)
| Third  of (Element.t * atom_id * distance * atom_id * angle)
| Other  of (Element.t * atom_id * distance * atom_id * angle * atom_id * dihedral )

let string_of_line = function
| First  e ->  Printf.sprintf "%-3s" (Element.to_string e)
| Second (e, i, r) -> Printf.sprintf "%-3s %5d %f" (Element.to_string e) i r
| Third  (e, i, r, j, a) -> Printf.sprintf "%-3s %5d %f %5d %f" (Element.to_string e) i r j a
| Other  (e, i, r, j, a, k, d) -> Printf.sprintf "%-3s %5d %f %5d %f %5d %f" (Element.to_string e) i r j a k d

let line_of_string l =
  let line_clean =
    Str.split (Str.regexp " ") l
    |> List.filter (fun x -> x <> "")
  in
  match line_clean with
  | e :: [] -> First (Element.of_string e)
  | e :: i :: r :: [] -> Second
    (Element.of_string e,
     atom_id_of_int @@ int_of_string i,
     distance_of_float @@ float_of_string r)
  | e :: i :: r :: j :: a :: [] -> Third 
    (Element.of_string e,
     atom_id_of_int @@ int_of_string i,
     distance_of_float @@ float_of_string r,
     atom_id_of_int @@ int_of_string j,
     angle_of_float @@ float_of_string a)
  | e :: i :: r :: j :: a :: k :: d :: [] -> Other
    (Element.of_string e,
     atom_id_of_int @@ int_of_string i,
     distance_of_float @@ float_of_string r,
     atom_id_of_int @@ int_of_string j,
     angle_of_float @@ float_of_string a,
     atom_id_of_int @@ int_of_string k,
     dihedral_of_float @@ float_of_string d)
  | _ -> failwith ("Syntax error: "^l)


type t = line array

let of_string t =
  let l =
    Str.split (Str.regexp "\n") t
    |> List.map line_of_string
  in

  let l = 
    match l with
    | First _ :: Second _ :: Third _ :: _
    | First _ :: Second _ :: []
    | First _ :: [] -> l
    | _ -> failwith "Syntax error"
  in
  Array.of_list l
 

let to_xyz z =
  let append

let test () =
  let text = " O
 H                    1    1.05835
 Cu                   1    1.05853  2    16. 
 Cl                   1    1.05385  3    25.     2    380
 N                    1    1.08535  2    34.     3    190
"
  in
  let l = of_string text
  in
  Array.iter (fun x -> string_of_line x |> print_endline ) l


