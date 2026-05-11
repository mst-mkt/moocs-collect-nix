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
  pname = "collect-cli";
  version = "1.0.2";

  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  cargoBuildFlags = [
    "-p"
    "collect-cli"
  ];
  cargoTestFlags = [
    "-p"
    "collect-cli"
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
    description = "INIAD MOOCs slide downloader (CLI)";
    homepage = "https://github.com/yu7400ki/moocs-collect";
    license = lib.licenses.mit;
    mainProgram = "collect-cli";
    platforms = lib.platforms.unix;
  };
}
