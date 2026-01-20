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

    enableGitSendEmail = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.git = {
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

          settings = lib.mkIf cfg.enableGitSendEmail {
            "credential \"smtp://smtp.office365.com:587\"" = {
              # the git-credential-email package takes a `scripts` argument that is not a package.
              # this "pollutes" the global package namespace meaning it breaks if a consumer has
              # a package named `scripts` in her overlay. so override it for now and fix it upstream later.
              helper = "${lib.getExe' (pkgs.git-credential-email.override {
                scripts = [
                  "git-credential-aol"
                  "git-credential-gmail"
                  "git-credential-outlook"
                  "git-credential-yahoo"
                  "git-msgraph"
                  "git-protonmail"
                ];
              }) "git-credential-outlook"}";
            };

            sendemail = {
              smtpEncryption = "tls";
              smtpServer = "smtp.office365.com";
              smtpUser = "jess@jessie.cafe";
              smtpServerPort = 587;
              smtpAuth = "XOAUTH2";
              from = "Jess <jess@jessie.cafe>";
            };
          };

          ignores = [
            ".direnv"
            ".envrc"
            ".env"
            "dev-stuff"
            "result"
          ];
        };
      }

      (lib.mkIf cfg.enableGitSendEmail {
        services.gnome-keyring.enable = true;

        home.packages = [
          pkgs.gcr
        ];
      })
    ]
  );
}
