{
  # let colmena escalate to root
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    settings.StreamLocalBindUnlink = true;
    enable = true;
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
