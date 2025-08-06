let
  pkgs = import <nixpkgs> { };
  jix = builtins.getFlake "github:ttrssreal/jix";
  jixpkgs = jix.packages.x86_64-linux;
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    jixpkgs.pwntools
    jixpkgs.pwndbg
    jixpkgs.pwninit
    gdb # gdbserver for local
    python3Packages.icecream
  ];
}
