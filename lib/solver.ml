open Formula

exception Unsat

let find_and_remove_unit_clause =
  List.find_map
    (function
     | [u] -> Some u
     | _ -> None)

let simplify fmla lit =
  fmla
  |> List.filter_map
       (fun clause ->
         if List.mem lit clause then
           (* clauses containing the literal are satisfied *)
           None
         else
           (* assume lit is true, so ~lit cannot be satisfied ->
              remove it from clauses *)
           let new_clause = List.filter (fun l -> l <> neg_lit lit) clause in
           if List.is_empty new_clause then
             (* empty clauses are unsatisfiable *)
             raise Unsat
           else
             Some new_clause)

let choose_literal hd_cls tl_clss =
  match find_and_remove_unit_clause (hd_cls :: tl_clss) with
  | Some lit -> lit
  | None ->
     assert (not (List.is_empty hd_cls));
     List.hd hd_cls

let rec solve_partial fmla ass =
  match fmla with
  | [] -> ass
  | hd_cls :: tl_clss ->
    (* choosing a literal does not raise *)
    let chosen_lit = choose_literal hd_cls tl_clss in
    let run_on_lit = run_with_simpl fmla ass in
    try
      (* may raise if setting the literal to true leads to
         contradiction. *)
      run_on_lit chosen_lit
    with Unsat ->
      (* assigning true to the literal is inadmissible. *)
      (* may also raise, but then there is no admissible assignment
         for the literal, so we let Unsat bubble through.*)
      run_on_lit (neg_lit chosen_lit)
and run_with_simpl fmla ass lit =
  let simplified = simplify fmla lit in
  solve_partial simplified (lit :: ass)

let solve fmla =
  try
    Some (solve_partial fmla [])
  with Unsat ->
    None

let check_assignment fmla ass =
  try
    ass
    |> ListLabels.fold_left ~f:simplify ~init:fmla
    |> fun simplified ->
       assert (List.is_empty simplified);
       true;
  with _ -> false
