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
      ./monitor.nix

      (
        { config, pkgs, ... }:
        {
          jix.homeKey = {
            enable = true;
            generate = true;
            publicKey = ./homeKey.pub;
          };

          jix.backblaze-rclone.enable = true;
          jix.sops.enable = true;

          programs.gpg = {
            enable = true;
            settings.default-key = "BA3350686C918606";
          };

          services.gpg-agent = {
            enable = true;
            pinentry.package = pkgs.pinentry-gtk2;
            enableExtraSocket = true;
          };

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;

            matchBlocks =
              let
                gpgAgentForwardSocket = {
                  remoteForwards = [
                    {
                      bind.address = "/run/user/1000/gnupg/S.gpg-agent";
                      host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                    }
                  ];
                };
              in
              {
                "ari" = gpgAgentForwardSocket;

                "*" = {
                  forwardAgent = false;
                  addKeysToAgent = "no";
                  compression = false;
                  serverAliveInterval = 0;
                  serverAliveCountMax = 3;
                  hashKnownHosts = false;
                  userKnownHostsFile = "~/.ssh/known_hosts";
                  controlMaster = "no";
                  controlPath = "~/.ssh/master-%r@%n:%p";
                  controlPersist = "no";
                };
              };
          };

          sops.secrets.home-backup-repo-password-jess-at-jess-laptop = { };
          jix.home-backup = {
            enable = true;
            passwordFile = config.sops.secrets.home-backup-repo-password-jess-at-jess-laptop.path;
            hostname = "jess-laptop";
            exclude = [
              "/home/jess/.local/share/containers"
            ];
          };

          jix.dwm-status = {
            extraConfig.network.template = "{LocalIPv4} @ {ESSID} @ {IPv4}";
            features = [
              "battery"
              "audio"
            ];
          };

          jix.bluetooth-connect = {
            enable = true;
            dmenuFontSize = 15;

            deviceAddrs = {
              "headphones" = "AC:80:0A:73:8A:3E";
            };
          };

          home.packages = [
            pkgs.attic-client
          ];
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
