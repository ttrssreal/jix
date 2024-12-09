with builtins;

let
  flake = getFlake "${unsafeDiscardStringContext ../.}";
in
flake.devShells.${currentSystem}.default
