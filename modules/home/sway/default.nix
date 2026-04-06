{
  lib,
  config,
  pkgs,
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
    programs.i3status = {
      enable = true;
      enableDefault = false;
      general.output_format = "i3bar";

      modules = {
        "disk /" = {
          enable = true;
          position = 0;
          settings = {
            format = "D: %free";
          };
        };
        "ethernet _first_" = {
          enable = true;
          position = 1;
          settings = {
            format_up = "%ip (%speed)";
            format_down = "Eth: down";
          };
        };
        "memory" = {
          enable = true;
          position = 2;
          settings = {
            format = "RAM: %used (%percentage_used)";
            format_degraded = "RAM: %used (%percentage_used) PRESSURE";
            threshold_degraded = "%10";
          };
        };
        "tztime local" = {
          enable = true;
          position = 3;
          settings = {
            format = "%a %d %b %H:%M:%S";
          };
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "alacritty";
        keybindings =
          let
            modifier = config.wayland.windowManager.sway.config.modifier;
          in
          lib.mkOptionDefault {
            "${modifier}+Shift+c" = "kill";
            "${modifier}+p" =
              "exec "
              + lib.concatStringsSep " | " [
                "${lib.getExe' pkgs.dmenu "dmenu_path"}"
                "${lib.getExe' pkgs.dmenu "dmenu"}"
                "${lib.getExe' pkgs.findutils "xargs"} swaymsg exec --"
              ];
          };
        output = {
          HDMI-A-1 = {
            mode = "1920x1080";
            position = "0 0";
          };
          DP-1 = {
            mode = "1280x1024";
            position = "1920 0";
          };
        };
        startup = lib.mapAttrsToList (k: _: {
          always = true;
          command = lib.concatStringsSep " " [
            "${lib.getExe' pkgs.sway "swaymsg"}"
            "output ${k}"
            "background \"$(find \"${../../../res}\" -type f | shuf -n 1)\""
            "fill"
          ];
        }) config.wayland.windowManager.sway.config.output;
        bars = [
          {
            mode = "dock";
            fonts = {
              names = [ "monospace" ];
              size = 12.0;
            };
            position = "top";
            statusCommand = "${pkgs.i3status}/bin/i3status";
            extraConfig = ''
              binding_mode_indicator yes
            '';
          }
        ];
      };
    };
  };
}
