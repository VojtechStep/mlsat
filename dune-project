(lang dune 3.15)

(name mlsat)

(generate_opam_files true)

(source
 (github VojtechStep/mlsat))

(authors "VojtechStep")

(maintainers "VojtechStep")

(package
 (name mlsat)
 (synopsis "Simple SAT solver")
 (depends
  ocaml
  dune
  (alcotest :with-test)))
