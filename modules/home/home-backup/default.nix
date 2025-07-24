{
  lib,
  config,
  ...
}:
let
  cfg = config.jix.home-backup;
in
{
  imports = [
    (lib.mkAliasOptionModule
      [ "jix" "home-backup" "exclude" ]
      [ "services" "restic" "backups" "home" "exclude" ]
    )
  ];

  options.jix.home-backup = {
    enable = lib.mkEnableOption "home-backup";
    hostname = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    sops.secrets = {
      home-backup-bucket = { };
      home-backup-repo-password = { };
      home-backup-access-key-id = { };
      home-backup-secret-access-key = { };
    };

    sops.templates.homeBackupRepositoryFile.content = ''
      s3:${config.sops.placeholder.home-backup-bucket}/${config.home.username}/${cfg.hostname}
    '';

    sops.templates.homeBackupCredsEnvironmentFile.content = ''
      AWS_ACCESS_KEY_ID=${config.sops.placeholder.home-backup-access-key-id}
      AWS_SECRET_ACCESS_KEY=${config.sops.placeholder.home-backup-secret-access-key}
    '';

    services.restic = lib.mkIf cfg.enable {
      enable = true;
      backups = {
        home = {
          initialize = true;
          repositoryFile = config.sops.templates.homeBackupRepositoryFile.path;
          passwordFile = config.sops.secrets.home-backup-repo-password.path;
          environmentFile = config.sops.templates.homeBackupCredsEnvironmentFile.path;
          paths = [
            config.home.homeDirectory
          ];
        };
      };
    };
  };
}
