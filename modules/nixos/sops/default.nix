{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.jix.sops;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.jix.sops.enable = lib.mkEnableOption "sops-nix";

  config = {
    assertions = [
      {
        assertion = config.jix.hostKey.enable;
        message = "The option `jix.hostKey` must be set to use secrets.";
      }
    ];

    sops = lib.mkIf cfg.enable {
      defaultSopsFile = ../../../secrets/nixos.yaml;
      age.sshKeyFile = config.jix.hostKey.privateKey.path;
    };
  };
}
