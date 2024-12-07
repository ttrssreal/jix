# Desk (He/They)

{
  jix.nixos.desk = {
    system = "x86_64-linux";

    profiles.graphical = {
      enable = true;
      windowManager = "dwm";
    };

    users.jess = {
      enable = true;
      uid = 1000;
      extraConfig = {
        extraGroups = [
          "networkmanager"
          "docker"
        ];
      };
    };

    modules = [
      ./system.nix
      ./hardware-configuration.nix
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "24.05"; # Did you read the comment?
  };
}
