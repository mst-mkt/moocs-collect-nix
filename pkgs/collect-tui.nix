{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  dbus,
  libsecret,
  apple-sdk,
  stdenv,
  src,
}:

rustPlatform.buildRustPackage {
  pname = "collect-tui";
  version = "0.0.0";

  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  cargoBuildFlags = [
    "-p"
    "collect-tui"
  ];
  cargoTestFlags = [
    "-p"
    "collect-tui"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
    libsecret
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  env.OPENSSL_NO_VENDOR = "1";

  meta = {
    description = "INIAD MOOCs slide downloader (TUI)";
    homepage = "https://github.com/mst-mkt/moocs-collect/tree/feat/tui";
    license = lib.licenses.mit;
    mainProgram = "collect-tui";
    platforms = lib.platforms.unix;
  };
}
