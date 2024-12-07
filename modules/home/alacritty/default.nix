{
  lib,
  config,
  ...
}:
let
  cfg = config.jix.alacritty;
in
{
  options.jix.alacritty.enable = lib.mkEnableOption "alacritty";

  config.programs.alacritty = lib.mkIf cfg.enable {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      font = {
        size = 7;
        normal = {
          family = "Fira Mono";
          style = "Medium";
        };
      };

      window.opacity = 0.85;
    };
  };
}
