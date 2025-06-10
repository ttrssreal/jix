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
          package = pkgs.dwm.overrideAttrs (
            final: prev: {
              src = pkgs.fetchFromGitHub {
                owner = "ttrssreal";
                repo = "dwm";
                rev = "6ad82b7a9d46bae8e6d803f37c081806b332b32d";
                hash = "sha256-0tcpLfn/Au0ZSWyglrwkZPs6ilG+88gaRklbm9Q02os=";
              };

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
