{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  options.profiles.base.enable = lib.mkEnableOption "the base profile";

  config.modules = lib.mkIf cfg.enable [
    {
      nix = {
        # system gc config
        gc = {
          automatic = true;
          # monthly
          dates = "*-*-1";
          randomizedDelaySec = "1hr";
        };
        settings = {
          auto-optimise-store = true;
          trusted-users = [ "@wheel" ];
        };

        optimise.automatic = true;
      };
    }

    (
      {
        pkgs,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          git
          vim
          curl
          wget
          zip
          unzip
          python3
        ];

        i18n.defaultLocale = "en_NZ.UTF-8";
        time.timeZone = "Pacific/Auckland";
      }
    )
  ];
}
