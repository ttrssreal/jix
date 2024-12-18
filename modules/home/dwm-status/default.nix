{
  lib,
  config,
  pkgs,
  ...
}:
let
  # https://github.com/nix-community/home-manager/blob/d00c6f6d0a/modules/services/dwm-status.nix#L10
  featureType = lib.types.enum [
    "audio"
    "backlight"
    "battery"
    "cpu_load"
    "network"
    "time"
  ];

  cfg = config.jix.dwm-status;
in
{
  imports = [
    (lib.mkAliasOptionModule
      [ "jix" "dwm-status" "extraConfig" ]
      [ "services" "dwm-status" "extraConfig" ]
    )
  ];

  options.jix.dwm-status = {
    enable = lib.mkEnableOption "dwm status bar";

    features = lib.mkOption {
      type = with lib.types; listOf featureType;
      default = [ ];
    };
  };

  config.services.dwm-status = lib.mkIf cfg.enable {
    enable = true;

    package = pkgs.dwm-status.overrideAttrs (
      final: prev: {
        # fixes for https://github.com/Gerschtli/dwm-status/issues/175
        # implements https://github.com/Gerschtli/dwm-status/issues/177
        # TODO: dwm-status: stop using fork once it reaches parity with upstream
        # Issue URL: https://github.com/ttrssreal/jix/issues/10
        src = pkgs.fetchFromGitHub {
          owner = "ttrssreal";
          repo = prev.pname;
          rev = "b89daf4fda0a019f764e46d194e3b178f7a9d699";
          sha256 = "sha256-Zi+SfsSWTnMYMdkfK+K/IKmy8rahDhjD3T6KJ+JL5rw=";
        };

        cargoDeps = prev.cargoDeps.overrideAttrs {
          inherit (final) src;

          outputHash = "sha256-dPqCyFWPqM/A2g23N1Of6BPijGMBu44xXSwVGO4j/Hk=";
        };
      }
    );

    order = cfg.features ++ [
      "network"
      "time"
    ];

    extraConfig = {
      network.template = lib.mkDefault "{LocalIPv4}";
      time = {
        format = lib.mkDefault "%a %d %b %H:%M:%S";
        update_seconds = lib.mkDefault true;
      };
    };
  };
}
