{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.jix.git;
in
{
  options.jix.git = {
    enable = lib.mkEnableOption "git";

    githubForceSSH = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    autostartGpgAgent = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config.programs.git = lib.mkIf cfg.enable {
    enable = true;
    userEmail = "jess@jessie.cafe";
    userName = "Jess";
    signing = {
      key = "BA3350686C918606";
      signByDefault = true;
    };
    extraConfig = lib.mkIf cfg.githubForceSSH {
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
    signing.signer = "${pkgs.writeShellScript "gnupg-signer" ''
      "${lib.getExe pkgs.gnupg}" \
        ${lib.optionalString (!cfg.autostartGpgAgent) "--no-autostart"} \
        "$@"
    ''}";
    ignores = [
      ".direnv"
      ".envrc"
      ".env"
      "dev-stuff"
      "result"
    ];
  };
}
