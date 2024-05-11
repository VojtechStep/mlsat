open Formula

open struct
  type parser_state = Init
                    | Reading of formula

  let formula_of_state = function
    | Init -> []
    | Reading f -> f

  let parse_clause line =
    line
    |> String.trim
    |> String.split_on_char ' '
    |> List.map int_of_string
    |> ListLabels.fold_left
         ~f:(fun clause id ->
           if id < 0 then
             Neg (-id) :: clause
           else if id > 0 then
             Pos id :: clause
           else clause)
         ~init:[]

  let parse_dimacs_line state line =
    if line = "" || String.starts_with ~prefix:"c" line then
      state
    else
      match state with
      | Init ->
         assert (String.starts_with ~prefix:"p cnf" line);
         Reading []
      | Reading fmla -> Reading (parse_clause line :: fmla)
end

let parse_dimacs_string input =
  input
  |> String.split_on_char '\n'
  |> ListLabels.fold_left ~f:parse_dimacs_line ~init:Init
  |> formula_of_state

let parse_dimacs_channel channel =
  channel
  |> In_channel.fold_lines parse_dimacs_line Init
  |> formula_of_state

let parse_assignment_string = parse_clause

let parse_assignment_channel channel =
  channel
  |> In_channel.input_line
  |> Option.get
  |> parse_assignment_string
