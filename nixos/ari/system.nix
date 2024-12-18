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

  jix.argocd.targetRevision = "ed72be1463c0bb83d992e4d16f2caf05b2d2f05b";

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
