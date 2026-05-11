{
  lib,
  rustPlatform,
  src,
}:

rustPlatform.buildRustPackage {
  pname = "mcmerge";
  version = "0.1.0";

  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  cargoBuildFlags = [
    "-p"
    "mcmerge"
  ];
  cargoTestFlags = [
    "-p"
    "mcmerge"
  ];

  meta = {
    description = "PDF merge utility for moocs-collect";
    homepage = "https://github.com/yu7400ki/moocs-collect";
    license = lib.licenses.mit;
    mainProgram = "mcmerge";
    platforms = lib.platforms.all;
  };
}
