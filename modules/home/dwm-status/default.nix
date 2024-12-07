{
  lib,
  config,
  pkgs,
  ...
}:
let
  # https://github.com/nix-community/home-manager/blob/d00c6f6d0a/modules/services/dwm-status.nix#L10
  featureType = lib.types.enum [
    "audio"
    "backlight"
    "battery"
    "cpu_load"
    "network"
    "time"
  ];

  cfg = config.jix.dwm-status;
in
{
  options.jix.dwm-status = {
    enable = lib.mkEnableOption "dwm status bar";

    features = lib.mkOption {
      type = with lib.types; listOf featureType;
      default = [ ];
    };

    inherit (config.services.dwm-status) extraConfig;
  };

  config.services.dwm-status = lib.mkIf cfg.enable {
    enable = true;

    package = pkgs.dwm-status.overrideAttrs (
      final: prev: {
        # fixes for https://github.com/Gerschtli/dwm-status/issues/175
        # TODO: Remove dwm-status override once network fix makes it into a release
        src = pkgs.fetchFromGitHub {
          owner = "Gerschtli";
          repo = prev.pname;
          rev = "8eede31a129de117b737fb0acf13f9ff453a295f";
          sha256 = "sha256-VBd7htaj2Xk8zWZ7SmnKKt7QdkdXrO3M2K6vO8Evoug=";
        };

        cargoDeps = prev.cargoDeps.overrideAttrs {
          inherit (final) src;

          outputHash = "sha256-KDOcdzdfRwalCCRp96FToc+pFYGWU4RENgioun4qu0U=";
        };
      }
    );

    order = cfg.features ++ [
      "network"
      "time"
    ];

    extraConfig = {
      network.template = "{IPv4}";
      time = {
        format = "%a %d %b %H:%M:%S";
        update_seconds = true;
      };
    };
  };
}
