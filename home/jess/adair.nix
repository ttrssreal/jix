{
  jix.home."jess@adair" = {
    profiles.base.enable = true;

    system = "x86_64-linux";

    homeDirectory = "/home/jess";
    username = "jess";

    modules = [
      (
        { pkgs, lib, ... }:
        {
          programs.gpg.enable = true;

          # https://github.com/ereslibre/homelab/blob/311d585730920375e19428bb727b2c80d380314e/dotfiles/systemd.nix
          systemd.user.services = {
            "gpg-forward-agent-path" = {
              Unit.Description = "Create GnuPG socket directory";
              Service = {
                ExecStart = "${pkgs.gnupg}/bin/gpgconf --create-socketdir";
                ExecStop = "";
              };
              Install.WantedBy = [ "default.target" ];
            };
          };

          home.activation.linger = lib.hm.dag.entryBefore [ "reloadSystemd" ] ''
            "${pkgs.systemd}/bin/loginctl" enable-linger "$USER"
          '';

          programs.zsh.shellAliases.gpg = "${pkgs.gnupg}/bin/gpg --no-autostart";
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
