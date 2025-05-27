{
  lib,
  config,
  withSystem,
  inputs,
  ...
}@tl:
let
  cfg = config.jix.nixos;
in
{
  options.jix.nixos = lib.mkOption {
    type =
      with lib.types;
      attrsOf (
        submodule (
          { name, config, ... }:
          {
            imports = [
              ./users
              ./profiles/nixos
            ];

            options = {
              system = lib.mkOption {
                type = lib.types.enum lib.platforms.all;
              };

              modules = lib.mkOption {
                type = with lib.types; listOf unspecified;
              };

              specialArgs = lib.mkOption {
                type = with lib.types; attrsOf anything;
                default = { };
              };

              stateVersion = lib.mkOption {
                type = lib.types.str;
              };

              deployment = {
                enable = lib.mkEnableOption "this deployment";

                cfg = lib.mkOption {
                  description = "The colmena `deployment` option";
                  type = lib.types.attrs;
                  default = { };
                };
              };

              # the instantiated system configuration
              nixosConfiguration = lib.mkOption {
                internal = true;
                readOnly = true;
              };
            };

            config = {
              # expose so nixos can auto-load home configs
              users.homeConfigurations = tl.config.jix.home;

              modules = [
                ../modules/nixos

                { nixpkgs.hostPlatform = config.system; }
                { networking.hostName = name; }
                { system.stateVersion = config.stateVersion; }
              ];

              specialArgs = { inherit inputs; };

              nixosConfiguration = inputs.nixpkgs.lib.nixosSystem {
                # pass though flake level + overlayed, package set
                pkgs = withSystem config.system (lib.getAttr "pkgs");

                inherit (config) modules specialArgs;
              };
            };
          }
        )
      );
  };

  config.flake.nixosConfigurations = lib.mapAttrs (_: lib.getAttr "nixosConfiguration") cfg;
}
