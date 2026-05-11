{
  description = "Nix packaging for MOOCs Collect";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    moocs-collect-src = {
      url = "github:yu7400ki/moocs-collect/cli-v1.0.2";
      flake = false;
    };

    moocs-collect-tui-src = {
      url = "github:mst-mkt/moocs-collect/feat/tui";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      moocs-collect-src,
      moocs-collect-tui-src,
      ...
    }:
    let
      overlay = final: _prev: {
        collect-cli = final.callPackage ./pkgs/collect-cli.nix {
          src = moocs-collect-src;
        };
        collect-tui = final.callPackage ./pkgs/collect-tui.nix {
          src = moocs-collect-tui-src;
        };
        mcmerge = final.callPackage ./pkgs/mcmerge.nix {
          src = moocs-collect-src;
        };
        moocs-collect = final.callPackage ./pkgs/moocs-collect.nix {
          src = moocs-collect-src;
        };
      };
    in
    {
      overlays.default = overlay;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          inherit (pkgs)
            collect-cli
            collect-tui
            mcmerge
            moocs-collect
            ;
          default = pkgs.collect-cli;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            pkgs.collect-cli
            pkgs.mcmerge
            pkgs.collect-tui
          ];
          packages = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            rust-analyzer
            nodejs_20
            pnpm
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
