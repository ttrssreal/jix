{
  jix.nixos.nodes.desk.modules = [
    (
      { config, ... }:

      {
        # https://nixos.wiki/wiki/Nvidia
        hardware.nvidia = {
          modesetting.enable = true;

          powerManagement = {
            enable = false;
            finegrained = false;
          };

          open = false;
          nvidiaSettings = true;

          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        services.xserver.videoDrivers = [ "nvidia" ];
      }
    )
  ];

  jix.install-iso.modules = [
    {
      # install and add nvidia drivers to supported list so the install
      # media will boot on this hardware
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.open = true;
    }
  ];
}
