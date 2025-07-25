{
  lib,
  config,
  withSystem,
  inputs,
  ...
}:
let
  cfg = config.jix.home;
in
{
  options.jix.home = lib.mkOption {
    type =
      with lib.types;
      attrsOf (
        submodule (
          { config, ... }:
          {
            imports = [
              ./profiles/home
            ];

            options = {
              modules = lib.mkOption {
                type = with lib.types; listOf unspecified;
              };

              system = lib.mkOption {
                type = lib.types.enum lib.platforms.all;
              };

              username = lib.mkOption {
                type = lib.types.str;
              };

              homeDirectory = lib.mkOption {
                type = lib.types.str;
              };

              stateVersion = lib.mkOption {
                type = lib.types.str;
              };

              extraSpecialArgs = lib.mkOption {
                type = with lib.types; attrsOf anything;
                default = { };
              };

              # the instantiated hm configuration
              homeConfiguration = lib.mkOption {
                internal = true;
                readOnly = true;
              };
            };

            config = {
              modules = [
                ../modules/home

                {
                  home = {
                    inherit (config) stateVersion homeDirectory username;
                  };
                }
              ];

              extraSpecialArgs = {
                inherit inputs;
              };

              homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration (
                withSystem config.system (
                  { pkgs, ... }:
                  {
                    inherit (config) extraSpecialArgs;
                    inherit pkgs;

                    modules = config.modules ++ [
                      # only include this module if we're coming from a
                      # standalone entrypoint
                      {
                        nix.package = pkgs.nix;
                      }
                    ];
                  }
                )
              );
            };
          }
        )
      );
  };

  config.flake.homeConfigurations = lib.mapAttrs (_: lib.getAttr "homeConfiguration") cfg;
}
