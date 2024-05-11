open Alcotest
open Test_lib
open Mlsat.Parser
open Mlsat.Formula

let test_parse_empty () =
  let output = parse_dimacs_string "" in
  check formula "empty formula" [] output

let test_parse_comments () =
  let output = parse_dimacs_string
"c Comment 1
c Comment 2
c Comment 3" in
  check formula "comments" [] output

let test_parse_init () =
  let output = parse_dimacs_string "p cnf 0 0" in
  check formula "init line" [] output

let test_parse_formula () =
  let output = parse_dimacs_string
"c This is an example formula
p cnf 2 2
1 0
-2 0" in
  check formula "formula" [[Pos 1]; [Neg 2]] output

let () =
  run "Parsing" [
      "parse_dimacs_string", [
        "parse empty", `Quick, test_parse_empty;
        "parse comments", `Quick, test_parse_comments;
        "parse init", `Quick, test_parse_init;
        "parse formula", `Quick, test_parse_formula;
      ];
    ]
