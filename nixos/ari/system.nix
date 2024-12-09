# convert this to a profile once the cluster becomes multinodal

{
  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services = {
    openssh.enable = true;

    # kuwubernetes
    k3s = {
      enable = true;
      role = "server";
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
