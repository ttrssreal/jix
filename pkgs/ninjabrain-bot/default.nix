{
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "ninjabrain-bot";
  version = "1.5.2-PRE1";

  src = fetchFromGitHub {
    owner = "Ninjabrain1";
    repo = "Ninjabrain-Bot";
    rev = "6573894ba618e948b8888a376ce75bbd65b6c6de";
    hash = "sha256-RJHZ0UfHrZOm7+fibcvN5sNP6w/k3mgXtu/9f+rrPBs=";
  };

  patches = [
    ./delete-extra-v-character-after-pasting.patch
  ];

  mvnHash = "sha256-ECJOdWgVVlMuMzBCVy6RdwvjzEjuYbMyqdiYRUBAV+c=";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/java
    install -Dm644 target/ninjabrainbot-${version}.jar $out/share/java

    classpath=$(find "$fetchedMavenDeps"/.m2 -name "*.jar" -printf ':%h/%f');
    classpath="$classpath:$out/share/java/ninjabrainbot-${version}.jar"

    makeWrapper ${jre}/bin/java $out/bin/ninjabrain-bot \
          --add-flags "-classpath ''${classpath#:}" \
          --add-flags "ninjabrainbot.Main"

    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "Accurate stronghold calculator for Minecraft speedrunning";
    homepage = "https://github.com/Ninjabrain1/Ninjabrain-Bot";
  };
}
