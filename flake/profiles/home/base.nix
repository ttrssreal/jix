{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  options.profiles.base.enable = lib.mkEnableOption "the minimal profile";

  config.modules = lib.mkIf cfg.enable [
    {
      home = {
        shellAliases = {
          vim = "nvim";
          gs = "git status";
          mrow = "echo mrow";
          curlo = "curl -LO";
        };
        language.base = "en_NZ.UTF-8";
      };
    }

    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    }

    {
      # auto start services
      systemd.user.startServices = "sd-switch";
    }

    # Let Home Manager install and manage itself.
    { programs.home-manager.enable = true; }

    {
      jix = {
        zsh.enable = true;
        git.enable = true;
        gpg.enable = true;
        jessvim.enable = true;
      };
    }

    {
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    }

    (
      { pkgs, ... }:
      {
        # common pkgs
        home.packages = with pkgs; [
          vim
          gnumake
          bintools
          zip
          unzip
          man-pages
          man-db
          tmux
          screen
          ltrace
          gnupg
          file
          dig
        ];
      }
    )
  ];
}
