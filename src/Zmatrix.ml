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


let int_of_atom_id : atom_id -> int = fun x -> x

let float_of_distance : distance -> float = fun x -> x

let float_of_angle : angle -> float = fun x -> x

let float_of_dihedral : dihedral -> float = fun x -> x


type line = 
| First  of  Element.t
| Second of (Element.t * distance)
| Third  of (Element.t * atom_id * distance * atom_id * angle)
| Other  of (Element.t * atom_id * distance * atom_id * angle * atom_id * dihedral )

let string_of_line = function
| First  e ->  Printf.sprintf "%-3s" (Element.to_string e)
| Second (e, r) -> Printf.sprintf "%-3s %5d %f" (Element.to_string e) 1 r
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
 

type xyz_line =  (Element.t * float * float * float) option

(** Linear algebra *)

let dot (x,y,z) (x',y',z') =
  x*.x' +. y*.y' +. z*.z'

let norm u =
  sqrt @@ dot u u

let (|-) (x,y,z) (x',y',z') =
  ( x-.x', y-.y', z-.z' )

let (|+) (x,y,z) (x',y',z') =
  ( x+.x', y+.y', z+.z' )

let (|*) s (x,y,z) =
  ( s*.x, s*.y, s*.z )

let rotation_matrix axis angle = 
   (* Euler-Rodrigues formula for rotation matrix, taken from
      https://github.com/jevandezande/zmatrix/blob/master/converter.py
   *)
   let axis =
      1. /. (norm axis) |* axis
   and a = 
      (cos (angle *. to_radian *. 0.5))
   in
   let (b, c, d) = 
      (-. sin (angle *. to_radian *. 0.5)) |* axis 
   in
   Array.of_list @@ 
     [(a *. a +. b *. b -. c *. c -. d *. d,
       2. *. (b *. c -. a *. d),
       2. *. (b *. d +. a *. c));
      (2. *. (b *. c +. a *. d),
       a *. a +. c *. c -.b *. b -. d *. d,
       2. *. (c *. d -. a *. b));
      (2. *. (b *. d -. a *. c),
       2. *. (c *. d +. a *. b),
       a *. a +. d *. d -. b *. b -. c *. c)]
(*
     [(a *. a +. b *. b -. c *. c -. d *. d,
       2. *. (b *. c +. a *. d),
       2. *. (b *. d -. a *. c));
      (2. *. (b *. c -. a *. d),
       a *. a +. c *. c -.b *. b -. d *. d,
       2. *. (c *. d +. a *. b));
      (2. *. (b *. d +. a *. c),
       2. *. (c *. d -. a *. b),
       a *. a +. d *. d -. b *. b -. c *. c)]
*)
      


let apply_rotation_matrix rot u =
  (dot rot.(0) u, dot rot.(1) u, dot rot.(2) u)
  

let to_xyz z =
  let result =
    Array.make (Array.length z) None
  in 

  let append_line i' =
    match z.(i') with
    | First e -> 
        result.(i') <- Some (e, 0., 0., 0.)
    | Second (e, r) -> 
        let x =
          float_of_distance r
        in
        result.(i') <- Some (e, x, 0., 0.)
    | Third  (e, i, r, j, a) -> 
      begin
        let ui = 
          match result.(i-1) with
          | None -> failwith @@ Printf.sprintf "Atom %d is defined in the future" i
          | Some (_, x, y, z) -> (x, y, z)
        and uj = 
          match result.(j-1) with
          | None -> failwith @@ Printf.sprintf "Atom %d is defined in the future" j
          | Some (_, x, y, z) -> (x, y, z)
        in
        let u_ij = 
          let v = 
            uj |- ui
          in
          (1. /. (norm v)) |* v
        in
        let rot = 
          rotation_matrix (0., 0., 1.) a
        in
        let new_vec =
          apply_rotation_matrix rot u_ij
        in
        let (x, y, z) =
          r |* new_vec |+ ui
        in
        result.(i') <- Some (e, x, y, z)
      end
    | Other  (e, i, r, j, a, k, d) -> 
      begin
        ()
      end
  in
  Array.iteri (fun i _ -> append_line i) z;
  result


let test () =
  let text = "
H
O 1 1.08
H 2 1.08 1 107.5
"
  in
  let l = of_string text
  in
  Array.iter (fun x -> string_of_line x |> print_endline ) l;
  to_xyz l 
  |> Array.iter (fun x -> match x with None -> () | Some (e,x,y,z) -> 
    Printf.printf "%s %f %f %f\n" (Element.to_string e) x y z) ;


