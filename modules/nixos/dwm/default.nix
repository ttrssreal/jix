{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.jix.dwm;
in
{
  options.jix.dwm = {
    enable = lib.mkEnableOption "dwm";

    fontSize = lib.mkOption {
      type = lib.types.int;
      description = ''
        The font size of status bar text.
      '';
      default = 20;
    };
  };

  config = {
    services = lib.mkIf cfg.enable {
      xserver = {
        enable = true;
        xkb.layout = "nz";

        windowManager.dwm = {
          enable = true;
          package = pkgs.dwm.overrideAttrs (
            final: prev: {
              src = pkgs.fetchgit {
                name = "dwm";
                url = "git://git.suckless.org/dwm";
                rev = "e81f17d4c196aaed6893fd4beed49991caa3e2a4";
                hash = "sha256-URaV5ZgeJ7QbMKEa9QvtwT95fl+s/cLwpM1bmn3hLUw=";
              };

              patches = [
                ./dwm-config-001.patch

                (pkgs.replaceVars ./update-fontsize-dyn.patch {
                  inherit (cfg) fontSize;
                })
              ];

              nativeBuildInputs = with pkgs; [
                pkg-config
                makeWrapper
              ];

              buildInputs =
                prev.buildInputs
                ++ (with pkgs; [
                  dbus
                  bluetooth-connect
                  dmenu
                  alacritty
                  flameshot
                ]);

              postInstall = ''
                wrapProgram $out/bin/dwm \
                  --suffix PATH : ${lib.makeBinPath final.buildInputs}
              '';
            }
          );
        };

        displayManager.startx.enable = true;
      };
    };
  };
}
