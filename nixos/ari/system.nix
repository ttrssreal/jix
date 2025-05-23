{
  networking.networkmanager.enable = true;

  # let colmena escalate to root
  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh.enable = true;

    postgresql = {
      enable = true;
      enableTCPIP = true;

      authentication = ''
        host all all all trust
      '';

      ensureDatabases = [
        "plausible"
      ];

      ensureUsers = [
        {
          name = "plausible";
          ensureDBOwnership = true;
        }
      ];
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S1ATNSADC61770E";
  };
}
