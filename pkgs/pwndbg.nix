{
  pwndbg-unwrapped,
  makeWrapper,
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  name = "jesspwn";

  src = ./jesspwn;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir $out
    cp -r * $out

    cat << EOF > $out/fix-sys-path.py
    import sys
    sys.path.append("$out")
    EOF

    makeWrapper ${lib.getExe' pwndbg-unwrapped "pwndbg"} $out/bin/pwndbg \
      --add-flags "--command=$out/fix-sys-path.py --command=$out/jesspwn.py"
  '';
}
