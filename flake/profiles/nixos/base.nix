{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  options.profiles.base = {
    enable = lib.mkEnableOption "the base profile";

    cache = lib.mkEnableOption "configuring the nix cache";
  };

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

    (lib.mkIf cfg.cache (
      { config, ... }:
      {
        assertions = [
          {
            assertion = config.jix.sops.enable;
            message = ''
              We need `jix.sops.enable = true` in order to authenticate with the nix cache
            '';
          }
        ];

        sops.secrets.nix-cache-creds-file = { };

        nix.settings = {
          netrc-file = config.sops.secrets.nix-cache-creds-file.path;

          substituters = [
            "https://ari.mudpuppy-cod.ts.net/nix-cache/main"
          ];

          trusted-public-keys = [
            "main:So8rfJkbLv5Vrd+y3agvPrDAA/9/SnTZz6RFHo+oFMM="
          ];
        };
      }
    ))

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
