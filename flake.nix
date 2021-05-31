{
  description = ''
    Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication
    to Cisco SSL-VPNs'';

  inputs.poetry2nix-src.url = "github:nix-community/poetry2nix/1.15.4";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          inputs.poetry2nix-src.overlay
          (final: prev:
            let
              withOpenConnect = (final.callPackage ./nix {
                pkgs = final;
                sources = { };
              });
            in {
              inherit (withOpenConnect) openconnect-sso;
              openconnect-shell = withOpenConnect.shell;
            })
        ];
        pkgs = import nixpkgs { inherit system overlays; };
      in rec {
        packages.openconnect-sso = pkgs.openconnect-sso;
        defaultPackage = packages.openconnect-sso;
        devShell = pkgs.openconnect-shell;
      });
}
