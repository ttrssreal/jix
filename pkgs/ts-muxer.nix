{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  zlib,
  freetype,
  ninja,
  pkg-config,
  qt5,
  buildWithGUI ? true,
  ...
}:
stdenv.mkDerivation {
  name = "tsMuxer";

  src = fetchFromGitHub {
    owner = "justdan96";
    repo = "tsMuxer";
    rev = "7f8667d1e6100a5b6407340d91ad80d57d976e58";
    sha256 = "sha256-JM3XpMQncTWMNrMVd2Iw9pguKDPbyfoO5l8EMWy2lOc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qttools
    qt5.qtmultimedia
    zlib
    freetype
  ];

  cmakeFlags = lib.optional buildWithGUI "-DTSMUXER_GUI=ON";
}
