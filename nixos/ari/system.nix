{
  imports = [
    ./radicale
    ./availability-listener.nix
    ./prometheus.nix
    ./mc-monitor.nix
  ];

  # for minecraft docker compose in systemd
  systemd.tmpfiles.rules = [
    "f /var/lib/systemd/linger/jess"
  ];

  # let colmena escalate to root
  security.sudo.wheelNeedsPassword = false;

  jix.sops.enable = true;

  jix.hostKey = {
    enable = true;
    generate = true;
    publicKey = ./hostKey.pub;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        StreamLocalBindUnlink = true;
      };
    };

    tailscale.enable = true;

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

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;

    interfaces.eno1 = {
      ipv4.addresses = [
        {
          address = "192.168.150.2";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.150.1";
      interface = "eno1";
    };

    nameservers = [ "192.168.150.1" ];
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S1ATNSADC61770E";
  };
}
