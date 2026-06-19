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

    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    output = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
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
      }
      // (lib.optionalAttrs cfg.laptop {
        "battery all" = {
          enable = true;
          position = 0;
          settings = {
            format = "%status %remaining (%percentage %consumption)";
            format_percentage = "%.00f%s";
            format_down = "No battery";
            status_chr = "⚡ CHR";
            status_bat = "🔋 BAT";
            status_unk = "? UNK";
            status_full = "☻ FULL";
            status_idle = "☻ IDLE";
            low_threshold = 10;
          };
        };

        "wireless _first_" = {
          enable = true;
          position = 1;
          settings = {
            format_up = "W: (%essid, %bitrate) %ip";
            format_down = "W: down";
          };
        };
      })
      // (lib.optionalAttrs (!cfg.laptop) {
        "ethernet _first_" = {
          enable = true;
          position = 1;
          settings = {
            format_up = "%ip (%speed)";
            format_down = "Eth: down";
          };
        };
      });
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        inherit (cfg) output;

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
            "${modifier}+o" = "exec " + "${lib.getExe' pkgs.bluetooth-connect "bluetooth-connect"}";
          };
        input = lib.optionalAttrs cfg.laptop {
          "type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
            natural_scroll = "enabled";
            middle_emulation = "enabled";
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

      extraConfig = ''
        for_window [app_id="flameshot"] border pixel 0, floating enable, fullscreen disable, move absolute position 0 0
        for_window [app_id="Alacritty"] floating enable
      '';
    };
  };
}
