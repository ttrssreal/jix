# https://discourse.nixos.org/t/what-to-do-with-a-full-boot-partition/2049/2

nix-clean () {
  nix-env --delete-generations old
  nix-store --gc
  nix-channel --update
  nix-env -u --always
  for link in /nix/var/nix/gcroots/auto/*
  do
    rm $(readlink "$link")
  done
  nix-collect-garbage -d
}
