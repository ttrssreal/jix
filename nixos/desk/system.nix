{ pkgs, ... }:
{
  imports = [
    ./ghidra-server.nix
  ];

  hardware.graphics.enable = true;
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "jess" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.qemu.vhostUserPackages = [
    pkgs.virtiofsd
  ];

  services.tailscale.enable = true;

  jix.hostKey = {
    enable = true;
    generate = true;
    publicKey = ./hostKey.pub;
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
    enable = true;
  };

  services.udev.packages = [
    pkgs.particle-cli
  ];

  jix = {
    dwm.fontSize = 15;
    sops.enable = true;
    buildtime-secrets.enable = true;
    pipewire.enable = true;
  };

  hardware.bluetooth.enable = true;

  # Bootloader.
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/nvme0n1";
      useOSProber = true;
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    supportedFilesystems = [
      "ntfs"
    ];
  };

  programs.steam.enable = true;
}
