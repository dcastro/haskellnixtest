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

              # compiler-nix-name = "ghc9102";
              compiler-nix-name = "ghc9122";

              # https://github.com/input-output-hk/haskell.nix/issues/2423
              modules = [{
                packages.directory.flags.os-string = true;
                packages.unix.flags.os-string = true;
              }];

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
        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };

      in {
        packages = {
          aarch64-multiplatform =
            (pkgs.pkgsCross.aarch64-multiplatform.helloProject.flake
              { }).packages."haskellnixtest:exe:haskellnixtest-exe";
          aarch64-multiplatform-musl =
            (pkgs.pkgsCross.aarch64-multiplatform-musl.helloProject.flake
              { }).packages."haskellnixtest:exe:haskellnixtest-exe";

        };
      });
}
