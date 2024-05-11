type atom = int

type lit = Pos of atom
         | Neg of atom

let int_of_lit = function
  | Pos a -> a
  | Neg a -> -a

let pp_print_lit fmt lit = Format.pp_print_int fmt (int_of_lit lit)

let neg_lit = function
  | Pos a -> Neg a
  | Neg a -> Pos a

(* probably should be encoded as non-empty lists, but eh *)
type clause = lit list
type formula = clause list

type assignment = lit list
