{
  lib,
  config,
  ...
}:
let
  cfg = config.jix.sway;
in
{
  options.jix.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true;
  };
}
