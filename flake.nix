{
  description = "MLSat — a SAT solver written in OCaml";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      ocamlPkgs = pkgs.ocamlPackages;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "mlsat";

        packages = with ocamlPkgs; [
          ocaml
          findlib
          dune_3
          merlin
          alcotest
          utop
        ];

        env.MERLIN_MODE = "${ocamlPkgs.merlin}/share/emacs/site-lisp";
        env.DUNE_MODE = "${ocamlPkgs.dune_3}/share/emacs/site-lisp";
      };
    };
}
