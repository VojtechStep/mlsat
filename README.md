# MLSAT

Simple SAT solver written in OCaml.

## Building

The solver is easiest to build with Nix. Run
`nix develop --command dune build --profile=release`. That produces
the binary `_build/default/bin/main.exe` (the `.exe` extension is an
OCaml convention, even on Unix systems).

## Command line interface

By default, the binary expects a path to the file containing a Dimacs
file, loads it and does nothing.

Adding the `--size 2` or `--size 3` flag makes the solver interpret
the problem and solution as 4x4 or 9x9 sudoku puzzles, respectively.
It then renders the problem and solutions in the terminal.

Adding the `--solve` flag tells the solver to actually solve the
problem. If the `--print` flag is present, it prints the solution on
standard output as a space-separated list of signed numbers.

Adding the `--solution solution_path` flag tells the binary to also
verify (and potentially render) an existing solution.

If the `--solution` flag is present, it is not necessary to provide a
problem file. This is only useful in combination with the `--size`
flag, because it renders the loaded solution.

## Examples

```bash
./_build/default/bin/main.exe --size 2 --solve --solution test/data/sudoku_mini_solution.txt test/data/sudoku_mini.txt
```

```bash
./_build/default/bin/main.exe --print --solve test/data/sudoku_hard.txt
```

```bash
./_build/default/bin/main.exe --print --solve test/data/sudoku_easy.txt > computed.txt \
  && ./_build/default/bin/main.exe --size 3 --solution computed.txt
```
