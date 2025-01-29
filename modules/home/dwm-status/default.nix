{
  lib,
  config,
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
