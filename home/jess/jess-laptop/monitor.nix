let
  # laptop monitor
  eDP-1 = builtins.readFile ./eDP-1.edid;

  # parents house monitor
  DVI-I-2-2 = builtins.readFile ./DVI-I-2-2.edid;
in
{
  programs.autorandr = {
    enable = true;

    profiles = {
      normal = {
        fingerprint = {
          inherit eDP-1;
        };

        config = {
          eDP-1 = {
            enable = true;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "60.01";
          };
        };
      };

      parents-house = {
        fingerprint = {
          inherit
            eDP-1
            DVI-I-2-2
            ;
        };

        config = {
          eDP-1 = {
            enable = true;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "60.01";
          };

          DVI-I-2-2 = {
            enable = true;
            mode = "1920x1080";
            position = "1920x0";
            rate = "60.00";
          };
        };
      };
    };
  };

  # service is started by udev when the drm sybsystem
  # detects a hotplugged monitor
  services.autorandr = {
    enable = true;
    matchEdid = true;
  };
}
