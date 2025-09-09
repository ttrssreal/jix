{
  writeShellApplication,
  coreutils,
  nix,
  ...
}:
writeShellApplication {
  name = "nixpkgs-print-out-paths";

  runtimeInputs = [
    coreutils
    nix
  ];

  text = ''
    if [ "$#" -le 0 ]; then
      echo "usage: $(basename "$0" || echo "$0") <package> <extra 'nix build' args>"
      exit 1
    fi

    declare -r package=$1
    shift 1

    nix build nixpkgs#"$package" --print-out-paths "$@"
  '';
}
