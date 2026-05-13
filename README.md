# moocs-collect-nix

Nix flake for distributing [MOOCs Collect](https://yu7400ki.github.io/moocs-collect/).

## Packages

| `#name`            | Description                     | Source                                                                                            |
| ------------------ | ------------------------------- | ------------------------------------------------------------------------------------------------- |
| `collect-cli`      | slide downloader CLI            | [yu7400ki/moocs-collect](https://github.com/yu7400ki/moocs-collect/tree/main/apps/cli)            |
| `collect-tui`      | slide downloader TUI            | [mst-mkt/moocs-collect/feat/tui](https://github.com/mst-mkt/moocs-collect/tree/feat/tui/apps/tui) |
| `mcmerge`          | PDF merge utility               | [yu7400ki/moocs-collect](https://github.com/yu7400ki/moocs-collect/tree/main/apps/merge)          |
| `moocs-collect`    | Tauri desktop app               | [yu7400ki/moocs-collect](https://github.com/yu7400ki/moocs-collect/tree/main/apps/desktop)        |
| `moocs-collect-ex` | Tauri desktop app (skmtrd fork) | [skmtrd/moocs-collect-ex](https://github.com/skmtrd/moocs-collect-ex/tree/main/apps/desktop)      |

## Usage

```bash
nix run github:mst-mkt/moocs-collect-nix#moocs-collect
nix run github:mst-mkt/moocs-collect-nix#moocs-collect-ex
nix run github:mst-mkt/moocs-collect-nix#collect-cli
nix run github:mst-mkt/moocs-collect-nix#collect-tui
nix run github:mst-mkt/moocs-collect-nix#mcmerge
```

## Binary cache

Skip local builds by using the Cachix cache.

```bash
cachix use moocs-collect-nix
```

Alternatively, add to your nix configuration:

```nix
nix.settings = {
  extra-substituters = [ "https://moocs-collect-nix.cachix.org" ];
  extra-trusted-public-keys = [
    "moocs-collect-nix.cachix.org-1:MpREl4nnQpusRFLilrWt2S67SW1mLuqM6HvcirF/CjE="
  ];
};
```
