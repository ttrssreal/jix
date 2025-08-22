{
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  libGL,
  glib,
  fontconfig,
  xorg,
  dbus,
  xkeyboard_config,
  libxkbcommon,
  qt6,
  lib,
  runCommand,
  awscli2,
  fetchFromGitHub,
  system,
}:
let
  fetchS3 = lib.fetchers.withNormalizedHash { } (
    {
      name,
      s3Path,
      s3Endpoint,
      outputHash,
      outputHashAlgo,
      credentialsSecret,
      ...
    }:
    runCommand name
      {
        nativeBuildInputs = [ awscli2 ];
        requiredSystemFeatures = [ "buildtime-secrets" ];
        buildtimeSecrets = [ credentialsSecret ];

        inherit outputHash outputHashAlgo;
      }
      ''
        export AWS_SHARED_CREDENTIALS_FILE=/secrets/${credentialsSecret}
        aws s3 cp --endpoint-url=${s3Endpoint} s3://${s3Path} $out
      ''
  );

  libxml_2_13_5_pkgs = fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "c75a2bda2fced25c24213d13011813a4c0affb5e";
    hash = "sha256-YcinmcTg6/CCSgqkZjTtrmlCt9iQpcgxjtuVU/t3/rU=";
  };

  inherit (import libxml_2_13_5_pkgs { inherit system; }) libxml2;
in
stdenv.mkDerivation {
  name = "binary-ninja";

  buildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    libGL
    stdenv.cc.cc.lib
    glib
    fontconfig
    xorg.libXi
    xorg.libXrender
    xorg.libxcb
    dbus
    libxkbcommon
    qt6.qtbase
    qt6.qtwayland
    libxml2
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  src = fetchS3 {
    name = "binaryninja_linux_stable_personal.zip";
    s3Path = "nix-private-66670f8190bb/binaryninja_linux_stable_personal.zip";
    s3Endpoint = "https://s3.us-west-002.backblazeb2.com";
    credentialsSecret = "binary-ninja-src-credentials";
    hash = "sha256-5F/L1S+a+uGHnL9FAml2tV4AAgEIDJ99PG3NET+Mc9o=";
  };

  doBuild = false;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    makeWrapper $out/opt/binaryninja \
          $out/bin/binaryninja \
          --prefix "QT_XKB_CONFIG_ROOT" ":" "${xkeyboard_config}/share/X11/xkb"
  '';
}
