{
  lib,
  config,
  ...
}:
let
  cfg = config.jix.xinit;
in
{
  options.jix.xinit = {
    enable = lib.mkEnableOption "xinit";

    init = lib.mkOption {
      type = lib.hm.types.dagOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    jix.xinit.init = {
      setupShell = lib.hm.dag.entryBefore [ "beginScript" ] ''
        set -exo pipefail
      '';

      beginScript = lib.hm.dag.entryAnywhere "";
    };

    home.file.".xinitrc".text = lib.pipe cfg.init [
      lib.hm.dag.topoSort
      (lib.getAttr "result")
      (map (lib.getAttr "data"))
      lib.concatLines
      (lib.mkIf cfg.enable)
    ];
  };
}
