{
  lib,
  config,
  ...
}:
let
  cfg = config.jix.alacritty;
in
{
  options.jix.alacritty = {
    enable = lib.mkEnableOption "alacritty";

    defaultFontSize = lib.mkOption {
      type = lib.types.int;
      default = 7;
    };
  };

  config.programs.alacritty = lib.mkIf cfg.enable {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      font = {
        size = cfg.defaultFontSize;
        normal = {
          family = "Fira Mono";
          style = "Medium";
        };
      };

      window.opacity = 0.85;
    };
  };
}
