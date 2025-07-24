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
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.jix.sops.enable = lib.mkEnableOption "sops-nix";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.jix.homeKey.enable;
        message = "The option `jix.homeKey` must be set to use secrets.";
      }
    ];

    sops = lib.mkIf cfg.enable {
      defaultSopsFile = ../../../secrets/nixos.yaml;
      age.sshKeyFile = config.jix.homeKey.privateKey.path;
    };
  };
}
