open Alcotest
open Test_lib
open Mlsat.Formula
open Mlsat.Solver

let test_simplify_pos () =
  let output = simplify [[Pos 1; Pos 2]] (Pos 1) in
  check formula "simplified" [] output

let test_simplify_neg () =
  let output = simplify [[Pos 1; Pos 2]] (Neg 1) in
  check formula "simplified" [[Pos 2]] output

let test_simplify_unsat () =
  let output () = ignore (simplify [[Pos 1]] (Neg 1)) in
  check_raises "simplify unsat" Unsat output

let () =
  run "Simplification" [
      "simplify", [
        "simplify pos", `Quick, test_simplify_pos;
        "simplify neg", `Quick, test_simplify_neg;
        "simplify unsat", `Quick, test_simplify_unsat;
      ];
    ]
