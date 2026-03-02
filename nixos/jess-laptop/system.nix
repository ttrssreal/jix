# Yoga 7 14ITL5
{ pkgs, lib, ... }:
{
  imports = [
    ./displaylink.nix
  ];

  # TODO: remove once #491981 is merged
  _module.args.pkgs = pkgs.applyPatches {
    src = pkgs.path;
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nixpkgs/pull/491981.patch";
        sha256 = "sha256-awa9J5ZNUyz4Z2RqPVEovBTNng4AdhzS03Bqg8jejWQ=";
      })
    ];
  };

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
    thermald.enable = true;
    tlp.enable = true;
    tailscale.enable = true;

    # auto configure monitors
    udev.extraRules = ''
      ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.writeShellScript "start autorandr for jess" ''
        ${lib.getExe' pkgs.systemd "systemctl"} start \
          --user \
          --machine=jess@.host \
          --no-block \
          autorandr.service
      ''}"

      SUBSYSTEM=="usb", ATTRS{idVendor}=="1949", ATTRS{idProduct}=="9981", MODE="0666"
    '';

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

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [ "kvm-intel" ];

    # this driver was being fucky with rfkill
    # https://github.com/torvalds/linux/blob/9852d85ec9/drivers/platform/x86/ideapad-laptop.c#L1930-L1944
    blacklistedKernelModules = [ "ideapad_laptop" ];
  };
}
