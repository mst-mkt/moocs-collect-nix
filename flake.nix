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

    moocs-collect-ex-src = {
      url = "github:skmtrd/moocs-collect-ex/main";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      moocs-collect-src,
      moocs-collect-tui-src,
      moocs-collect-ex-src,
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
        moocs-collect-ex = final.callPackage ./pkgs/moocs-collect-ex.nix {
          src = moocs-collect-ex-src;
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
            moocs-collect-ex
            ;
          default = pkgs.collect-cli;
        };

        formatter = pkgs.nixfmt;
      }
    );
}
