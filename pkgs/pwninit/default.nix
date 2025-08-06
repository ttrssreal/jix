{
  pwninit-unwrapped,
  writeShellApplication,
  direnv,
}:
writeShellApplication {
  name = "pwninit";

  runtimeInputs = [
    pwninit-unwrapped
    direnv
  ];

  text = ''
    pwninit \
      --template-path ${./solve.py} \
      --template-bin-name bin \
      "$@"

    if [ ! -e ./.envrc ]; then
      echo "use nix" > .envrc
      direnv allow
    fi

    if [ ! -e ./shell.nix ]; then
      install -m644 ${./shell.nix} shell.nix
    fi
  '';
}
