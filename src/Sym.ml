type t =
| C1
| C2v
| C4v
| D2h
| D4h

let to_string = function
| C1  -> "C1"
| C2v -> "CNV 2\n\n"
| C4v -> "CNV 4\n\n"
| D2h -> "DNH 2\n\n"
| D4h -> "DNH 4\n\n"

