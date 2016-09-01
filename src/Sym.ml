type t =
| C1
| C2v
| D4h

let to_string = function
| C1  -> "C1"
| C2v -> "CNV 2\n"
| D4h -> "DNH 4\n"

