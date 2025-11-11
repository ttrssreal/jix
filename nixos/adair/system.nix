{
  # let colmena escalate to root
  security.sudo.wheelNeedsPassword = false;

  jix.fuzzing-metrics.enable = true;

  jix.aflplusplus = {
    adair-1 = {
      enable = true;
      main = true;
      target = "/home/jess/readelf-sans";
      corpusDir = "/home/jess/in";
      outDir = "/home/jess/out";
      extraArgs = [
        "-L"
        "0"
        "-P"
        "explore"
      ];
    };

    adair-2 = {
      enable = true;
      target = "/home/jess/readelf-cmplog";
      corpusDir = "/home/jess/in";
      outDir = "/home/jess/out";
      extraArgs = [
        "-Z"
        "-P"
        "exploit"
      ];
    };

    adair-3 = {
      enable = true;
      target = "/home/jess/readelf-laf";
      corpusDir = "/home/jess/in";
      outDir = "/home/jess/out";
      extraEnvs = [ "AFL_DISABLE_TRIM=1" ];
      extraArgs = [
        "-P"
        "exploit"
      ];
    };

    adair-4 = {
      enable = true;
      target = "/home/jess/readelf-nothing";
      corpusDir = "/home/jess/in";
      outDir = "/home/jess/out";
      extraEnvs = [ "AFL_DISABLE_TRIM=1" ];
      extraArgs = [
        "-a ascii"
        "-p"
        "lin"
      ];
    };
  };

  services.openssh = {
    settings.StreamLocalBindUnlink = true;
    enable = true;
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
