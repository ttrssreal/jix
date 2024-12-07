{ lib, ... }:
{
  jix.home."jess@desk" = {
    profiles = {
      daily.enable = true;
      graphical.windowManager = "dwm";
    };

    system = "x86_64-linux";

    homeDirectory = "/home/jess";
    username = "jess";

    modules = [
      {
        programs.alacritty.settings.font.size = lib.mkForce 10;
      }

      {
        services.dwm-status = {
          enable = true;
          order = [
            "network"
            "time"
          ];

          extraConfig = {
            network.template = "{IPv4}";
            time.format = "%a %d %b %H:%M:%S";
          };
        };
      }
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };
}
