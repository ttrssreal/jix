{ pkgs, ... }:
{
  hardware.graphics.enable = true;

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  services.openssh = {
    settings.PasswordAuthentication = false;
    enable = true;
  };

  services.udev.packages = [
    pkgs.particle-cli
  ];

  # Bootloader.
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sdb";
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
