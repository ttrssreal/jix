{
  writeShellApplication,
  systemd,
  vim,
  ...
}:
writeShellApplication {
  name = "nix-conf-edit";

  runtimeInputs = [
    systemd
    vim
  ];

  text = ''
    if [ "$(id -u)" != "0" ]; then
      echo "error: we need to be root to edit /etc/nix.conf"
      exit 1
    fi

    cp -v /etc/nix/nix.conf /etc/nix/nix.conf.orig
    rm -fv /etc/nix/nix.conf
    cp -v /etc/nix/nix.conf.orig /etc/nix/nix.conf
    chmod -v +w /etc/nix/nix.conf

    "''${EDITOR:-vim}" /etc/nix/nix.conf

    systemctl restart nix-daemon
  '';
}
