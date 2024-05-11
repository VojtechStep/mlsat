open Alcotest
open Test_lib
open Mlsat.Parser
open Mlsat.Formula
open Mlsat.Solver

let test_solve_triv_pos () =
  let output = solve [[Pos 1]] in
  check assignment "assignment" (Some [Pos 1]) output

let test_solve_triv_neg () =
  let output = solve [[Neg 1]] in
  check assignment "assignment" (Some [Neg 1]) output

let test_solve_unsat () =
  let output = solve [[Pos 1]; [Neg 1]] in
  check assignment "assignment" None output

let test_check_triv () =
  check bool "trivial solution" true (check_assignment [[Pos 1]] [Pos 1])

let test_check_wrong () =
  check bool "wrong assignment" false (check_assignment [[Pos 1]] [Neg 1])

let check_pair name =
  let problem =
    In_channel.with_open_text ("data/" ^ name ^ ".txt") parse_dimacs_channel in
  let solution =
    In_channel.with_open_text ("data/" ^ name ^ "_solution.txt") parse_assignment_channel in
  check bool "provided examples" true (check_assignment problem solution)

let test_check_mini () = check_pair "sudoku_mini"

let test_check_easy () = check_pair "sudoku_easy"

let test_check_hard () = check_pair "sudoku_hard"

let solve_from_file name =
  let problem =
    In_channel.with_open_text ("data/" ^ name ^ ".txt") parse_dimacs_channel in
  let solution = solve problem |> Option.get in
  check bool "computed solution" true (check_assignment problem solution)

let test_solve_mini () = solve_from_file "sudoku_mini"

let test_solve_easy () = solve_from_file "sudoku_easy"

let test_solve_hard () = solve_from_file "sudoku_hard"

let () =
  run "Solving" [
      "solve", [
        "solve trivial pos", `Quick, test_solve_triv_pos;
        "solve trivial neg", `Quick, test_solve_triv_neg;
        "solve unsat", `Quick, test_solve_unsat;
        "solve mini sudoku", `Quick, test_solve_mini;
        "solve easy sudoku", `Quick, test_solve_easy;
        "solve hard sudoku", `Quick, test_solve_hard;
      ];
      "check", [
          "check trivial", `Quick, test_check_triv;
          "check trivial wrong", `Quick, test_check_wrong;
          "check mini sudoku", `Quick, test_check_mini;
          "check easy sudoku", `Quick, test_check_easy;
          "check hard sudoku", `Quick, test_check_hard;
        ]
    ]
