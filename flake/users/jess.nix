{
  name,
  lib,
  config,
  ...
}:
let
  cfg = config.users.jess;

  home = config.users.homeConfigurations."jess@${name}";
in
{
  options.users.jess = {
    enable = lib.mkEnableOption "the jess user";

    # https://discourse.nixos.org/t/psa-pinning-users-uid-is-important-when-reinstalling-nixos-restoring-backups/21819
    uid = lib.mkOption {
      type = lib.types.int;
    };

    extraConfig = lib.mkOption {
      # "anything" because merge nice
      type = with lib.types; attrsOf anything;
      default = { };
    };
  };

  config.modules = lib.mkIf cfg.enable [
    (
      { pkgs, ... }:
      {
        users.users.jess = {
          description = "Jess";
          isNormalUser = true;

          inherit (cfg) uid;

          shell = pkgs.zsh;

          # we install zsh via hm, so tell
          # nixos to not worry
          ignoreShellProgramCheck = true;

          extraGroups = [
            "wheel"
          ];
        };
      }
    )

    {
      users.users.jess = cfg.extraConfig;
    }

    {
      home-manager = {
        inherit (home) extraSpecialArgs;

        users.jess.imports = home.modules;
      };
    }
  ];
}
