{ pkgs, lib, ... }:
{
  options.jix.podman.enable = lib.mkEnableOption "podman";

  config = {
    virtualisation = {
      containers.enable = true;

      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      skopeo
    ];
  };
}
