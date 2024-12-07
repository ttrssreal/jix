{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.jix.picom.enable = lib.mkEnableOption "picom";

  config = lib.mkIf config.jix.picom.enable {
    services.picom.enable = true;

    jix.xinit = {
      enable = true;
      init.importNeededX11EnvVars = lib.hm.dag.entryBefore [ "preExecWindowManager" ] ''
        # https://github.com/nix-community/home-manager/issues/1217
        ${lib.getExe' pkgs.systemd "systemctl"} --user import-environment XAUTHORITY DISPLAY
      '';
    };
  };
}
