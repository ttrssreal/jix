{
  config,
  ...
}:
{
  imports = [
    ./argocd
  ];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  jix.argocd.targetRevision = "af5994c42321cc8beb5f7cf198348c656e5b452e";

  services = {
    openssh.enable = true;

    # kuwubernetes
    kubernetes = {
      masterAddress = config.networking.hostName;

      roles = [
        "master"
        "node"
      ];
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
