{
  lib,
  config,
  ...
}:
let
  cfg = config.jix.home-backup;
  bucket = "https://s3.us-west-002.backblazeb2.com/home-backups-c054294cc6b8";
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

  config.services.restic = lib.mkIf cfg.enable {
    enable = true;
    backups = {
      home = {
        initialize = true;
        repository = "s3:${bucket}/${config.home.username}/${cfg.hostname}";
        passwordFile = "${config.home.homeDirectory}/.keys/restic-backups-home/password";
        environmentFile = "${config.home.homeDirectory}/.keys/restic-backups-home/b2-creds";
        paths = [
          config.home.homeDirectory
        ];
      };
    };
  };
}
