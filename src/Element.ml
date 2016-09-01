exception ElementError of string

type t =
|X
|H                                                 |He
|Li|Be                              |B |C |N |O |F |Ne
|Na|Mg                              |Al|Si|P |S |Cl|Ar
|K |Ca|Sc|Ti|V |Cr|Mn|Fe|Co|Ni|Cu|Zn|Ga|Ge|As|Se|Br|Kr
|Rb|Sr|Y |Zr|Nb|Mo|Tc|Ru|Rh|Pd|Ag|Cd|In|Sn|Sb|Te|I |Xe

let of_string x = 
  match (String.capitalize (String.lowercase x)) with
|  "X"   |  "Dummy"       ->  X
|  "H"   |  "Hydrogen"    ->  H
|  "He"  |  "Helium"      ->  He
|  "Li"  |  "Lithium"     ->  Li
|  "Be"  |  "Beryllium"   ->  Be
|  "B"   |  "Boron"       ->  B
|  "C"   |  "Carbon"      ->  C
|  "N"   |  "Nitrogen"    ->  N
|  "O"   |  "Oxygen"      ->  O
|  "F"   |  "Fluorine"    ->  F
|  "Ne"  |  "Neon"        ->  Ne
|  "Na"  |  "Sodium"      ->  Na
|  "Mg"  |  "Magnesium"   ->  Mg
|  "Al"  |  "Aluminum"    ->  Al
|  "Si"  |  "Silicon"     ->  Si
|  "P"   |  "Phosphorus"  ->  P
|  "S"   |  "Sulfur"      ->  S
|  "Cl"  |  "Chlorine"    ->  Cl
|  "Ar"  |  "Argon"       ->  Ar
|  "K"   |  "Potassium"   ->  K
|  "Ca"  |  "Calcium"     ->  Ca
|  "Sc"  |  "Scandium"    ->  Sc
|  "Ti"  |  "Titanium"    ->  Ti
|  "V"   |  "Vanadium"    ->  V
|  "Cr"  |  "Chromium"    ->  Cr
|  "Mn"  |  "Manganese"   ->  Mn
|  "Fe"  |  "Iron"        ->  Fe
|  "Co"  |  "Cobalt"      ->  Co
|  "Ni"  |  "Nickel"      ->  Ni
|  "Cu"  |  "Copper"      ->  Cu
|  "Zn"  |  "Zinc"        ->  Zn
|  "Ga"  |  "Gallium"     ->  Ga
|  "Ge"  |  "Germanium"   ->  Ge
|  "As"  |  "Arsenic"     ->  As
|  "Se"  |  "Selenium"    ->  Se
|  "Br"  |  "Bromine"     ->  Br
|  "Kr"  |  "Krypton"     ->  Kr
|  "Rb"  |  "Rubidium"    ->  Rb
|  "Sr"  |  "Strontium"   ->  Sr
|  "Y"   |  "Yttrium"     ->  Y
|  "Zr"  |  "Zirconium"   ->  Zr
|  "Nb"  |  "Niobium"     ->  Nb
|  "Mo"  |  "Molybdenum"  ->  Mo
|  "Tc"  |  "Technetium"  ->  Tc
|  "Ru"  |  "Ruthenium"   ->  Ru
|  "Rh"  |  "Rhodium"     ->  Rh
|  "Pd"  |  "Palladium"   ->  Pd
|  "Ag"  |  "Silver"      ->  Ag
|  "Cd"  |  "Cadmium"     ->  Cd
|  "In"  |  "Indium"      ->  In
|  "Sn"  |  "Tin"         ->  Sn
|  "Sb"  |  "Antimony"    ->  Sb
|  "Te"  |  "Tellurium"   ->  Te
|  "I"   |  "Iodine"      ->  I
|  "Xe"  |  "Xenon"       ->  Xe
| x -> raise (ElementError ("Element "^x^" unknown"))


let to_string = function
| X   -> "X"
| H   -> "H"
| He  -> "He"
| Li  -> "Li"
| Be  -> "Be"
| B   -> "B"
| C   -> "C"
| N   -> "N"
| O   -> "O"
| F   -> "F"
| Ne  -> "Ne"
| Na  -> "Na"
| Mg  -> "Mg"
| Al  -> "Al"
| Si  -> "Si"
| P   -> "P"
| S   -> "S"
| Cl  -> "Cl"
| Ar  -> "Ar"
| K   -> "K"
| Ca  -> "Ca"
| Sc  -> "Sc"
| Ti  -> "Ti"
| V   -> "V"
| Cr  -> "Cr"
| Mn  -> "Mn"
| Fe  -> "Fe"
| Co  -> "Co"
| Ni  -> "Ni"
| Cu  -> "Cu"
| Zn  -> "Zn"
| Ga  -> "Ga"
| Ge  -> "Ge"
| As  -> "As"
| Se  -> "Se"
| Br  -> "Br"
| Kr  -> "Kr"
| Rb  -> "Rb"
| Sr  -> "Sr"
| Y   -> "Y"
| Zr  -> "Zr"
| Nb  -> "Nb"
| Mo  -> "Mo"
| Tc  -> "Tc"
| Ru  -> "Ru"
| Rh  -> "Rh"
| Pd  -> "Pd"
| Ag  -> "Ag"
| Cd  -> "Cd"
| In  -> "In"
| Sn  -> "Sn"
| Sb  -> "Sb"
| Te  -> "Te"
| I   -> "I"
| Xe  -> "Xe"


let to_long_string = function
| X   -> "Dummy"
| H   -> "Hydrogen"
| He  -> "Helium"
| Li  -> "Lithium"
| Be  -> "Beryllium"
| B   -> "Boron"
| C   -> "Carbon"
| N   -> "Nitrogen"
| O   -> "Oxygen"
| F   -> "Fluorine"
| Ne  -> "Neon"
| Na  -> "Sodium"
| Mg  -> "Magnesium"
| Al  -> "Aluminum"
| Si  -> "Silicon"
| P   -> "Phosphorus"
| S   -> "Sulfur"
| Cl  -> "Chlorine"
| Ar  -> "Argon"
| K   -> "Potassium"
| Ca  -> "Calcium"
| Sc  -> "Scandium"
| Ti  -> "Titanium"
| V   -> "Vanadium"
| Cr  -> "Chromium"
| Mn  -> "Manganese"
| Fe  -> "Iron"
| Co  -> "Cobalt"
| Ni  -> "Nickel"
| Cu  -> "Copper"
| Zn  -> "Zinc"
| Ga  -> "Gallium"
| Ge  -> "Germanium"
| As  -> "Arsenic"
| Se  -> "Selenium"
| Br  -> "Bromine"
| Kr  -> "Krypton"
| Rb  ->  "Rubidium"
| Sr  ->  "Strontium"
| Y   ->  "Yttrium"
| Zr  ->  "Zirconium"
| Nb  ->  "Niobium"
| Mo  ->  "Molybdenum"
| Tc  ->  "Technetium"
| Ru  ->  "Ruthenium"
| Rh  ->  "Rhodium"
| Pd  ->  "Palladium"
| Ag  ->  "Silver"
| Cd  ->  "Cadmium"
| In  ->  "Indium"
| Sn  ->  "Tin"
| Sb  ->  "Antimony"
| Te  ->  "Tellurium"
| I   ->  "Iodine"
| Xe  ->  "Xenon"


let to_charge c = 
  let result = match c with
  | X   -> 0
  | H   -> 1
  | He  -> 2
  | Li  -> 3
  | Be  -> 4
  | B   -> 5
  | C   -> 6
  | N   -> 7
  | O   -> 8
  | F   -> 9
  | Ne  -> 10
  | Na  -> 11
  | Mg  -> 12
  | Al  -> 13
  | Si  -> 14
  | P   -> 15
  | S   -> 16
  | Cl  -> 17
  | Ar  -> 18
  | K   -> 19
  | Ca  -> 20
  | Sc  -> 21
  | Ti  -> 22
  | V   -> 23
  | Cr  -> 24
  | Mn  -> 25
  | Fe  -> 26
  | Co  -> 27
  | Ni  -> 28
  | Cu  -> 29
  | Zn  -> 30
  | Ga  -> 31
  | Ge  -> 32
  | As  -> 33
  | Se  -> 34
  | Br  -> 35
  | Kr  -> 36
  | Rb  -> 37
  | Sr  -> 38
  | Y   -> 39
  | Zr  -> 40
  | Nb  -> 41
  | Mo  -> 42
  | Tc  -> 43
  | Ru  -> 44
  | Rh  -> 45
  | Pd  -> 46
  | Ag  -> 47
  | Cd  -> 48
  | In  -> 49
  | Sn  -> 50
  | Sb  -> 51
  | Te  -> 52
  | I   -> 53
  | Xe  -> 54
  in Charge.of_int result


let of_charge c = match (Charge.to_int c) with
|  0   -> X   
|  1   -> H   
|  2   -> He  
|  3   -> Li  
|  4   -> Be  
|  5   -> B   
|  6   -> C   
|  7   -> N   
|  8   -> O   
|  9   -> F   
|  10  -> Ne  
|  11  -> Na  
|  12  -> Mg  
|  13  -> Al  
|  14  -> Si  
|  15  -> P   
|  16  -> S   
|  17  -> Cl  
|  18  -> Ar  
|  19  -> K   
|  20  -> Ca  
|  21  -> Sc  
|  22  -> Ti  
|  23  -> V   
|  24  -> Cr  
|  25  -> Mn  
|  26  -> Fe  
|  27  -> Co  
|  28  -> Ni  
|  29  -> Cu  
|  30  -> Zn  
|  31  -> Ga  
|  32  -> Ge  
|  33  -> As  
|  34  -> Se  
|  35  -> Br  
|  36  -> Kr  
|  37  -> Rb
|  38  -> Sr
|  39  -> Y
|  40  -> Zr
|  41  -> Nb
|  42  -> Mo
|  43  -> Tc
|  44  -> Ru
|  45  -> Rh
|  46  -> Pd
|  47  -> Ag
|  48  -> Cd
|  49  -> In
|  50  -> Sn
|  51  -> Sb
|  52  -> Te
|  53  -> I
|  54  -> Xe
| x -> raise (ElementError ("Element of charge "^(string_of_int x)^" unknown"))


