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
        assertion = !cfg.enable;
        # wait until this is merged to fully integrate secrets
        message = "https://github.com/Mic92/sops-nix/pull/779";
      }
    ];

    sops = lib.mkIf cfg.enable {
      defaultSopsFile = ../../../secrets/nixos.yaml;
      age.sshKeyPaths = [
        config.jix.hostKey.privateKey.path
      ];
    };
  };
}
