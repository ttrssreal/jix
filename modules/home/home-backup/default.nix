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
    passwordFile = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      home-backup-bucket = { };
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

    services.restic = {
      enable = true;
      backups = {
        home = {
          initialize = true;
          repositoryFile = config.sops.templates.homeBackupRepositoryFile.path;
          passwordFile = cfg.passwordFile;
          environmentFile = config.sops.templates.homeBackupCredsEnvironmentFile.path;
          pruneOpts = [
            "--keep-last 50"
            "--keep-weekly 50"
            "--keep-monthly 50"
            "--keep-yearly 50"
          ];
          paths = [
            config.home.homeDirectory
          ];
        };
      };
    };
  };
}
