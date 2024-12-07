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
  options.jix.zsh.enable = lib.mkEnableOption "zsh";

  config.programs.zsh = lib.mkIf cfg.enable {
    enable = true;

    plugins = [
      zsh-nix-shell
    ];

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
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

    initExtra =
      # https://github.com/nix-community/home-manager/issues/2751
      ''
        export EDITOR="nvim" # ??
      ''
      + lib.concatLines (
        map builtins.readFile [
          ./nix-direnv-utils.sh
          ./nix-clean.sh
        ]
      );
  };
}
