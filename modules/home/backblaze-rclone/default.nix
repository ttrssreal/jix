{ lib, config, ... }:
let
  cfg = config.jix.backblaze-rclone;
in
{
  options.jix.backblaze-rclone.enable = lib.mkEnableOption "the backblaze rclone remote";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.jix.sops.enable;
        message = "Rclone needs `jix.sops.enable = true` to use secrets.";
      }
    ];

    sops.secrets = {
      rclone-cli-s3-endpoint = { };
      rclone-cli-access-key-id = { };
      rclone-cli-secret-access-key = { };
    };

    programs.rclone = {
      enable = true;
      remotes.backblaze = {
        config = {
          type = "s3";
          provider = "Other";
        };

        secrets = {
          endpoint = config.sops.secrets.rclone-cli-s3-endpoint.path;
          access_key_id = config.sops.secrets.rclone-cli-access-key-id.path;
          secret_access_key = config.sops.secrets.rclone-cli-secret-access-key.path;
        };
      };
    };
  };
}
