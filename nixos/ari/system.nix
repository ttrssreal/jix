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

  jix.argocd.targetRevision = "e9725767422d4913388d6e4f2e15f7886a21529a";

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
