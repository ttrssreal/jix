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
        jix.bluetooth-connect = {
          enable = true;

          deviceAddrs = {
            "headphones" = "AC:80:0A:73:8A:3E";
          };
        };
      }

      {
        jix.dwm-status.features = [
          "battery"
        ];
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
