{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.daily;
in
{
  options.profiles.daily = {
    enable = lib.mkEnableOption "the daily profile";
  };

  config = lib.mkIf cfg.enable {
    profiles.graphical.enable = true;

    modules = [
      ./pkgs.nix
    ];
  };
}
