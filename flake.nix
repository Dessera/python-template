{
  description = "Standard Python development environment with poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcode = {
      url = "github:Dessera/nixcode";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    {
      flake-parts,
      poetry2nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        systems = [ "x86_64-linux" ];

        perSystem =
          { pkgs, system, ... }:
          let
            python = pkgs.python313;
            py = import ./python.nix {
              inherit pkgs poetry2nix python;
            };

            vscodium' = withSystem system ({ inputs', ... }: inputs'.nixcode.packages.python);
          in
          {
            packages = py.packages.default;

            devShells = {
              default = pkgs.mkShell {
                packages = with pkgs; [
                  nixd
                  nixfmt-rfc-style

                  py.env.default
                  ruff
                  poetry

                  vscodium'
                ];
              };
            };
          };
      }
    );
}
