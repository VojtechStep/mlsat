open Formula

type point = int * int
type grid_value = int

(* x, y -> value *)
type grid = point -> grid_value option

let empty_grid: grid = fun _ -> None

let add_to_grid (p, value) (grid : grid): grid = fun q ->
  if q = p then
    Some value
  else grid q

module type Sudoku = sig
  val small_dimension : int
end

module type Renderer = sig
  val decode_atom: int -> point * grid_value
  val grid_of_formula: formula -> grid
  val grid_of_assignment: assignment -> grid
  val pp_print_grid: grid Fmt.t
end

module GridRenderer (S : Sudoku): Renderer = struct
  let dimension = S.small_dimension * S.small_dimension

  let decode_atom v =
    let b = dimension in
    let v = v - 1 in
    let n, v = v mod b, v / b in
    let y, v = v mod b, v / b in
    let x = v mod b in
    (x, y), n + 1

  let grid_of_assignment =
    ListLabels.fold_left
      ~f:(fun grid -> function
        | Pos a -> add_to_grid (decode_atom a) grid
        | _ -> grid)
      ~init:empty_grid

  let grid_of_formula fmla =
    fmla
    |> List.filter_map (function | [Pos a] -> Some (Pos a) | _ -> None)
    |> grid_of_assignment

  let pp_print_line left sep fill right fmt () =
    Format.pp_print_string fmt left;
    Format.pp_print_seq
      ?pp_sep:(Some (fun fmt () -> Format.pp_print_string fmt sep))
      (fun fmt () ->
        (* (2 * small - 1) - 1 = 2 * (small - 1) *)
        for _ = 0 to 2 * (S.small_dimension - 1) do Format.pp_print_string fmt fill done)
      fmt
      (Seq.init S.small_dimension (fun _ -> ()));
    Format.pp_print_string fmt right;
    Format.pp_print_newline fmt ()

  let pp_print_header = pp_print_line "┌" "┬" "─" "┐"

  let pp_print_middle = pp_print_line "├" "┼" "─" "┤"

  let pp_print_footer = pp_print_line "└" "┴" "─" "┘"

  let pp_print_row_part fmt row_part =
    Format.pp_print_list
      ?pp_sep:(Some (fun fmt () -> Format.pp_print_char fmt ' '))
      Format.pp_print_char
      fmt
      row_part;
    Format.pp_print_string fmt "│"

  let pp_print_row fmt row =
    Format.pp_print_string fmt "│";
    for part_offset = 0 to S.small_dimension - 1 do
      pp_print_row_part fmt
        (List.init S.small_dimension
           (fun x -> row (x + S.small_dimension * part_offset)))
    done;
    Format.pp_print_newline fmt ()

  let pp_print_rows fmt =
    List.iter (pp_print_row fmt)

  let pp_print_grid fmt grid =
    pp_print_header fmt ();
    Format.pp_print_list
      ?pp_sep:(Some pp_print_middle)
      pp_print_rows
      fmt
      (List.init S.small_dimension
         (fun rows_chunk ->
           List.init S.small_dimension
             (fun y x ->
               grid (y + S.small_dimension * rows_chunk, x)
               |> function
                 | Some value -> char_of_int (48 + value)
                 | None -> '-')));
    pp_print_footer fmt ()
end

module MiniRenderer =
  GridRenderer (struct
      let small_dimension = 2
    end)

module RegularRenderer =
  GridRenderer (struct
      let small_dimension = 3
    end)
