{ pkgs, ... }:
{
  jix = {
    pipewire.enable = true;
    dwm.fontSize = 15;
    buildtime-secrets.enable = true;
    hostKey = {
      enable = true;
      generate = true;
      publicKey = ./hostKey.pub;
    };
    sops.enable = true;
  };

  services = {
    tailscale.enable = true;

    # used by status bar
    upower.enable = true;
  };

  hardware.graphics.extraPackages = [
    pkgs.intel-media-driver
  ];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs = {
    # needs to be system level as the module configures firewalls
    # and some opengl settings
    steam.enable = true;
    # this is the backend database gsettings uses, lets keep gnome
    # apps happy
    dconf.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-f0e12459-3aa7-4904-88c4-a73b625891c3".device =
    "/dev/disk/by-uuid/f0e12459-3aa7-4904-88c4-a73b625891c3";
}
