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

    dmenuFontSize = lib.mkOption {
      type = lib.types.int;
      description = ''
        The font size of the option picker.
      '';
    };
  };

  config = {
    home.packages = [
      (pkgs.bluetooth-connect.override {
        inherit (cfg) dmenuFontSize;
      })
    ];

    # mappings
    # icon/name -> mac addr
    xdg.configFile."bluetooth-connect/map".text = lib.concatLines (
      lib.mapAttrsToList (k: v: "${k}\t${v}") cfg.deviceAddrs
    );
  };
}
