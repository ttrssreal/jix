{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.jix.bluetooth-connect;
in
{
  options.jix.bluetooth-connect = {
    enable = lib.mkEnableOption "bluetooth-connect";

    deviceAddrs = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
    };
  };

  config = {
    home.packages = [
      pkgs.bluetooth-connect
    ];

    # mappings
    # icon/name -> mac addr
    xdg.configFile."bluetooth-connect/map".text = lib.concatLines (
      lib.mapAttrsToList (k: v: "${k}\t${v}") cfg.deviceAddrs
    );
  };
}
