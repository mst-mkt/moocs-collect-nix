# moocs-collect-nix

Nix flake for distributing [MOOCs Collect](https://yu7400ki.github.io/moocs-collect/).

## Packages

| `#name`         | Description          | Source                                                                                            |
| --------------- | -------------------- | ------------------------------------------------------------------------------------------------- |
| `collect-cli`   | slide downloader CLI | [yu7400ki/moocs-collect](https://github.com/yu7400ki/moocs-collect/tree/main/apps/cli)            |
| `collect-tui`   | slide downloader TUI | [mst-mkt/moocs-collect/feat/tui](https://github.com/mst-mkt/moocs-collect/tree/feat/tui/apps/tui) |
| `mcmerge`       | PDF merge utility    | [yu7400ki/moocs-collect](https://github.com/yu7400ki/moocs-collect/tree/main/apps/merge)          |
| `moocs-collect` | Tauri desktop app    | [yu7400ki/moocs-collect](https://github.com/yu7400ki/moocs-collect/tree/main/apps/desktop)        |

## Usage

```bash
nix run github:mst-mkt/moocs-collect-nix#moocs-collect
nix run github:mst-mkt/moocs-collect-nix#collect-cli
nix run github:mst-mkt/moocs-collect-nix#collect-tui
nix run github:mst-mkt/moocs-collect-nix#mcmerge
```
