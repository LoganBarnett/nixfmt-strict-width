{
  description = "A nixfmt that honors --width wherever a line can break.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixfmt-strict-width = pkgs.callPackage ./default.nix { };
        in
        {
          inherit nixfmt-strict-width;
          default = nixfmt-strict-width;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Every construct in the fixture can break, so no formatted line may
          # pass the width.
          width =
            pkgs.runCommand "nixfmt-strict-width-width"
              {
                nativeBuildInputs = [
                  self.packages.${system}.nixfmt-strict-width
                  pkgs.gawk
                ];
              }
              ''
                nixfmt --width=80 - < ${./tests/over-width.nix} > formatted.nix
                awk '
                  length > 80 { print "over width: " $0; over = 1 }
                  END { exit over }
                ' formatted.nix
                touch $out
              '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.packages.${system}.nixfmt-strict-width
              pkgs.treefmt
            ];
          };
        }
      );
    };
}
