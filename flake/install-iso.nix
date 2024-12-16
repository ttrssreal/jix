# Custom NixOS (Live) ISO for manually boostrapping systems

{
  inputs,
  lib,
  options,
  ...
}:
{
  options.jix.install-iso.modules = lib.mkOption {
    type = with lib.types; listOf unspecified;
  };

  config = {
    jix.install-iso.modules = [
      (
        { modulesPath, ... }:
        {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
          ];

          # https://github.com/NixOS/nixpkgs/issues/292465
          nix.settings.extra-experimental-features = [
            "flakes"
          ];
        }
      )
    ];

    perSystem =
      { pkgs, ... }:
      {
        packages.install-iso = inputs.nixos-generators.nixosGenerate {
          inherit pkgs;

          inherit (options.jix.install-iso) modules;

          format = "iso";
        };
      };
  };
}
