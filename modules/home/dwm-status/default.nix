{ lib, config, ... }:
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
  options.jix.dwm-status = {
    enable = lib.mkEnableOption "dwm status bar";

    features = lib.mkOption {
      type = with lib.types; listOf featureType;
    };

    inherit (config.services.dwm-status) extraConfig;
  };

  config = lib.mkIf cfg.enable {
    jix.dwm-status.features = [
      "network"
      "time"
    ];

    services.dwm-status = {
      enable = true;

      order = cfg.features;

      extraConfig = {
        network.template = "{IPv4}";
        time = {
          format = "%a %d %b %H:%M:%S";
          update_seconds = true;
        };
      };
    };
  };
}
