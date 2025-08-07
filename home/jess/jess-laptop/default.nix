{
  jix.home."jess@jess-laptop" = {
    profiles = {
      daily.enable = true;
      graphical.windowManager = "dwm";
    };

    system = "x86_64-linux";

    homeDirectory = "/home/jess";
    username = "jess";

    modules = [
      {
        jix.homeKey = {
          enable = true;
          generate = true;
          publicKey = ./homeKey.pub;
        };
      }

      {
        jix.bluetooth-connect = {
          enable = true;
          dmenuFontSize = 15;

          deviceAddrs = {
            "headphones" = "AC:80:0A:73:8A:3E";
          };
        };
      }

      {
        jix.dwm-status = {
          extraConfig.network.template = "{LocalIPv4} @ {ESSID} @ {IPv4}";

          features = [
            "battery"
            "audio"
          ];
        };
      }

      {
        services.barrier.client = {
          enable = true;
          enableCrypto = false;
          server = "desk";
          enableDragDrop = true;
        };
      }

      (
        { config, ... }:
        {
          jix.sops.enable = true;
          sops.secrets.home-backup-repo-password-jess-at-jess-laptop = { };

          jix.home-backup = {
            enable = true;
            passwordFile = config.sops.secrets.home-backup-repo-password-jess-at-jess-laptop.path;
            hostname = "jess-laptop";
          };
        }
      )
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
