{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.jix.buildtime-secrets;
in
{
  imports = [
    inputs.buildtime-secrets-nix.nixosModules.default
  ];

  options.jix.buildtime-secrets.enable = lib.mkEnableOption "buildtime-secrets";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.jix.hostKey.enable;
        message = "The option `jix.hostKey` must be set to use secrets.";
      }
    ];

    buildtimeSecrets = {
      enable = true;
      secretDirectory = "/run/bt-secrets";

      sops = {
        enable = true;
        sopsFile = ../../../secrets/buildtime.yaml;
        keyFile = config.jix.hostKey.privateKey.path;
      };
    };
  };
}
