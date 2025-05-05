{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.jix.gpg;
in
{
  options.jix.gpg.enable = lib.mkEnableOption "gpg";

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-curses;
    };
  };
}
