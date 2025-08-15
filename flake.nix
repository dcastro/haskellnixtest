# From: https://input-output-hk.github.io/haskell.nix/tutorials/getting-started.html#scaffolding

{
  description = "A very basic flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        overlays = [
          haskellNix.overlay
          (final: _prev: {
            # This overlay adds our project to pkgs
            helloProject = final.haskell-nix.project' {
              src = ./.;

              # Use stack.yaml instead of cabal.project
              projectFileName = "stack.yaml";

              compiler-nix-name = "ghc967";
              # This is used by `nix develop .` to open a shell for use with
              # `cabal`, `hlint` and `haskell-language-server`
              shell.tools = {
                cabal = { };
                # hlint = {};
                # haskell-language-server = {};
              };
              # Non-Haskell shell tools go here
              shell.buildInputs = with pkgs; [ nixpkgs-fmt ];
              # This adds `js-unknown-ghcjs-cabal` to the shell.
              # shell.crossPlatforms = p: [p.ghcjs];
            };
          })
        ];
        pkgs_ = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };
        pkgs = pkgs_.pkgsCross.aarch64-multiplatform;
        flake = pkgs.helloProject.flake {
          # This adds support for `nix build .#js-unknown-ghcjs:hello:exe:hello`
          # crossPlatforms = p: [p.ghcjs];
        };
      in flake // {
        packages = flake.packages // {
          # Built by `nix build .`
          default = flake.packages."haskellnixtest:exe:haskellnixtest-exe";
        };
      });
}
