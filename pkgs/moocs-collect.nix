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
  # Dictionary source for lindera-unidic 1.2.0 build.rs.
  # Fetch in advance via fetchurl for LINDERA_CACHE, as the sandbox restricts downloads.
  unidicMecab = fetchurl {
    url = "https://Lindera.dev/unidic-mecab-2.1.2.tar.gz";
    hash = "sha256-JKx1/k5E2XO1XmWEfDX6Suwtt6QaB7ScoSUUbbn8EYk=";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moocs-collect";
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
    hash = "sha256-xQHbwiZWy2WRddO09ViO+1m+2fryryoJfsR+azWu7B0=";
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
    # lindera-unidic offline dictionary
    export LINDERA_CACHE="$NIX_BUILD_TOP/lindera-cache"
    mkdir -p "$LINDERA_CACHE/1.2.0"
    cp ${unidicMecab} "$LINDERA_CACHE/1.2.0/unidic-mecab-2.1.2.tar.gz"

    # frontend build (cwd = apps/desktop)
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
        # Linux deb output: bin/app + share/applications + icons/.../app.png
        # rename `app` -> `moocs-collect`
        mv $out/bin/app $out/bin/moocs-collect

        for f in $out/share/icons/hicolor/*/apps/app.png; do
          mv "$f" "$(dirname "$f")/moocs-collect.png"
        done

        substituteInPlace $out/share/applications/collect.desktop \
          --replace-fail 'Exec=app' 'Exec=moocs-collect' \
          --replace-fail 'StartupWMClass=app' 'StartupWMClass=moocs-collect' \
          --replace-fail 'Icon=app' 'Icon=moocs-collect'
        mv $out/share/applications/collect.desktop $out/share/applications/moocs-collect.desktop
      ''
    else
      ''
        # macOS .app bundle: $out/Applications/collect.app/Contents/MacOS/collect
        mv $out/Applications/collect.app $out/Applications/moocs-collect.app
        mkdir -p $out/bin
        ln -s $out/Applications/moocs-collect.app/Contents/MacOS/collect $out/bin/moocs-collect
      '';

  meta = {
    description = "INIAD MOOCs slide downloader (desktop)";
    homepage = "https://github.com/yu7400ki/moocs-collect";
    license = lib.licenses.mit;
    mainProgram = "moocs-collect";
    platforms = lib.platforms.unix;
  };
})
