{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    arion.url = "github:hercules-ci/arion";
    lib-python-my-library.url = "github:chadac/test-nixspace-lib-python-my-library";
  };

  outputs = { self, flake-parts, systems, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      flake = {
        lib = {
          arionModule = { pkgs, ... }: let
            inherit (pkgs) system bash;
            inherit (self.packages.${system}) rest-api;
          in {
            services.rest-api = {
              service.image = "nixos/nix:latest";
              service.useHostStore = true;
              service.command = ["${bash}/bin/bash" "-c" "${rest-api}/bin/rest-api"];
              service.ports = ["8000:8000"];
            };
          };
        };
      };
      perSystem = { pkgs, system, ... }: let
        inherit (pkgs) python3;
      in {
        packages = rec {
          default = package;
          package = pkgs.callPackage ./. {
            inherit python3;
            my-library = inputs.lib-python-my-library.packages.${system}.default;
          };
          env = python3.withPackages(p: [ package ] ++ (with p; [
            gunicorn
          ]));
          rest-api = pkgs.writeShellScriptBin "rest-api" ''
            ${env}/bin/gunicorn -w 4 -b 0.0.0.0 'my_rest_api.main:app'
          '';
          compose-file = inputs.arion.lib.build {
            inherit pkgs;
            modules = [
              { project.name = "my_rest_api"; }
              self.lib.arionModule
            ];
          };
        };
      };
    };
}
