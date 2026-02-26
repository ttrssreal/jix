{
  pkgs,
  lib,
  config,
  ...
}:
let
  zsh-nix-shell = rec {
    name = "zsh-nix-shell";
    file = "nix-shell.plugin.zsh";
    src = pkgs.fetchFromGitHub {
      owner = "chisui";
      repo = name;
      rev = "v0.8.0";
      sha256 = "sha256-Z6EYQdasvpl1P78poj9efnnLj7QQg13Me8x1Ryyw+dM=";
    };
  };

  cfg = config.jix.zsh;
in
{
  options.jix.zsh = {
    enable = lib.mkEnableOption "zsh";

    createGpgSocketDir = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config.programs.zsh = lib.mkIf cfg.enable {
    enable = true;

    plugins = [
      zsh-nix-shell
    ];

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      custom = "${
        (pkgs.fetchFromGitHub {
          owner = "ohmyzsh";
          repo = "ohmyzsh";
          rev = "69a6359f7cf8978d464573fb7b023ee3cd00181a";
          hash = "sha256-M7oceuWwoJWmToETcmM6ed5UoJ0it5dNaukd5NqcMbs=";
          postFetch = ''
            cd $out
            patchPhase
          '';
        }).overrideAttrs
        {
          patches = [
            ./0001-show-hostname-if-ssh.patch
          ];
        }
      }";
      plugins = [
        "git"
        "extract"
        "minikube"
      ];
    };

    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    history.ignoreSpace = true;

    initContent = ''
      # https://github.com/nix-community/home-manager/issues/2751
      export EDITOR="nvim" # ??

      ${lib.optionalString cfg.createGpgSocketDir "${lib.getExe' pkgs.gnupg "gpgconf"} --create-socketdir"}

      ${lib.concatLines (
        map builtins.readFile [
          ./nix-direnv-utils.sh
          ./nix-clean.sh
        ]
      )}

      # https://lobste.rs/s/rcffs8/make_ts#c_g47l2u
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey "^X" edit-command-line
    '';
  };
}
