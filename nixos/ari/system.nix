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

  jix.argocd.targetRevision = "e5a692ad6276328bcadc194d30b7804aa36d3dc2";

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
