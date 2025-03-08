{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  udev,
}:
buildNpmPackage rec {
  pname = "particle-cli";
  version = "3.32.7";

  buildInputs = [
    udev
  ];

  src = fetchFromGitHub {
    owner = "particle-iot";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-hWkzZgfKqznO8DcnhmE5ijGg7I68WTDgQ2elsAQafCY=";
  };

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  postInstall = ''
    install -D -t $out/etc/udev/rules.d \
      $out/lib/node_modules/${pname}/assets/50-particle.rules
  '';

  npmDepsHash = "sha256-RtcKBWMlmrhHl+zOLXBX0V74wd4EK2r/pUmi0wRuTz4=";
  dontNpmBuild = true;
  dontNpmPrune = true;

  meta = {
    description = "Command Line Interface for Particle Cloud and devices";
    homepage = "https://github.com/particle-iot/particle-cli";
    license = lib.licenses.asl20;
  };
}
