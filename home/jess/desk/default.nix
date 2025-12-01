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
      (
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          jix.homeKey = {
            enable = true;
            generate = true;
            publicKey = ./homeKey.pub;
          };

          jix.backblaze-rclone.enable = true;
          jix.sops.enable = true;

          sops.secrets.home-backup-repo-password-jess-at-desk = { };
          jix.home-backup = {
            enable = true;
            hostname = "desk";
            passwordFile = config.sops.secrets.home-backup-repo-password-jess-at-desk.path;
            exclude = [
              "/home/jess/code"
              "/home/jess/.cache"
              "/home/jess/.local/share/containers"
              "/home/jess/silver-desktop-etc-ssh-dir"
              "/home/jess/silver-desktop-var-dir"
              "/home/jess/media/raw" # obs
              "/home/jess/vm" # obs
            ];
          };

          jix.bluetooth-connect = {
            enable = true;
            dmenuFontSize = 15;

            deviceAddrs = {
              "headphones" = "AC:80:0A:73:8A:3E";
            };
          };

          jix.xinit.init.adjustDisplay = lib.hm.dag.entryAfter [ "beginScript" ] ''
            ${lib.getExe pkgs.xorg.xrandr} \
              --output HDMI-0 \
              --auto \
              --pos 0x0 \
              --output DP-0 \
              --auto \
              --scale 1x1 \
              --right-of HDMI-0
          '';

          programs.alacritty.settings.font.size = lib.mkForce 10;

          jix.git.autostartGpgAgent = true;

          programs.gpg.enable = true;

          services.gpg-agent = {
            enable = true;
            pinentry.package = pkgs.pinentry-gtk2;
          };

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;

            matchBlocks = {
              "adair" = {
                remoteForwards = [
                  {
                    bind.address = "/run/user/1000/gnupg/S.gpg-agent";
                    host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                  }
                  {
                    bind.address = "/home/jess/.gnupg/S.gpg-agent";
                    host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                  }
                ];
              };

              "ari" = {
                remoteForwards = [
                  {
                    bind.address = "/run/user/1000/gnupg/S.gpg-agent";
                    host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                  }
                  {
                    bind.address = "/home/jess/.gnupg/S.gpg-agent";
                    host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                  }
                ];
              };

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

          xdg.mimeApps = {
            enable = true;
            defaultApplications = {
              "text/plain" = [ "jessvim.desktop" ];
              "text/x-c" = [ "jessvim.desktop" ];
              "text/x-diff" = [ "jessvim.desktop" ];
              "image/svg+xml" = [ "feh.desktop" ];
            };
          };

          home.packages = [
            pkgs.ninjabrain-bot
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
