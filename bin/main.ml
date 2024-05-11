open Mlsat

type configuration = {
    problem_input: string option;
    solution_input: string option;
    print_raw_solution: bool;
    solve: bool;
    size: int;
  }

let usage_message = "mlsat [options] [problem file]"

let parse_args () =
  let size = ref 0 in
  let solve = ref false in
  let input_file = ref None in
  let solution_file = ref None in
  let print_raw_solution = ref false in
  Arg.parse [
      "--solution", Arg.String (fun file -> solution_file := Some file), "Existing solution to check";
      "--size", Arg.Set_int size, "Small square size of sudoku";
      "--solve", Arg.Set solve, "Solve the problem";
      "--print", Arg.Set print_raw_solution, "Print the solution as a list of literals"
    ]
    (fun file -> input_file := Some file)
  usage_message;
  {
    problem_input = !input_file;
    solution_input = !solution_file;
    size = !size;
    solve = !solve;
    print_raw_solution = !print_raw_solution;
  }

let print_assignment size solution =
  if size = 2 then
    let grid = Renderer.MiniRenderer.grid_of_assignment solution in
    Renderer.MiniRenderer.pp_print_grid Format.err_formatter grid
  else if size = 3 then
    let grid = Renderer.RegularRenderer.grid_of_assignment solution in
    Renderer.RegularRenderer.pp_print_grid Format.err_formatter grid

let process_solution annotation size problem solution =
  prerr_endline @@ "The " ^ annotation ^ " assignment";
  print_assignment size solution;
  match problem with
  | Some problem ->
     if Solver.check_assignment problem solution then
       prerr_endline "is a solution"
     else
       prerr_endline "is NOT a solution"
  | None -> ()

let print_formula size formula =
  if size = 2 then
    let grid = Renderer.MiniRenderer.grid_of_formula formula in
    Renderer.MiniRenderer.pp_print_grid Format.err_formatter grid
  else if size = 3 then
    let grid = Renderer.RegularRenderer.grid_of_formula formula in
    Renderer.RegularRenderer.pp_print_grid Format.err_formatter grid

let process_problem config problem =
  if config.size <> 0 then begin
      prerr_endline "The problem";
      print_formula config.size problem
    end;
  if config.solve then
    match Solver.solve problem with
    | None ->
       prerr_endline "Problem is unsatisfiable";
       exit 2
    | Some solution ->
       process_solution "computed" config.size (Some problem) solution;
       if config.print_raw_solution then begin
           Format.pp_print_list
             ?pp_sep:(Some (fun fmt () -> Format.pp_print_char fmt ' '))
             Formula.pp_print_lit
             Format.std_formatter
             solution;
           print_newline ()
         end

let process_problem_path config problem_path =
  let problem =
    In_channel.with_open_text problem_path
      Parser.parse_dimacs_channel in
  process_problem config problem;
  problem

let process_solution_path size problem solution_path =
  let solution =
    In_channel.with_open_text solution_path
      Parser.parse_assignment_channel in
  process_solution "loaded" size problem solution;
  solution

let () =
  let config = parse_args () in
  (match config.size with
   | 0 | 2 | 3 -> ()
   | _ ->
      prerr_endline "Printing only supports sizes 2 and 3";
      exit 1);
  match config.problem_input, config.solution_input with
  | None, None ->
     prerr_endline "Expeceted at least a problem file or a solution file";
     exit 1
  | Some problem_path, None ->
     ignore @@ process_problem_path config problem_path
  | None, Some solution_path ->
     ignore (process_solution_path config.size None solution_path)
  | Some problem_path, Some solution_path ->
     let problem = process_problem_path config problem_path in
     ignore @@ process_solution_path config.size (Some problem) solution_path
