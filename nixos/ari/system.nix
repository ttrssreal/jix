{
  networking.networkmanager.enable = true;

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
    device = "/dev/sda";
  };
}
