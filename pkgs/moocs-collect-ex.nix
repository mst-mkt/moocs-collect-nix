{
  lib,
  stdenv,
  rustPlatform,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  cargo-tauri,
  nodejs,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  gtk3,
  librsvg,
  openssl,
  glib-networking,
  dbus,
  libsecret,
  apple-sdk,
  darwin,
  fetchurl,
  src,
}:

let
  unidicMecab = fetchurl {
    url = "https://Lindera.dev/unidic-mecab-2.1.2.tar.gz";
    hash = "sha256-JKx1/k5E2XO1XmWEfDX6Suwtt6QaB7ScoSUUbbn8EYk=";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moocs-collect-ex";
  version = "1.0.2";

  inherit src;

  sourceRoot = "source/apps/desktop";

  postUnpack = ''
    chmod -R +w source
  '';

  pnpmRoot = "../..";
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-2687sZIQC+KEVbAfci0xNfTsO7kE8rv29y9ZCyrsX+Q=";
  };
  pnpmWorkspaces = [ "desktop" ];

  cargoRoot = "../..";
  cargoHash = "sha256-L3n1pg78X8TK7zNacSLW9erAuURd+JehZbgGmOHuojs=";

  buildAndTestSubdir = "src-tauri";

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"signingIdentity": "-"' '"signingIdentity": null'
  '';

  preBuild = ''
    export LINDERA_CACHE="$NIX_BUILD_TOP/lindera-cache"
    mkdir -p "$LINDERA_CACHE/1.2.0"
    cp ${unidicMecab} "$LINDERA_CACHE/1.2.0/unidic-mecab-2.1.2.tar.gz"

    pnpm run prepare
    pnpm run build
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpmConfigHook
    pnpm_10
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.xattr
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    gtk3
    librsvg
    glib-networking
    dbus
    libsecret
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  env.OPENSSL_NO_VENDOR = "1";

  postInstall =
    if stdenv.hostPlatform.isLinux then
      ''
        mv $out/bin/app $out/bin/moocs-collect-ex

        for f in $out/share/icons/hicolor/*/apps/app.png; do
          mv "$f" "$(dirname "$f")/moocs-collect-ex.png"
        done

        substituteInPlace $out/share/applications/collect.desktop \
          --replace-fail 'Exec=app' 'Exec=moocs-collect-ex' \
          --replace-fail 'StartupWMClass=app' 'StartupWMClass=moocs-collect-ex' \
          --replace-fail 'Icon=app' 'Icon=moocs-collect-ex'
        mv $out/share/applications/collect.desktop $out/share/applications/moocs-collect-ex.desktop
      ''
    else
      ''
        mv $out/Applications/collect.app $out/Applications/moocs-collect-ex.app
        mkdir -p $out/bin
        ln -s $out/Applications/moocs-collect-ex.app/Contents/MacOS/app $out/bin/moocs-collect-ex
      '';

  meta = {
    description = "INIAD MOOCs slide downloader (desktop, skmtrd/moocs-collect-ex fork)";
    homepage = "https://github.com/skmtrd/moocs-collect-ex";
    license = lib.licenses.mit;
    mainProgram = "moocs-collect-ex";
    platforms = lib.platforms.unix;
  };
})
