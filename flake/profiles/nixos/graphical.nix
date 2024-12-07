{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.graphical;
in
{
  options.profiles.graphical = {
    enable = lib.mkEnableOption "the graphical profile";

    windowManager = lib.mkOption {
      type = lib.types.enum [
        "dwm"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    profiles.base.enable = true;

    modules = [
      {
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
      }

      {
        jix.${cfg.windowManager}.enable = true;
      }

      (
        { pkgs, ... }:
        {
          fonts = {
            # this has to be at the system level bc it looks
            # like HM cant install fonts per-user?
            packages = with pkgs; [
              # nvim tree
              nerd-fonts.hack

              # alacritty
              fira-mono
            ];

            fontDir.enable = true;

            fontconfig = {
              enable = true;
              hinting.autohint = true;
            };
          };
        }
      )
    ];
  };
}
