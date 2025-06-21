{
  lib,
  config,
  withSystem,
  inputs,
  ...
}@tl:
let
  cfg = config.jix.nixos;

  nixosConfigModule =
    { name, config, ... }:
    {
      imports = [
        ./users
        ./profiles/nixos
      ];

      options = {
        system = lib.mkOption {
          type = with lib.types; nullOr (enum lib.platforms.all);
          default = null;
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

        flakeExpose = lib.mkOption {
          type = lib.types.bool;
          description = "Should this be a public configuration";
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

          # in contexts such as test nodes, this will be made read-only and
          # set to the realized nixpkgs hostPlatform.
          # https://github.com/NixOS/nixpkgs/blob/fdf56ea52203/nixos/modules/misc/nixpkgs/read-only.nix
          (lib.mkIf (config.system != null) {
            nixpkgs.hostPlatform = config.system;
          })

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
    };

  mkNodesOption =
    description: extra:
    lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          imports = [
            nixosConfigModule
            extra
          ];
        });
      inherit description;
      default = { };
    };
in
{
  options.jix.nixos = {
    nodes = mkNodesOption "Configs for real nodes" {
      flakeExpose = true;
    };

    test-nodes = mkNodesOption "Configs for testing" {
      flakeExpose = false;
    };
  };

  config.flake.nixosConfigurations =
    lib.pipe (lib.attrsets.unionOfDisjoint cfg.nodes cfg.test-nodes)
      [
        (lib.filterAttrs (_: lib.getAttr "flakeExpose"))
        (lib.mapAttrs (_: lib.getAttr "nixosConfiguration"))
      ];
}
