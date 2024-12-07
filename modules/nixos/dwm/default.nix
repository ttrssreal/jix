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
  options.jix.dwm.enable = lib.mkEnableOption "dwm";

  config = {
    services = lib.mkIf cfg.enable {
      xserver = {
        enable = true;
        xkb.layout = "nz";

        windowManager.dwm = {
          enable = true;
          package = pkgs.dwm.overrideAttrs (final: prev: {
            src = pkgs.fetchFromGitHub {
              owner = "ttrssreal";
              repo = "dwm";
              rev = "c7f44d913d249bfb3dcd6ba1a6c51d052806c6aa";
              hash = "sha256-Srj+oAYYK652AcOnQICa4w6jbMm5pQc1q6wuY829oY4=";
            };

            nativeBuildInputs = with pkgs; [
              pkg-config
              makeWrapper
            ];

            buildInputs = prev.buildInputs ++ (with pkgs; [
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
          });
        };

        displayManager.startx.enable = true;
      };
    };
  };
}
