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

    wallpaperDir = lib.mkOption {
      type = lib.types.path;
      default = ../../../res/wallpaper;
    };

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
        jix.alacritty.enable = true;
      }

      (
        { lib, pkgs, ... }:
        lib.mkIf (cfg.windowManager == "dwm") {
          jix.picom.enable = true;

          jix.xinit = {
            enable = true;
            init = {
              preExecWindowManager = lib.hm.dag.entryAfter [ "beginScript" ] ''
                # fix java grey screen issue
                # https://youtrack.jetbrains.com/issue/IJPL-142746/JAVAAWTWMNONREPARENTING-is-ignored-since-2018.1
                export _JAVA_AWT_WM_NONREPARENTING=1

                ${lib.getExe pkgs.feh} --bg-max --randomize ${cfg.wallpaperDir}/* &

                # https://github.com/NixOS/nixpkgs/blob/b6aa3932ce2378307f72d10cbaa80f8af1545abc/nixos/modules/services/x11/display-managers/default.nix#L238
                ${lib.getExe' pkgs.systemd "systemctl"} --user start --no-block nixos-fake-graphical-session.target
              '';

              execWindowManager = lib.hm.dag.entryAfter [ "preExecWindowManager" ] ''
                # will be on PATH if using (cfg.windowManager == "dwm")
                exec dwm
              '';
            };
          };
        }
      )
    ];
  };
}
