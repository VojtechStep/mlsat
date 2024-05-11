open Alcotest
open Mlsat.Formula

let lit = testable pp_print_lit ( = )

let clause = slist lit compare

let formula = slist clause compare

let assignment = option (list lit)
